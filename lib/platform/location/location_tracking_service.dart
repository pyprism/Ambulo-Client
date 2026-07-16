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

  // In-memory "current activity segment" / "current trip" state — only
  // tracked while a continuous stream is running (Significant/Move), not for
  // one-off manual fixes, which don't imply a sustained activity or trip.
  String? _currentSegmentId;
  ActivityType? _currentSegmentType;
  String? _currentTripId;
  Position? _lastPosition;

  /// Whether the continuous position stream is currently running (i.e. a
  /// non-Quit/Manual mode is active and permitted) — surfaced for the
  /// diagnostics screen.
  bool get isActive => _subscription != null;

  Future<LocationTrackingStatus> applyMode(MonitoringMode mode) async {
    await _subscription?.cancel();
    _subscription = null;
    await _closeCurrentSegment();
    await _closeCurrentTrip();
    _lastPosition = null;

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

    _subscription =
        Geolocator.getPositionStream(
          locationSettings: _settingsFor(mode),
        ).listen(
          (position) async {
            await _store(position, mode, RecordSource.location);
            final previous = _lastPosition;
            final delta = previous == null
                ? 0.0
                : haversineMeters(
                    previous.latitude,
                    previous.longitude,
                    position.latitude,
                    position.longitude,
                  );
            await _updateActivitySegment(position, delta);
            await _updateTrip(position, delta);
            await _geofences.checkTransitions(
              latitude: position.latitude,
              longitude: position.longitude,
              recordedAt: position.timestamp,
            );
            _lastPosition = position;
          },
          onError: (_) {},
          cancelOnError: false,
        );
    return LocationTrackingStatus.active;
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
            ? const ForegroundNotificationConfig(
                notificationTitle: 'Ambulo — Move mode',
                notificationText: 'Tracking your location in the background',
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
    RecordSource source,
  ) async {
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
            speed: Value(position.speed >= 0 ? position.speed : null),
            heading: Value(position.heading >= 0 ? position.heading : null),
            recordedAt: position.timestamp,
            batteryLevel: Value(batteryLevel),
            connectivity: Value(connectivity),
            monitoringMode: mode,
            source: source,
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
  /// if the classified activity changed since the last point.
  Future<void> _updateActivitySegment(Position position, double delta) async {
    final type = classifySpeed(position.speed >= 0 ? position.speed : null);

    if (_currentSegmentId == null || _currentSegmentType != type) {
      await _closeCurrentSegment();
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
      return;
    }

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

  /// Starts a trip on the first point of a continuous tracking session,
  /// extends it thereafter — one trip per Significant/Move session, closed
  /// when tracking stops (see [applyMode] / [dispose]).
  Future<void> _updateTrip(Position position, double delta) async {
    if (_currentTripId == null) {
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

  Future<void> _closeCurrentTrip() async {
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
    final bump = SyncBump(current.localRev);
    await (_db.update(
      _db.trips,
    )..where((t) => t.id.equals(_currentTripId!))).write(
      TripsCompanion(
        endedAt: Value(_lastPosition?.timestamp ?? DateTime.now()),
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

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _closeCurrentSegment();
    await _closeCurrentTrip();
  }
}
