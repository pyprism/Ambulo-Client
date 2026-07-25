import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ambulo/data/local/database.dart';
import 'package:ambulo/data/local/tables/activity_samples_table.dart';
import 'package:ambulo/data/local/tables/places_table.dart';
import 'package:ambulo/data/local/tables/sync_columns.dart';
import 'package:ambulo/data/repositories/activity_sample_repository.dart';
import 'package:ambulo/data/repositories/note_repository.dart';
import 'package:ambulo/data/repositories/place_repository.dart';
import 'package:ambulo/data/repositories/workout_session_repository.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test(
    'NoteRepository preserves unspecified fields and soft-deletes notes',
    () async {
      final repository = NoteRepository(db);
      final date = DateTime.utc(2026, 7, 25);
      await repository.addNote(
        content: 'Original',
        noteDate: date,
        context: 'morning walk',
      );
      final original = (await db.select(db.notes).get()).single;

      await repository.updateNote(original.id, content: 'Edited');
      final edited = (await db.select(db.notes).get()).single;
      expect(edited.content, 'Edited');
      expect(edited.noteDate.toUtc(), date);
      expect(edited.context, 'morning walk');
      expect(edited.localRev, 2);
      expect(edited.syncState, SyncState.pendingUpload);

      await repository.deleteNote(edited.id);
      final deleted = (await db.select(db.notes).get()).single;
      expect(deleted.deletedAt, isNotNull);
      expect(deleted.localRev, 3);
    },
  );

  test(
    'WorkoutSessionRepository updates nullable fields and soft-deletes',
    () async {
      final repository = WorkoutSessionRepository(db);
      final start = DateTime.utc(2026, 7, 25, 8);
      await repository.addWorkout(
        activityType: ActivityType.running,
        startedAt: start,
        endedAt: start.add(const Duration(minutes: 30)),
        distanceMeters: 5000,
        calories: 400,
        notes: 'tempo',
      );
      final original = (await db.select(db.workoutSessions).get()).single;

      await repository.updateWorkout(
        original.id,
        activityType: ActivityType.cycling,
        endedAt: const Value(null),
        distanceMeters: const Value(null),
        calories: const Value(250),
      );
      final edited = (await db.select(db.workoutSessions).get()).single;
      expect(edited.activityType, ActivityType.cycling);
      expect(edited.endedAt, isNull);
      expect(edited.distanceMeters, isNull);
      expect(edited.calories, 250);
      expect(edited.notes, 'tempo');
      expect(edited.localRev, 2);

      await repository.deleteWorkout(edited.id);
      expect(
        (await db.select(db.workoutSessions).get()).single.deletedAt,
        isNotNull,
      );
    },
  );

  test(
    'ActivitySampleRepository reclassifies and soft-deletes samples',
    () async {
      final start = DateTime.utc(2026, 7, 25, 8);
      await db
          .into(db.activitySamples)
          .insert(
            ActivitySamplesCompanion.insert(
              activityType: ActivityType.walking,
              startedAt: start,
              source: RecordSource.motion,
            ),
          );
      final original = (await db.select(db.activitySamples).get()).single;
      final repository = ActivitySampleRepository(db);

      await repository.updateActivityType(original.id, ActivityType.running);
      final updated = (await db.select(db.activitySamples).get()).single;
      expect(updated.activityType, ActivityType.running);
      expect(updated.localRev, 2);
      expect(updated.syncState, SyncState.pendingUpload);

      await repository.deleteActivitySample(updated.id);
      expect(
        (await db.select(db.activitySamples).get()).single.deletedAt,
        isNotNull,
      );
    },
  );

  test(
    'PlaceRepository returns only active places after update and deletion',
    () async {
      final repository = PlaceRepository(db);
      await repository.addPlace(
        name: 'Home',
        category: PlaceCategory.home,
        latitude: 51.5,
        longitude: -0.12,
        radiusMeters: 100,
      );
      await repository.addPlace(
        name: 'Office',
        category: PlaceCategory.work,
        latitude: 51.51,
        longitude: -0.13,
        radiusMeters: 50,
      );
      final places = await repository.activePlaces();
      final home = places.firstWhere((place) => place.name == 'Home');

      await repository.updatePlace(
        home.id,
        name: 'New home',
        radiusMeters: 150,
        notifyFriends: true,
      );
      final updated = (await repository.activePlaces()).firstWhere(
        (place) => place.id == home.id,
      );
      expect(updated.name, 'New home');
      expect(updated.radiusMeters, 150);
      expect(updated.notifyFriends, isTrue);
      expect(updated.localRev, 2);

      await repository.deletePlace(updated.id);
      expect(await repository.activePlaces(), hasLength(1));
      expect(
        (await db.select(db.places).get()).where((p) => p.deletedAt != null),
        hasLength(1),
      );
    },
  );
}
