import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart' as conn_plus;
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart' hide ActivityType;

import '../../data/local/database.dart';
import '../../data/local/sync_mutation.dart';
import '../../data/local/tables/activity_samples_table.dart';
import '../../data/local/tables/location_points_table.dart';
import '../../data/local/tables/sync_columns.dart';
import '../notifications/notification_service.dart';
import '../platform_support.dart';
import 'activity_classifier.dart';
import 'geo_math.dart';
import 'geofence_service.dart';

/// Outcome of the most recent [LocationTrackingService.applyMode] call —
/// lets callers (Settings/Diagnostics) tell the user *why* tracking isn't
/// running instead of it silently not happening.
enum LocationTrackingStatus {
  /// Quit/Manual, web, or successfully paused — nothing should be running.
  inactive,

  /// The position stream is up and running.
  active,
  locationServiceDisabled,
  permissionDenied,

  /// Whileinuse/foreground permission is granted but Move mode also needs
  /// "Allow all the time", which most OSes can't grant from the in-app
  /// runtime dialog alone — the user needs to flip it in Settings.
  backgroundPermissionNeeded,
}

/// Drives real location capture from the current monitoring mode. Never uses
/// a `Timer` — Significant and Move both ride the OS location-callback
/// stream with a distance filter (coarse for Significant, tight for Move);
/// Manual only ever takes one reading on explicit request; Quit tears
/// everything down. Move additionally asks for a foreground-service
/// notification / background indicator, satisfying the "visible while
/// tracking" requirement on each platform.
class LocationTrackingService {
  LocationTrackingService(this._db);

  final AppDatabase _db;
  StreamSubscription<Position>? _subscription;
  final _battery = Battery();
  late final _geofences = GeofenceService(_db);

  // applyMode/dispose tear down and rebuild the single position stream, so
  // two of them running concurrently would each cancel a null subscription,
  // then each open a stream — the second overwrites `_subscription`, leaking
  // the first as an uncancelled parallel stream whose interleaved async
  // callbacks corrupt the in-memory segment/trip state (every point starts a
  // fresh 0-distance segment). At app start this genuinely happens: the
  // provider fires an apply from `ref.listen(monitoringMode)` /
  // `ref.listen(trackingPaused)` (both during their controller's restore)
  // *and* from the ready-gated `Future.wait(...).then`. Chaining every
  // mutation through this future serializes them, so a later apply fully
  // awaits the previous one's teardown before starting.
  Future<void> _mutations = Future<void>.value();
  Future<void> _positionMutations = Future<void>.value();

  // A classification change must persist across this much wall-clock time
  // before a new activity segment actually starts — otherwise a single
  // noisy GPS point fragments activity history / active-minutes.
  static const _minSegmentSwitchDuration = Duration(seconds: 45);

  // A trip is split once the device stays within this radius for this long
  // — otherwise a user who leaves Significant/Move on permanently gets one
  // giant multi-day "trip".
  static const _stationaryRadiusMeters = 50.0;
  static const _tripStationaryGap = Duration(minutes: 20);
  static const _tripStartMovementMeters = 10.0;

  // Below this, "hasn't left the anchor radius yet" just means "still
  // walking across it" — Move mode's 10 m distance filter means a
  // walking-pace point lands inside the radius for several consecutive
  // callbacks before finally pushing past it (worst case, at walking pace,
  // ~50-60s to cross 50 m). Only once a point sits in the radius *longer*
  // than that does it actually indicate the device stopped, so jitter
  // suppression in [_checkStationaryGap] gates on this elapsed time, not on
  // radius containment alone — otherwise it would wrongly zero out most of
  // a continuous walk's distance every time the anchor goes stale for a
  // few points.
  static const _stationaryJitterGap = Duration(minutes: 2);

  // In-memory "current activity segment" / "current trip" state — only
  // tracked while a continuous stream is running (Significant/Move), not for
  // one-off manual fixes, which don't imply a sustained activity or trip.
  String? _currentSegmentId;
  ActivityType? _currentSegmentType;
  ActivityType? _pendingSegmentType;
  DateTime? _pendingSegmentSince;
  String? _currentTripId;
  Position? _stationaryAnchor;
  DateTime? _lastMovementAt;
  Position? _lastPosition;

  /// Whether the continuous position stream is currently running (i.e. a
  /// non-Quit/Manual mode is active and permitted) — surfaced for the
  /// diagnostics screen.
  bool get isActive => _subscription != null;

