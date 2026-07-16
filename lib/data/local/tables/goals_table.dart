import 'package:drift/drift.dart';

import 'health_samples_table.dart';
import 'sync_columns.dart';

/// Mirrors server `utils.enums.GoalPeriod`.
enum GoalPeriod { daily, weekly, monthly, custom }

class Goals extends Table with SyncableColumns {
  TextColumn get metricType => textEnum<HealthMetricType>()();
  RealColumn get targetValue => real()();
  TextColumn get period =>
      textEnum<GoalPeriod>().withDefault(const Constant('daily'))();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}
