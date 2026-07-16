import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/local/tables/health_samples_table.dart';
import '../../data/local/tables/location_points_table.dart';
import '../../data/repositories/fitness_stats_repository.dart';
import '../../platform/platform_support.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/goal_ring.dart';
import '../fitness/fitness_providers.dart';
import '../fitness/goals_provider.dart';
import '../tracking/monitoring_mode_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayStatsProvider);
    final weekly = ref.watch(weeklyStatsProvider);
    final activeGoals = ref.watch(activeGoalsProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: today.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load dashboard',
          message: '$e',
        ),
        data: (stats) {
          final hasAnyData =
              stats.steps > 0 ||
              stats.distanceMeters > 0 ||
              stats.activeMinutes > 0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (!hasAnyData)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: EmptyState(
                    icon: Icons.dashboard_outlined,
                    title: 'No activity yet today',
                    message:
                        'Steps, distance, active minutes, and calories will '
                        'appear here once tracking starts.',
                  ),
                ),
              _SectionHeader('Today'),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 700 ? 4 : 2;
                  return GridView.count(
                    crossAxisCount: columns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.6,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _StatCard(
                        icon: Icons.directions_walk,
                        label: 'Steps',
                        value: '${stats.steps}',
                        color: AppColors.darkGreen,
                      ),
                      _StatCard(
                        icon: Icons.straighten,
                        label: 'Distance',
                        value:
                            '${(stats.distanceMeters / 1000).toStringAsFixed(2)} km',
                        color: AppColors.darkBlue,
                      ),
                      _StatCard(
                        icon: Icons.timer_outlined,
                        label: 'Active minutes',
                        value: '${stats.activeMinutes} min',
                        color: AppColors.darkPink,
                      ),
                      _StatCard(
                        icon: Icons.local_fire_department_outlined,
                        label: 'Calories (est.)',
                        value: '${stats.calories.round()} kcal',
                        color: AppColors.darkGreen,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              _SectionHeader('Goals'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 24,
                    runSpacing: 16,
                    alignment: WrapAlignment.spaceEvenly,
                    children: [
                      GoalRing(
                        label: 'Steps',
                        value: stats.steps.toDouble(),
                        target: goalTargetFor(
                          HealthMetricType.steps,
                          activeGoals,
                        ),
                        valueLabel: '${stats.steps}',
                        color: AppColors.darkGreen,
                      ),
                      GoalRing(
                        label: 'Active min',
                        value: stats.activeMinutes.toDouble(),
                        target: goalTargetFor(
                          HealthMetricType.activeMinutes,
                          activeGoals,
                        ),
                        valueLabel: '${stats.activeMinutes}',
                        color: AppColors.darkPink,
                      ),
                      GoalRing(
                        label: 'Distance (m)',
                        value: stats.distanceMeters,
                        target: goalTargetFor(
                          HealthMetricType.distance,
                          activeGoals,
                        ),
                        valueLabel:
                            '${(stats.distanceMeters / 1000).toStringAsFixed(1)}km',
                        color: AppColors.darkBlue,
                      ),
                      GoalRing(
                        label: 'Calories',
                        value: stats.calories,
                        target: goalTargetFor(
                          HealthMetricType.calories,
                          activeGoals,
                        ),
                        valueLabel: '${stats.calories.round()}',
                        color: AppColors.darkGreen,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _SectionHeader('This week'),
              weekly.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Could not load weekly trend: $e'),
                data: (days) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _WeeklyTrendRow(days: days),
                  ),
                ),
              ),
              if (PlatformSupport.supportsSensorCollection) ...[
                const SizedBox(height: 24),
                _SectionHeader('Battery impact'),
                const Card(child: _BatteryImpactTile()),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyTrendRow extends StatelessWidget {
  const _WeeklyTrendRow({required this.days});

  final List<DailyStats> days;

  @override
  Widget build(BuildContext context) {
    if (days.every((d) => d.steps == 0)) {
      return Text(
        'No steps recorded this week yet.',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    final maxSteps = days.map((d) => d.steps).reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: 96,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final day in days)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      day.steps > 0 ? '${day.steps}' : '',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: maxSteps == 0
                          ? 4
                          : 4 + (day.steps / maxSteps) * 56,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _weekdayLabel(day.date),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _weekdayLabel(DateTime date) =>
      const ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'][date.weekday - 1];
}

class _BatteryImpactTile extends ConsumerWidget {
  const _BatteryImpactTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(monitoringModeProvider);
    final (icon, impact, description) = switch (mode) {
      MonitoringMode.quit => (
        Icons.battery_full,
        'None',
        'Tracking is off — no battery impact.',
      ),
      MonitoringMode.manual => (
        Icons.battery_full,
        'Minimal',
        'Only uses power when you explicitly record something.',
      ),
      MonitoringMode.significant => (
        Icons.battery_5_bar,
        'Low',
        'Coarse, low-power location updates only.',
      ),
      MonitoringMode.move => (
        Icons.battery_2_bar,
        'High',
        'Precise tracking with a foreground service — uses more battery.',
      ),
    };

    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text('$impact impact — ${_modeLabel(mode)} mode'),
      subtitle: Text(description),
    );
  }

  String _modeLabel(MonitoringMode mode) => switch (mode) {
    MonitoringMode.quit => 'Quit',
    MonitoringMode.manual => 'Manual',
    MonitoringMode.significant => 'Significant',
    MonitoringMode.move => 'Move',
  };
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}