  /// Serializes a mutation onto [_mutations] so concurrent apply/dispose
  /// calls can't race the single position-stream teardown/rebuild. Errors
  /// are isolated to the caller — the chain itself never breaks, so one
  /// failed apply can't wedge every later one.
  Future<T> _serialize<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _mutations = _mutations.then((_) async {
      try {
        completer.complete(await action());
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  Future<LocationTrackingStatus> applyMode(MonitoringMode mode) =>
      _serialize(() => _applyMode(mode));

  Future<LocationTrackingStatus> _applyMode(MonitoringMode mode) async {
    await _subscription?.cancel();
    _subscription = null;
    await _safeCancelMoveReminder();
    await _positionMutations;
    await _closeCurrentSegment();
    await _closeCurrentTrip();
    _lastPosition = null;
    _pendingSegmentType = null;
    _pendingSegmentSince = null;
    _stationaryAnchor = null;
    _lastMovementAt = null;

    if (!PlatformSupport.supportsSensorCollection) {
      return LocationTrackingStatus.inactive;
    }
    if (mode == MonitoringMode.quit || mode == MonitoringMode.manual) {
      return LocationTrackingStatus.inactive;
    }

    final status = await _resolvePermission(
      background: mode == MonitoringMode.move,
    );
    if (status != LocationTrackingStatus.active) return status;

    if (mode == MonitoringMode.move) {
      await _safeEnsureGeolocatorNotificationChannel();
    }
    _subscription =
        Geolocator.getPositionStream(
          locationSettings: _settingsFor(mode),
        ).listen(
          (position) => _enqueuePosition(position, mode),
          onError: (e, st) => debugPrint('location stream error: $e\n$st'),
          cancelOnError: false,
        );
    if (mode == MonitoringMode.move) {
      await _safeScheduleMoveReminder();
    }
    return LocationTrackingStatus.active;
  }

  // Works around a geolocator_android bug where its own foreground-service
  // notification channel is created disabled (see
  // NotificationService._geolocatorChannelId) — must run before the
  // position stream starts so the fix is in place by the time geolocator
  // tries to post to that channel. Never let this block tracking itself.
  Future<void> _safeEnsureGeolocatorNotificationChannel() async {
    try {
      await NotificationService.instance
          .ensureGeolocatorNotificationChannelVisible();
    } catch (e, st) {
      debugPrint('geolocator notification channel fix failed: $e\n$st');
    }
  }

  // The Move-mode reminder is a courtesy, not core tracking behavior — a
  // missing notification permission/plugin channel (e.g. under test) must
  // never take down the position stream it's attached to.
  Future<void> _safeScheduleMoveReminder() async {
    try {
      await NotificationService.instance.scheduleMoveModeReminder();
    } catch (e, st) {
      debugPrint('move mode reminder schedule failed: $e\n$st');
    }
  }

  Future<void> _safeCancelMoveReminder() async {
    try {
      await NotificationService.instance.cancelMoveModeReminder();
    } catch (e, st) {
      debugPrint('move mode reminder cancel failed: $e\n$st');
    }
  }

  /// Stream listeners don't await async callbacks. Queue the whole pipeline
  /// so every point observes one consistent in-memory segment/trip state.
  void _enqueuePosition(Position position, MonitoringMode mode) {
    _positionMutations = _positionMutations.then((_) async {
      try {
        await _store(
          position,
          mode,
          RecordSource.location,
          tripId: _currentTripId,
        );
        final previous = _lastPosition;
        final delta = previous == null
            ? 0.0
            : haversineMeters(
                previous.latitude,
                previous.longitude,
                position.latitude,
                position.longitude,
              );
        _lastPosition = position;
        await _updateActivitySegment(position, delta);
        final gap = await _checkStationaryGap(position);
        if (!gap.closedTrip && !gap.stationary) {
          await _updateTrip(position, delta);
        }
        await _geofences.checkTransitions(
          latitude: position.latitude,
          longitude: position.longitude,
          recordedAt: position.timestamp,
        );
      } catch (e, st) {
        debugPrint('location callback failed: $e\n$st');
      }
    });
  }

  /// Manual mode's "record now" action — also usable from any other mode as
  /// an explicit one-off capture.
  Future<bool> recordManualPoint() async {
    if (!PlatformSupport.supportsSensorCollection) return false;
    final status = await _resolvePermission(background: false);
    if (status != LocationTrackingStatus.active) return false;
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      await _store(position, MonitoringMode.manual, RecordSource.manual);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<LocationTrackingStatus> _resolvePermission({
    required bool background,
  }) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationTrackingStatus.locationServiceDisabled;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return LocationTrackingStatus.permissionDenied;
    }
    if (background && permission != LocationPermission.always) {
      // Most OSes (Android 11+, iOS's two-step prompt) can't grant "always"
      // from a single runtime dialog — but ask once more in case this one
      // can, before telling the user they need a Settings hop.
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always) {
        return LocationTrackingStatus.backgroundPermissionNeeded;
      }
    }
    return LocationTrackingStatus.active;
  }

  LocationSettings _settingsFor(MonitoringMode mode) {
    final isMove = mode == MonitoringMode.move;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: isMove ? LocationAccuracy.high : LocationAccuracy.reduced,
        distanceFilter: isMove ? 10 : 200,
        foregroundNotificationConfig: isMove
            ? ForegroundNotificationConfig(
                notificationTitle: 'Ambulo — Move mode',
                notificationText: 'Tracking your location in the background',
                notificationChannelName:
                    NotificationService.geolocatorChannelName,
                enableWakeLock: true,
              )
            : null,
      );
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: isMove ? LocationAccuracy.best : LocationAccuracy.reduced,
        distanceFilter: isMove ? 10 : 200,
        pauseLocationUpdatesAutomatically: !isMove,
        allowBackgroundLocationUpdates: isMove,
        showBackgroundLocationIndicator: isMove,
      );
    }
    return LocationSettings(
      accuracy: isMove ? LocationAccuracy.high : LocationAccuracy.reduced,
      distanceFilter: isMove ? 10 : 200,
    );
  }

  Future<void> _store(
    Position position,
    MonitoringMode mode,
    RecordSource source, {
    String? tripId,
  }) async {
    final batteryLevel = await _safeBatteryLevel();
    final connectivity = await _connectivityKind();

    await _db
        .into(_db.locationPoints)
        .insert(
          LocationPointsCompanion.insert(
            latitude: position.latitude,
            longitude: position.longitude,
            altitude: Value(position.altitude),
            horizontalAccuracy: Value(position.accuracy),
            verticalAccuracy: Value(position.altitudeAccuracy),
            speed: Value(position.speed >= 0 ? position.speed : null),
            speedAccuracy: Value(
              position.speedAccuracy > 0 ? position.speedAccuracy : null,
            ),
            heading: Value(position.heading >= 0 ? position.heading : null),
            recordedAt: position.timestamp,
            batteryLevel: Value(batteryLevel),
            connectivity: Value(connectivity),
            monitoringMode: mode,
            source: source,
            tripId: Value(tripId),
            syncState: const Value(SyncState.pendingUpload),
          ),
        );
  }

  Future<int?> _safeBatteryLevel() async {
    try {
      return await _battery.batteryLevel;
    } catch (_) {
      return null;
    }
  }

  Future<Connectivity> _connectivityKind() async {
    try {
      final results = await conn_plus.Connectivity().checkConnectivity();
      if (results.contains(conn_plus.ConnectivityResult.wifi)) {
        return Connectivity.wifi;
      }
      if (results.contains(conn_plus.ConnectivityResult.mobile)) {
        return Connectivity.cellular;
      }
      if (results.contains(conn_plus.ConnectivityResult.none)) {
        return Connectivity.offline;
      }
      return Connectivity.unknown;
    } catch (_) {
      return Connectivity.unknown;
    }
  }

  /// Extends the current activity segment, or closes it and opens a new one
  /// once the classified activity has changed *and* that change has
  /// persisted for [_minSegmentSwitchDuration] — a single noisy GPS point
  /// just extends the current segment instead of fragmenting it.
  Future<void> _updateActivitySegment(Position position, double delta) async {
    final type = classifySpeed(
      position.speed >= 0 ? position.speed : null,
      horizontalAccuracy: position.accuracy,
    );

    if (_currentSegmentId == null) {
      _pendingSegmentType = null;
      _pendingSegmentSince = null;
      await _startSegment(type, position);
      return;
    }

    if (type == _currentSegmentType) {
      _pendingSegmentType = null;
      _pendingSegmentSince = null;
      await _extendCurrentSegment(position, delta);
      return;
    }

    if (_pendingSegmentType != type) {
      _pendingSegmentType = type;
      _pendingSegmentSince = position.timestamp;
    }
    final pendingElapsed = position.timestamp.difference(_pendingSegmentSince!);
    if (pendingElapsed < _minSegmentSwitchDuration) {
      await _extendCurrentSegment(position, delta);
      return;
    }

    _pendingSegmentType = null;
    _pendingSegmentSince = null;
    await _closeCurrentSegment();
    await _startSegment(type, position);
  }

  Future<void> _startSegment(ActivityType type, Position position) async {
    final row = await _db
        .into(_db.activitySamples)
        .insertReturning(
          ActivitySamplesCompanion.insert(
            activityType: type,
            startedAt: position.timestamp,
            distanceMeters: const Value(0),
            source: RecordSource.motion,
            syncState: const Value(SyncState.pendingUpload),
          ),
        );
    _currentSegmentId = row.id;
    _currentSegmentType = type;
  }

  Future<void> _extendCurrentSegment(Position position, double delta) async {
    final current = await (_db.select(
      _db.activitySamples,
    )..where((t) => t.id.equals(_currentSegmentId!))).getSingleOrNull();
    if (current == null) return;

    final bump = SyncBump(current.localRev);
    await (_db.update(
      _db.activitySamples,
    )..where((t) => t.id.equals(_currentSegmentId!))).write(
      ActivitySamplesCompanion(
        endedAt: Value(position.timestamp),
        distanceMeters: Value((current.distanceMeters ?? 0) + delta),
        updatedAt: bump.updatedAt,
        localRev: bump.localRev,
        syncState: bump.syncState,
      ),
    );
  }

  /// Closes the current trip once the device has stayed within
  /// [_stationaryRadiusMeters] for [_tripStationaryGap] — splitting what
  /// would otherwise be one unbounded trip for as long as tracking stays
  /// on. The next point starts a fresh trip via [_updateTrip]. `endedAt` is
  /// stamped with [_lastMovementAt], not this point's timestamp, so the
  /// stationary tail (up to [_tripStationaryGap] long) isn't counted as trip
  /// duration. Once a trip is running and this point has sat inside the
  /// anchor radius for at least [_stationaryJitterGap] without yet closing
  /// the trip, `stationary` tells the caller to also skip the
  /// distance/endedAt bump in [_updateTrip] — jitter during a genuine dwell
  /// shouldn't advance either. That threshold — not bare radius containment
  /// — is what distinguishes a stall from an ordinary walk: [_stationaryAnchor]
  /// only resets once a point clears the radius, so during continuous
  /// movement several consecutive points land inside it before the anchor
  /// catches up; gating on elapsed time keeps those counted as real motion.
  /// Also gated on `_currentTripId != null`: before a trip exists,
  /// [_updateTrip]'s own delta-based movement threshold is what decides
  /// whether a point counts, so an anchor that simply hasn't drifted past
  /// the radius yet must not block trip creation.
  Future<({bool closedTrip, bool stationary})> _checkStationaryGap(
    Position position,
  ) async {
    final anchor = _stationaryAnchor;
    if (anchor == null) {
      _stationaryAnchor = position;
      _lastMovementAt = position.timestamp;
      return (closedTrip: false, stationary: false);
    }

    final distanceFromAnchor = haversineMeters(
      anchor.latitude,
      anchor.longitude,
      position.latitude,
      position.longitude,
    );
    if (distanceFromAnchor > _stationaryRadiusMeters) {
      _stationaryAnchor = position;
      _lastMovementAt = position.timestamp;
      return (closedTrip: false, stationary: false);
    }

    final lastMovement = _lastMovementAt;
    if (_currentTripId != null && lastMovement != null) {
      final gap = position.timestamp.difference(lastMovement);
      if (gap >= _tripStationaryGap) {
        await _closeCurrentTrip(endedAt: lastMovement);
        _stationaryAnchor = position;
        _lastMovementAt = position.timestamp;
        return (closedTrip: true, stationary: false);
      }
      if (gap >= _stationaryJitterGap) {
        return (closedTrip: false, stationary: true);
      }
    }
    return (closedTrip: false, stationary: false);
  }

  /// Starts a trip on the first point of a continuous tracking session,
  /// extends it thereafter — one trip per Significant/Move session, closed
  /// when tracking stops (see [applyMode] / [dispose]).
  Future<void> _updateTrip(Position position, double delta) async {
    if (_currentTripId == null) {
      if (delta < _tripStartMovementMeters) return;
      final startPlace = await _findContainingPlace(
        position.latitude,
        position.longitude,
      );
      final row = await _db
          .into(_db.trips)
          .insertReturning(
            TripsCompanion.insert(
              startedAt: position.timestamp,
              distanceMeters: const Value(0),
              pointCount: const Value(1),
              startPlaceId: Value(startPlace?.id),
              source: RecordSource.location,
              syncState: const Value(SyncState.pendingUpload),
            ),
          );
      _currentTripId = row.id;
      return;
    }

    final current = await (_db.select(
      _db.trips,
    )..where((t) => t.id.equals(_currentTripId!))).getSingleOrNull();
    if (current == null) return;

    final bump = SyncBump(current.localRev);
    await (_db.update(
      _db.trips,
    )..where((t) => t.id.equals(_currentTripId!))).write(
      TripsCompanion(
        endedAt: Value(position.timestamp),
        distanceMeters: Value(current.distanceMeters + delta),
        pointCount: Value(current.pointCount + 1),
        updatedAt: bump.updatedAt,
        localRev: bump.localRev,
        syncState: bump.syncState,
      ),
    );
  }

  /// `endedAt` defaults to the last recorded point's timestamp — correct for
  /// the applyMode/dispose path, where tracking stopped mid-movement and the
  /// last point *is* the trip's end. [_checkStationaryGap] passes
  /// [_lastMovementAt] instead, trimming the stationary tail out of the
  /// trip's duration. `_lastMovementAt` and trip creation use different
  /// thresholds (50m stationary-radius vs. 10m start-movement delta), so
  /// `_lastMovementAt` can still point at a timestamp from *before* the trip
  /// was created (the point that created the trip can itself land inside the
  /// still-fresh anchor's radius) — clamped to `startedAt` so `endedAt` never
  /// precedes it and duration never goes negative.
  Future<void> _closeCurrentTrip({DateTime? endedAt}) async {
    if (_currentTripId == null) return;
    final current = await (_db.select(
      _db.trips,
    )..where((t) => t.id.equals(_currentTripId!))).getSingleOrNull();
    if (current == null) {
      _currentTripId = null;
      return;
    }
    final endPlace = _lastPosition == null
        ? null
        : await _findContainingPlace(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
          );
    final resolvedEndedAt =
        endedAt ?? _lastPosition?.timestamp ?? DateTime.now();
    final bump = SyncBump(current.localRev);
    await (_db.update(
      _db.trips,
    )..where((t) => t.id.equals(_currentTripId!))).write(
      TripsCompanion(
        endedAt: Value(
          resolvedEndedAt.isBefore(current.startedAt)
              ? current.startedAt
              : resolvedEndedAt,
        ),
        endPlaceId: Value(endPlace?.id),
        updatedAt: bump.updatedAt,
        localRev: bump.localRev,
        syncState: bump.syncState,
      ),
    );
    _currentTripId = null;
  }

  Future<Place?> _findContainingPlace(double latitude, double longitude) async {
    final places = await (_db.select(
      _db.places,
    )..where((t) => t.deletedAt.isNull())).get();
    Place? closest;
    var closestDistance = double.infinity;
    for (final place in places) {
      final distance = haversineMeters(
        latitude,
        longitude,
        place.latitude,
        place.longitude,
      );
      if (distance <= place.radiusMeters && distance < closestDistance) {
        closest = place;
        closestDistance = distance;
      }
    }
    return closest;
  }

  // Segments have the same stationary-tail issue as trips ([_closeCurrentTrip])
  // but no speed UI depends on segment duration — not worth wiring the
  // stationary-gap plumbing through here too. Revisit if that changes.
  Future<void> _closeCurrentSegment() async {
    if (_currentSegmentId == null) return;
    final current = await (_db.select(
      _db.activitySamples,
    )..where((t) => t.id.equals(_currentSegmentId!))).getSingleOrNull();
    if (current == null) {
      _currentSegmentId = null;
      _currentSegmentType = null;
      return;
    }
    final bump = SyncBump(current.localRev);
    await (_db.update(
      _db.activitySamples,
    )..where((t) => t.id.equals(_currentSegmentId!))).write(
      ActivitySamplesCompanion(
        endedAt: Value(_lastPosition?.timestamp ?? DateTime.now()),
        updatedAt: bump.updatedAt,
        localRev: bump.localRev,
        syncState: bump.syncState,
      ),
    );
    _currentSegmentId = null;
    _currentSegmentType = null;
  }

  Future<void> dispose() => _serialize(_dispose);

  Future<void> _dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    await _safeCancelMoveReminder();
    await _positionMutations;
    await _closeCurrentSegment();
    await _closeCurrentTrip();
    _pendingSegmentType = null;
    _pendingSegmentSince = null;
    _stationaryAnchor = null;
    _lastMovementAt = null;
  }
}
