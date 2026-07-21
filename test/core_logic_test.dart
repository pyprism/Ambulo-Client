import 'package:flutter_test/flutter_test.dart';

import 'package:ambulo/data/local/sync_mutation.dart';
import 'package:ambulo/data/local/sync_wire.dart';
import 'package:ambulo/data/local/tables/activity_samples_table.dart';
import 'package:ambulo/data/local/tables/health_samples_table.dart';
import 'package:ambulo/data/local/tables/sync_columns.dart';
import 'package:ambulo/platform/location/activity_classifier.dart';
import 'package:ambulo/platform/location/geo_math.dart';

void main() {
  group('haversineMeters', () {
    test('returns zero for identical coordinates', () {
      expect(haversineMeters(51.5, -0.12, 51.5, -0.12), 0);
    });

    test('calculates a known distance and is symmetric', () {
      final londonToParis = haversineMeters(51.5074, -0.1278, 48.8566, 2.3522);
      final parisToLondon = haversineMeters(48.8566, 2.3522, 51.5074, -0.1278);

      expect(londonToParis, closeTo(343556, 1000));
      expect(parisToLondon, closeTo(londonToParis, 0.0001));
    });
  });

  group('classifySpeed', () {
    test('classifies each speed band, including exact boundaries', () {
      expect(classifySpeed(null), ActivityType.unknown);
      expect(classifySpeed(0.29), ActivityType.still);
      expect(classifySpeed(0.3), ActivityType.walking);
      expect(classifySpeed(2), ActivityType.running);
      expect(classifySpeed(4), ActivityType.cycling);
      expect(classifySpeed(8), ActivityType.vehicle);
    });

    test('does not classify speed when GPS accuracy is unusable', () {
      expect(classifySpeed(3, horizontalAccuracy: 0), ActivityType.unknown);
      expect(classifySpeed(3, horizontalAccuracy: 25.01), ActivityType.unknown);
      expect(classifySpeed(3, horizontalAccuracy: 25), ActivityType.running);
    });
  });

  group('sync wire mappings', () {
    test('round-trips every sync state', () {
      for (final state in SyncState.values) {
        expect(syncStateFromWire(syncStateToWire(state)), state);
      }
    });

    test('round-trips every health metric type', () {
      for (final type in HealthMetricType.values) {
        expect(healthMetricTypeFromWire(healthMetricTypeToWire(type)), type);
      }
    });

    test('maps unknown wire values to safe fallback values', () {
      expect(syncStateFromWire('future_state'), SyncState.failed);
      expect(
        healthMetricTypeFromWire('future_metric'),
        HealthMetricType.custom,
      );
    });
  });

  test('SyncBump advances the revision and queues the row for upload', () {
    final bump = SyncBump(41);

    expect(bump.localRev.value, 42);
    expect(bump.syncState.value, SyncState.pendingUpload);
    expect(bump.updatedAt.value, isA<DateTime>());
  });
}
