import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database.dart';
import '../../data/local/database_provider.dart';
import '../../data/repositories/place_repository.dart';

final placeRepositoryProvider = Provider<PlaceRepository>((ref) {
  return PlaceRepository(ref.watch(appDatabaseProvider));
});

final placesProvider = StreamProvider<List<Place>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.places)..where((t) => t.deletedAt.isNull())).watch();
});
