import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:xml/xml.dart';

import '../local/database.dart';
import '../local/tables/location_points_table.dart';
import '../local/tables/sync_columns.dart';

class ParsedLocationPoint {
  ParsedLocationPoint({
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    this.altitude,
    this.speed,
    this.heading,
  });

  final double latitude;
  final double longitude;
  final DateTime recordedAt;
  final double? altitude;
  final double? speed;
  final double? heading;
}

/// Result of parsing + dedupe-checking a file, ready for the user to review
/// before anything is written to the DB.
class ImportPreview {
  ImportPreview({
    required this.formatLabel,
    required this.newPoints,
    required this.duplicateCount,
    required this.skippedCount,
  });

  final String formatLabel;
  final List<ParsedLocationPoint> newPoints;
  final int duplicateCount;
  final int skippedCount;

  int get totalParsed => newPoints.length + duplicateCount + skippedCount;
}

/// Thrown when a file doesn't match any client-parseable format. The caller
/// should offer the server-upload path (for large archives) instead.
class UnrecognizedImportFormatException implements Exception {
  UnrecognizedImportFormatException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Client-side parsing for small, self-contained files — GPX, GeoJSON,
/// Ambulo's own JSON export, and OwnTracks JSON/.rec exports. Large archives
/// (Google Takeout, Google Fit, TCX) are handled server-side; see
/// `ServerImportRepository`.
class ImportRepository {
  ImportRepository(this._db);

  final AppDatabase _db;

  Future<ImportPreview> parseAndPreview(String filename, String content) async {
    final _ParsedFile parsed;
    try {
      parsed = _parse(filename, content);
    } on UnrecognizedImportFormatException {
      rethrow;
    } catch (e) {
      // Any parser bug (malformed XML, unexpected field types, etc.) must
      // surface as a friendly message, not an unhandled exception that
      // leaves the import flow stuck mid-air.
      throw UnrecognizedImportFormatException('Could not read this file: $e');
    }
    final points = parsed.points
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    if (points.isEmpty) {
      return ImportPreview(
        formatLabel: parsed.formatLabel,
        newPoints: const [],
        duplicateCount: 0,
        skippedCount: parsed.skippedCount,
      );
    }

    final existing =
        await (_db.select(_db.locationPoints)..where(
              (t) =>
                  t.deletedAt.isNull() &
                  t.recordedAt.isBiggerOrEqualValue(points.first.recordedAt) &
                  t.recordedAt.isSmallerOrEqualValue(points.last.recordedAt),
            ))
            .get();

    final seen = {
      for (final e in existing)
        _dedupeKey(e.recordedAt, e.latitude, e.longitude),
    };
    final newPoints = <ParsedLocationPoint>[];
    var duplicates = 0;
    for (final p in points) {
      final key = _dedupeKey(p.recordedAt, p.latitude, p.longitude);
      if (!seen.add(key)) {
        duplicates++;
      } else {
        newPoints.add(p);
      }
    }

    return ImportPreview(
      formatLabel: parsed.formatLabel,
      newPoints: newPoints,
      duplicateCount: duplicates,
      skippedCount: parsed.skippedCount,
    );
  }

  Future<void> commit(ImportPreview preview) async {
    if (preview.newPoints.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAll(_db.locationPoints, [
        for (final p in preview.newPoints)
          LocationPointsCompanion.insert(
            latitude: p.latitude,
            longitude: p.longitude,
            altitude: Value(p.altitude),
            speed: Value(p.speed),
            heading: Value(p.heading),
            recordedAt: p.recordedAt,
            monitoringMode: MonitoringMode.manual,
            source: RecordSource.import,
            syncState: const Value(SyncState.pendingUpload),
          ),
      ]);
    });
  }

  String _dedupeKey(DateTime t, double lat, double lon) =>
      '${t.toUtc().millisecondsSinceEpoch}_${lat.toStringAsFixed(5)}_${lon.toStringAsFixed(5)}';

