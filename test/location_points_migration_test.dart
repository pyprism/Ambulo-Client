// Smoke test for the v5->v6 migration: adds `speed_accuracy` and `trip_id`
// to `location_points`. Builds a v5-shaped database by hand (the v6 CREATE
// TABLE with those two columns stripped out), seeds a row, then opens it
// through AppDatabase so the real `onUpgrade` runs — proving existing rows
// survive and the new columns read back null.
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

import 'package:ambulo/data/local/database.dart';
import 'package:ambulo/data/local/tables/location_points_table.dart';
import 'package:ambulo/data/local/tables/sync_columns.dart';

void main() {
  test(
    'migration 5->6: existing location_points rows survive, new columns are null',
    () async {
      final raw = sqlite3.sqlite3.openInMemory();
      raw.execute('''
        CREATE TABLE "location_points" (
          "id" TEXT NOT NULL,
          "user_id" TEXT NULL,
          "device_id" TEXT NULL,
          "created_at" INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
          "updated_at" INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
          "deleted_at" INTEGER NULL,
          "local_rev" INTEGER NOT NULL DEFAULT 1,
          "server_rev" INTEGER NULL,
          "sync_state" TEXT NOT NULL DEFAULT 'localOnly',
          "source" TEXT NOT NULL,
          "latitude" REAL NOT NULL,
          "longitude" REAL NOT NULL,
          "altitude" REAL NULL,
          "horizontal_accuracy" REAL NULL,
          "vertical_accuracy" REAL NULL,
          "speed" REAL NULL,
          "heading" REAL NULL,
          "recorded_at" INTEGER NOT NULL,
          "battery_level" INTEGER NULL,
          "connectivity" TEXT NOT NULL DEFAULT 'unknown',
          "monitoring_mode" TEXT NOT NULL,
          PRIMARY KEY ("id")
        )
      ''');
      raw.execute('''
        INSERT INTO location_points
          (id, source, latitude, longitude, speed, recorded_at, monitoring_mode)
        VALUES
          ('pre-v6', 'location', 52.0, 13.0, 1.5, 1700000000, 'move')
      ''');
      raw.execute('PRAGMA user_version = 5');

      final db = AppDatabase.forTesting(NativeDatabase.opened(raw));
      final row = await (db.select(
        db.locationPoints,
      )..where((t) => t.id.equals('pre-v6'))).getSingle();

      expect(row.speed, 1.5);
      expect(row.speedAccuracy, isNull);
      expect(row.tripId, isNull);

      await db
          .into(db.locationPoints)
          .insert(
            LocationPointsCompanion.insert(
              latitude: 52.1,
              longitude: 13.1,
              speedAccuracy: const Value(0.8),
              tripId: const Value('trip-1'),
              recordedAt: DateTime.fromMillisecondsSinceEpoch(1700001000000),
              monitoringMode: MonitoringMode.move,
              source: RecordSource.location,
            ),
          );
      final newRow = await (db.select(
        db.locationPoints,
      )..where((t) => t.tripId.equals('trip-1'))).getSingle();
      expect(newRow.speedAccuracy, 0.8);

      await db.close();
    },
  );
}
