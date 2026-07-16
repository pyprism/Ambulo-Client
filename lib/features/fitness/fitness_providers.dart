import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database_provider.dart';
import '../../data/repositories/fitness_stats_repository.dart';

final fitnessStatsRepositoryProvider = Provider<FitnessStatsRepository>((ref) {
  return FitnessStatsRepository(ref.watch(appDatabaseProvider));
});

final todayStatsProvider = FutureProvider<DailyStats>((ref) {
  return ref.watch(fitnessStatsRepositoryProvider).statsForDay(DateTime.now());
});

final weeklyStatsProvider = FutureProvider<List<DailyStats>>((ref) {
  final now = DateTime.now();
  return ref
      .watch(fitnessStatsRepositoryProvider)
      .statsForRange(now.subtract(const Duration(days: 6)), now);
});

final monthlyStatsProvider = FutureProvider<List<DailyStats>>((ref) {
  final now = DateTime.now();
  return ref
      .watch(fitnessStatsRepositoryProvider)
      .statsForRange(now.subtract(const Duration(days: 29)), now);
});