  _ParsedFile _parse(String filename, String content) {
    final lower = filename.toLowerCase();
    final trimmed = content.trimLeft();
    if (lower.endsWith('.gpx') ||
        trimmed.startsWith('<?xml') ||
        trimmed.startsWith('<gpx')) {
      return _parseGpx(content);
    }

    try {
      final decoded = jsonDecode(content);
      if (decoded is Map<String, dynamic> &&
          decoded['ambulo_export_version'] != null) {
        return _parseAmbuloJson(decoded);
      }
      if (decoded is Map<String, dynamic> &&
          decoded['type'] == 'FeatureCollection') {
        return _parseGeoJson(decoded);
      }
      if (decoded is List) {
        return _parseOwnTracksList(decoded);
      }
      throw UnrecognizedImportFormatException(
        'Recognized JSON, but not a format Ambulo understands.',
      );
    } on FormatException {
      // Not a single JSON document — try OwnTracks .rec (newline-delimited,
      // each line optionally prefixed with an ISO timestamp before the `{`).
      final points = <ParsedLocationPoint>[];
      var skipped = 0;
      for (final line in const LineSplitter().convert(content)) {
        if (line.trim().isEmpty) continue;
        final idx = line.indexOf('{');
        if (idx == -1) {
          skipped++;
          continue;
        }
        try {
          final obj = jsonDecode(line.substring(idx));
          final point = _ownTracksPoint(obj as Map<String, dynamic>);
          if (point != null) {
            points.add(point);
          } else {
            skipped++;
          }
        } catch (_) {
          skipped++;
        }
      }
      if (points.isEmpty) {
        throw UnrecognizedImportFormatException(
          'Could not recognize this file as GPX, GeoJSON, Ambulo JSON, or '
          'OwnTracks. For Google Takeout, Google Fit, or TCX files, use '
          '"Upload large archive" instead.',
        );
      }
      return _ParsedFile(
        formatLabel: 'OwnTracks',
        points: points,
        skippedCount: skipped,
      );
    }
  }

  _ParsedFile _parseGpx(String content) {
    final XmlDocument doc;
    try {
      doc = XmlDocument.parse(content);
    } on XmlException catch (e) {
      throw UnrecognizedImportFormatException(
        'This GPX file could not be parsed: ${e.message}',
      );
    }
    final points = <ParsedLocationPoint>[];
    var skipped = 0;
    for (final trkpt in doc.findAllElements('trkpt')) {
      try {
        final lat = double.tryParse(trkpt.getAttribute('lat') ?? '');
        final lon = double.tryParse(trkpt.getAttribute('lon') ?? '');
        final timeText = trkpt.findElements('time').firstOrNull?.innerText;
        final time = timeText == null ? null : DateTime.tryParse(timeText);
        if (lat == null || lon == null || time == null) {
          skipped++;
          continue;
        }
        final eleText = trkpt.findElements('ele').firstOrNull?.innerText;
        points.add(
          ParsedLocationPoint(
            latitude: lat,
            longitude: lon,
            recordedAt: time,
            altitude: eleText == null ? null : double.tryParse(eleText),
          ),
        );
      } catch (_) {
        skipped++;
      }
    }
    return _ParsedFile(
      formatLabel: 'GPX',
      points: points,
      skippedCount: skipped,
    );
  }

