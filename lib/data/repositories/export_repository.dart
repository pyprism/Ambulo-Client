import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:drift/drift.dart';

import '../local/database.dart';

enum ExportFormat { json, csv, gpx, geoJson }

extension ExportFormatX on ExportFormat {
  String get fileExtension => switch (this) {
    ExportFormat.json => 'json',
    ExportFormat.csv => 'csv',
    ExportFormat.gpx => 'gpx',
    ExportFormat.geoJson => 'geojson',
  };

  String get label => switch (this) {
    ExportFormat.json => 'Ambulo JSON',
    ExportFormat.csv => 'CSV',
    ExportFormat.gpx => 'GPX',
    ExportFormat.geoJson => 'GeoJSON',
  };

  String get mimeType => switch (this) {
    ExportFormat.json => 'application/json',
    ExportFormat.csv => 'text/csv',
    ExportFormat.gpx => 'application/gpx+xml',
    ExportFormat.geoJson => 'application/geo+json',
  };
}

/// Builds export files straight from the local DB — works fully offline,
/// no server round-trip needed (matches offline-first client-owned-logic).
class ExportRepository {
  ExportRepository(this._db);

  final AppDatabase _db;

  Future<String> build(ExportFormat format) async {
    final points =
        await (_db.select(_db.locationPoints)
              ..where((t) => t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.asc(t.recordedAt)]))
            .get();

