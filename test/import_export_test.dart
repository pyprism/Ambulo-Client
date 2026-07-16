import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ambulo/data/local/database.dart';
import 'package:ambulo/data/local/tables/location_points_table.dart';
import 'package:ambulo/data/local/tables/sync_columns.dart';
import 'package:ambulo/data/repositories/export_repository.dart';
import 'package:ambulo/data/repositories/import_repository.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('parses GPX, imports new points, and dedupes on re-import', () async {
    const gpx = '''
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="test"><trk><trkseg>
  <trkpt lat="51.5" lon="-0.12"><ele>10</ele><time>2026-01-01T10:00:00Z</time></trkpt>
  <trkpt lat="51.51" lon="-0.13"><ele>12</ele><time>2026-01-01T10:05:00Z</time></trkpt>
</trkseg></trk></gpx>
''';
    final repo = ImportRepository(db);

    final preview = await repo.parseAndPreview('track.gpx', gpx);
    expect(preview.formatLabel, 'GPX');
    expect(preview.newPoints, hasLength(2));
    expect(preview.duplicateCount, 0);

    await repo.commit(preview);
    final stored = await db.select(db.locationPoints).get();
    expect(stored, hasLength(2));
    expect(stored.every((p) => p.source == RecordSource.import), isTrue);

    // Re-importing the same file should dedupe against what's now stored.
    final secondPreview = await repo.parseAndPreview('track.gpx', gpx);
    expect(secondPreview.newPoints, isEmpty);
    expect(secondPreview.duplicateCount, 2);
  });

  test('parses GeoJSON FeatureCollection', () async {
    const geoJson = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {"type": "Point", "coordinates": [-0.12, 51.5, 10]},
      "properties": {"recorded_at": "2026-01-02T09:00:00Z", "speed": 1.5}
    }
  ]
}
''';
    final repo = ImportRepository(db);
    final preview = await repo.parseAndPreview('trip.geojson', geoJson);
    expect(preview.formatLabel, 'GeoJSON');
    expect(preview.newPoints, hasLength(1));
    expect(preview.newPoints.single.latitude, 51.5);
    expect(preview.newPoints.single.longitude, -0.12);
  });

  test('parses OwnTracks JSON array records', () async {
    const ownTracks = '''
[
  {"_type": "location", "lat": 51.5, "lon": -0.12, "tst": 1767261600, "vel": 18},
  {"_type": "waypoint", "lat": 0, "lon": 0}
]
''';
    final repo = ImportRepository(db);
    final preview = await repo.parseAndPreview('export.json', ownTracks);
    expect(preview.formatLabel, 'OwnTracks');
    expect(preview.newPoints, hasLength(1));
    expect(preview.newPoints.single.speed, closeTo(5.0, 0.01));
  });

  test('parses OwnTracks .rec (newline-delimited, timestamp-prefixed)', () async {
    const rec =
        '2026-01-01T10:00:00Z * {"_type":"location","lat":51.5,"lon":-0.12,"tst":1767261600}\n'
        '2026-01-01T10:05:00Z * {"_type":"location","lat":51.51,"lon":-0.13,"tst":1767261900}\n';
    final repo = ImportRepository(db);
    final preview = await repo.parseAndPreview('export.rec', rec);
    expect(preview.formatLabel, 'OwnTracks');
    expect(preview.newPoints, hasLength(2));
  });

  test('round-trips through Ambulo JSON export and re-import', () async {
    await db
        .into(db.locationPoints)
        .insert(
          LocationPointsCompanion.insert(
            latitude: 51.5,
            longitude: -0.12,
            recordedAt: DateTime.utc(2026, 1, 1, 10),
            monitoringMode: MonitoringMode.manual,
            source: RecordSource.manual,
          ),
        );

    final exportRepo = ExportRepository(db);
    final json = await exportRepo.build(ExportFormat.json);

    await db.close();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final importRepo = ImportRepository(db);
    final preview = await importRepo.parseAndPreview('backup.json', json);
    expect(preview.formatLabel, 'Ambulo JSON');
    expect(preview.newPoints, hasLength(1));
  });

  test('rejects an unrecognized file format', () async {
    final repo = ImportRepository(db);
    await expectLater(
      repo.parseAndPreview('notes.txt', 'just some plain text notes'),
      throwsA(isA<UnrecognizedImportFormatException>()),
    );
  });

  test('malformed GPX (invalid XML) surfaces a friendly error, not a raw '
      'XML exception', () async {
    final repo = ImportRepository(db);
    await expectLater(
      repo.parseAndPreview('broken.gpx', '<?xml version="1.0"?><gpx><trk>'),
      throwsA(isA<UnrecognizedImportFormatException>()),
    );
  });

  test('GeoJSON with non-numeric coordinates skips only the bad feature', () async {
    const geoJson = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {"type": "Point", "coordinates": ["not-a-number", 51.5]},
      "properties": {"recorded_at": "2026-01-02T09:00:00Z"}
    },
    {
      "type": "Feature",
      "geometry": {"type": "Point", "coordinates": [-0.12, 51.5]},
      "properties": {"recorded_at": "2026-01-02T09:05:00Z"}
    }
  ]
}
''';
    final repo = ImportRepository(db);
    final preview = await repo.parseAndPreview('trip.geojson', geoJson);
    expect(preview.newPoints, hasLength(1));
    expect(preview.skippedCount, 1);
  });

  test('Ambulo JSON with a bad numeric field skips only that record', () async {
    const json = '''
{
  "ambulo_export_version": 1,
  "location_points": [
    {"id": "a", "latitude": "oops", "longitude": -0.12, "recorded_at": "2026-01-01T10:00:00Z"},
    {"id": "b", "latitude": 51.5, "longitude": -0.12, "recorded_at": "2026-01-01T10:05:00Z"}
  ]
}
''';
    final repo = ImportRepository(db);
    final preview = await repo.parseAndPreview('backup.json', json);
    expect(preview.newPoints, hasLength(1));
    expect(preview.skippedCount, 1);
  });

  test('invalid/truncated JSON does not crash the import flow', () async {
    final repo = ImportRepository(db);
    await expectLater(
      repo.parseAndPreview('broken.json', '{"_type": "location", "lat": '),
      throwsA(isA<UnrecognizedImportFormatException>()),
    );
  });

  test('builds CSV and GPX export content', () async {
    await db
        .into(db.locationPoints)
        .insert(
          LocationPointsCompanion.insert(
            latitude: 51.5,
            longitude: -0.12,
            recordedAt: DateTime.utc(2026, 1, 1, 10),
            monitoringMode: MonitoringMode.manual,
            source: RecordSource.manual,
          ),
        );
    final repo = ExportRepository(db);

    final csv = await repo.build(ExportFormat.csv);
    expect(csv, contains('latitude,longitude'));
    expect(csv, contains('51.5'));

    final gpx = await repo.build(ExportFormat.gpx);
    expect(gpx, contains('<gpx'));
    expect(gpx, contains('lat="51.5"'));
  });
}