  _ParsedFile _parseGeoJson(Map<String, dynamic> decoded) {
    final features = decoded['features'];
    final points = <ParsedLocationPoint>[];
    var skipped = 0;
    if (features is List) {
      for (final feature in features) {
        if (feature is! Map<String, dynamic>) {
          skipped++;
          continue;
        }
        final geometry = feature['geometry'];
        final properties = feature['properties'];
        if (geometry is! Map<String, dynamic> ||
            geometry['type'] != 'Point' ||
            geometry['coordinates'] is! List) {
          skipped++;
          continue;
        }
        // A single bad-typed field (e.g. a coordinate given as a string)
        // must only skip this one feature, not fail the whole import.
        try {
          final coords = (geometry['coordinates'] as List)
              .map((e) => (e as num).toDouble())
              .toList();
          final timeRaw = properties is Map
              ? (properties['recorded_at'] ??
                    properties['time'] ??
                    properties['timestamp'])
              : null;
          final time = timeRaw == null
              ? null
              : DateTime.tryParse(timeRaw.toString());
          if (coords.length < 2 || time == null) {
            skipped++;
            continue;
          }
          points.add(
            ParsedLocationPoint(
              longitude: coords[0],
              latitude: coords[1],
              altitude: coords.length > 2 ? coords[2] : null,
              recordedAt: time,
              speed: properties is Map
                  ? (properties['speed'] as num?)?.toDouble()
                  : null,
              heading: properties is Map
                  ? (properties['heading'] as num?)?.toDouble()
                  : null,
            ),
          );
        } catch (_) {
          skipped++;
        }
      }
    }
    return _ParsedFile(
      formatLabel: 'GeoJSON',
      points: points,
      skippedCount: skipped,
    );
  }

  _ParsedFile _parseAmbuloJson(Map<String, dynamic> decoded) {
    final raw = decoded['location_points'];
    final points = <ParsedLocationPoint>[];
    var skipped = 0;
    if (raw is List) {
      for (final item in raw) {
        if (item is! Map<String, dynamic>) {
          skipped++;
          continue;
        }
        try {
          final lat = (item['latitude'] as num?)?.toDouble();
          final lon = (item['longitude'] as num?)?.toDouble();
          final time = item['recorded_at'] == null
              ? null
              : DateTime.tryParse(item['recorded_at'].toString());
          if (lat == null || lon == null || time == null) {
            skipped++;
            continue;
          }
          points.add(
            ParsedLocationPoint(
              latitude: lat,
              longitude: lon,
              recordedAt: time,
              altitude: (item['altitude'] as num?)?.toDouble(),
              speed: (item['speed'] as num?)?.toDouble(),
              heading: (item['heading'] as num?)?.toDouble(),
            ),
          );
        } catch (_) {
          skipped++;
        }
      }
    }
    return _ParsedFile(
      formatLabel: 'Ambulo JSON',
      points: points,
      skippedCount: skipped,
    );
  }

  _ParsedFile _parseOwnTracksList(List<dynamic> decoded) {
    final points = <ParsedLocationPoint>[];
    var skipped = 0;
    void visit(dynamic node) {
      if (node is List) {
        for (final item in node) {
          visit(item);
        }
      } else if (node is Map<String, dynamic>) {
        try {
          final point = _ownTracksPoint(node);
          if (point != null) {
            points.add(point);
          } else {
            skipped++;
          }
        } catch (_) {
          skipped++;
        }
      } else {
        skipped++;
      }
    }

    visit(decoded);
    return _ParsedFile(
      formatLabel: 'OwnTracks',
      points: points,
      skippedCount: skipped,
    );
  }

  ParsedLocationPoint? _ownTracksPoint(Map<String, dynamic> obj) {
    if (obj['_type'] != 'location') return null;
    final lat = (obj['lat'] as num?)?.toDouble();
    final lon = (obj['lon'] as num?)?.toDouble();
    final tst = (obj['tst'] as num?)?.toInt();
    if (lat == null || lon == null || tst == null) return null;
    // OwnTracks 'vel' is km/h; Ambulo stores speed in m/s.
    final velKmh = (obj['vel'] as num?)?.toDouble();
    return ParsedLocationPoint(
      latitude: lat,
      longitude: lon,
      recordedAt: DateTime.fromMillisecondsSinceEpoch(tst * 1000, isUtc: true),
      altitude: (obj['alt'] as num?)?.toDouble(),
      speed: velKmh == null ? null : velKmh * 1000 / 3600,
      heading: (obj['cog'] as num?)?.toDouble(),
    );
  }
}

class _ParsedFile {
  _ParsedFile({
    required this.formatLabel,
    required this.points,
    required this.skippedCount,
  });

  final String formatLabel;
  final List<ParsedLocationPoint> points;
  final int skippedCount;
}