    return switch (format) {
      ExportFormat.json => _buildJson(points),
      ExportFormat.csv => _buildCsv(points),
      ExportFormat.gpx => _buildGpx(points),
      ExportFormat.geoJson => _buildGeoJson(points),
    };
  }

  Future<String> _buildJson(List<LocationPoint> points) async {
    final places = await _db.select(_db.places).get();
    final trips = await _db.select(_db.trips).get();
    final healthSamples = await _db.select(_db.healthSamples).get();
    final activitySamples = await _db.select(_db.activitySamples).get();
    final goals = await _db.select(_db.goals).get();
    final workouts = await _db.select(_db.workoutSessions).get();
    final notes = await _db.select(_db.notes).get();

    final data = {
      'ambulo_export_version': 2,
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'location_points': [
        for (final p in points)
          {
            'id': p.id,
            'latitude': p.latitude,
            'longitude': p.longitude,
            'altitude': p.altitude,
            'horizontal_accuracy': p.horizontalAccuracy,
            'speed': p.speed,
            'heading': p.heading,
            'recorded_at': p.recordedAt.toUtc().toIso8601String(),
          },
      ],
      'places': [
        for (final place in places.where((p) => p.deletedAt == null))
          {
            'id': place.id,
            'name': place.name,
            'category': place.category.name,
            'latitude': place.latitude,
            'longitude': place.longitude,
            'radius_meters': place.radiusMeters,
            'address': place.address,
          },
      ],
      'trips': [
        for (final trip in trips.where((t) => t.deletedAt == null))
          {
            'id': trip.id,
            'name': trip.name,
            'started_at': trip.startedAt.toUtc().toIso8601String(),
            'ended_at': trip.endedAt?.toUtc().toIso8601String(),
            'distance_meters': trip.distanceMeters,
            'point_count': trip.pointCount,
            'start_place_id': trip.startPlaceId,
            'end_place_id': trip.endPlaceId,
          },
      ],
      'health_samples': [
        for (final sample in healthSamples.where((s) => s.deletedAt == null))
          {
            'id': sample.id,
            'metric_type': sample.metricType.name,
            'value': sample.value,
            'unit': sample.unit,
            'recorded_at': sample.recordedAt.toUtc().toIso8601String(),
            'note': sample.note,
          },
      ],
      'activity_samples': [
        for (final sample in activitySamples.where((s) => s.deletedAt == null))
          {
            'id': sample.id,
            'activity_type': sample.activityType.name,
            'started_at': sample.startedAt.toUtc().toIso8601String(),
            'ended_at': sample.endedAt?.toUtc().toIso8601String(),
            'confidence': sample.confidence,
            'distance_meters': sample.distanceMeters,
            'steps': sample.steps,
          },
      ],
      'goals': [
        for (final goal in goals.where((g) => g.deletedAt == null))
          {
            'id': goal.id,
            'metric_type': goal.metricType.name,
            'target_value': goal.targetValue,
            'period': goal.period.name,
            'start_date':
                '${goal.startDate.year.toString().padLeft(4, '0')}-${goal.startDate.month.toString().padLeft(2, '0')}-${goal.startDate.day.toString().padLeft(2, '0')}',
            'end_date': goal.endDate == null
                ? null
                : '${goal.endDate!.year.toString().padLeft(4, '0')}-${goal.endDate!.month.toString().padLeft(2, '0')}-${goal.endDate!.day.toString().padLeft(2, '0')}',
            'is_active': goal.isActive,
          },
      ],
      'workout_sessions': [
        for (final workout in workouts.where((w) => w.deletedAt == null))
          {
            'id': workout.id,
            'activity_type': workout.activityType.name,
            'started_at': workout.startedAt.toUtc().toIso8601String(),
            'ended_at': workout.endedAt?.toUtc().toIso8601String(),
            'distance_meters': workout.distanceMeters,
            'calories': workout.calories,
            'notes': workout.notes,
          },
      ],
      'notes': [
        for (final note in notes.where((n) => n.deletedAt == null))
          {
            'id': note.id,
            'content': note.content,
            'note_date':
                '${note.noteDate.year.toString().padLeft(4, '0')}-${note.noteDate.month.toString().padLeft(2, '0')}-${note.noteDate.day.toString().padLeft(2, '0')}',
            'context': note.context,
          },
      ],
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  String _buildCsv(List<LocationPoint> points) {
    final rows = [
      [
        'id',
        'latitude',
        'longitude',
        'altitude',
        'speed',
        'heading',
        'horizontal_accuracy',
        'recorded_at',
      ],
      for (final p in points)
        [
          p.id,
          p.latitude,
          p.longitude,
          p.altitude ?? '',
          p.speed ?? '',
          p.heading ?? '',
          p.horizontalAccuracy ?? '',
          p.recordedAt.toUtc().toIso8601String(),
        ],
    ];
    return Csv().encode(rows);
  }

  String _buildGpx(List<LocationPoint> points) {
    final buffer = StringBuffer()
      ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
      ..writeln(
        '<gpx version="1.1" creator="Ambulo" '
        'xmlns="http://www.topografix.com/GPX/1/1">',
      )
      ..writeln('  <trk>')
      ..writeln('    <name>Ambulo export</name>')
      ..writeln('    <trkseg>');
    for (final p in points) {
      buffer.writeln('      <trkpt lat="${p.latitude}" lon="${p.longitude}">');
      if (p.altitude != null) {
        buffer.writeln('        <ele>${p.altitude}</ele>');
      }
      buffer.writeln(
        '        <time>${p.recordedAt.toUtc().toIso8601String()}</time>',
      );
      buffer.writeln('      </trkpt>');
    }
    buffer
      ..writeln('    </trkseg>')
      ..writeln('  </trk>')
      ..writeln('</gpx>');
    return buffer.toString();
  }

  String _buildGeoJson(List<LocationPoint> points) {
    final data = {
      'type': 'FeatureCollection',
      'features': [
        for (final p in points)
          {
            'type': 'Feature',
            'geometry': {
              'type': 'Point',
              'coordinates': [
                p.longitude,
                p.latitude,
                if (p.altitude != null) p.altitude,
              ],
            },
            'properties': {
              'id': p.id,
              'recorded_at': p.recordedAt.toUtc().toIso8601String(),
              if (p.speed != null) 'speed': p.speed,
              if (p.heading != null) 'heading': p.heading,
              if (p.horizontalAccuracy != null)
                'horizontal_accuracy': p.horizontalAccuracy,
            },
          },
      ],
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }
}
