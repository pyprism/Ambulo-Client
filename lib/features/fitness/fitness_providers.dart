import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database_provider.dart';
import '../../data/local/tables/health_samples_table.dart';
import '../../data/repositories/fitness_stats_repository.dart';
import '../../data/repositories/health_sample_repository.dart';
import 'user_profile_controller.dart';

final fitnessStatsRepositoryProvider = Provider<FitnessStatsRepository>((ref) {
  return FitnessStatsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(userProfileProvider),
  );
});

final healthSampleRepositoryProvider = Provider<HealthSampleRepository>((ref) {
  return HealthSampleRepository(ref.watch(appDatabaseProvider));
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

final weeklyWeightProvider = FutureProvider<List<(DateTime, double)>>((ref) {
  final now = DateTime.now();
  return ref
      .watch(fitnessStatsRepositoryProvider)
      .weightHistory(now.subtract(const Duration(days: 6)), now);
});

final monthlyWeightProvider = FutureProvider<List<(DateTime, double)>>((ref) {
  final now = DateTime.now();
  return ref
      .watch(fitnessStatsRepositoryProvider)
      .weightHistory(now.subtract(const Duration(days: 29)), now);
});

/// Most recent weight/height readings — used to show a current value on the
/// Personal data settings screen without pulling in the whole history.
final latestWeightKgProvider = FutureProvider<double?>((ref) {
  return ref
      .watch(fitnessStatsRepositoryProvider)
      .latestSampleValue(HealthMetricType.weight);
});

final latestHeightCmProvider = FutureProvider<double?>((ref) {
  return ref
      .watch(fitnessStatsRepositoryProvider)
      .latestSampleValue(HealthMetricType.height);
});
