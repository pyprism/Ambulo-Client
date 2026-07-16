import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database.dart';
import '../../data/local/database_provider.dart';
import '../../data/local/tables/goals_table.dart';
import '../../data/local/tables/health_samples_table.dart';

final activeGoalsProvider = StreamProvider<List<Goal>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(
    db.goals,
  )..where((t) => t.isActive.equals(true) & t.deletedAt.isNull())).watch();
});

/// Reasonable defaults shown until the user sets their own goal — goal rings
/// need a target even before one is configured, so these are display
/// fallbacks, not persisted rows.
const defaultDailyGoals = {
  HealthMetricType.steps: 10000.0,
  HealthMetricType.activeMinutes: 30.0,
  HealthMetricType.distance: 5000.0,
  HealthMetricType.calories: 500.0,
};

double goalTargetFor(HealthMetricType metric, List<Goal> activeGoals) {
  final userGoal = activeGoals
      .where((g) => g.metricType == metric && g.period == GoalPeriod.daily)
      .toList();
  if (userGoal.isNotEmpty) return userGoal.first.targetValue;
  return defaultDailyGoals[metric] ?? 1;
}
