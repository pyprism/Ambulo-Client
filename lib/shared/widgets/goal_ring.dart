import 'package:flutter/material.dart';

/// A goal-progress ring: current value vs target, with a label underneath.
/// Used on the dashboard for steps/active-minutes/distance/calories.
class GoalRing extends StatelessWidget {
  const GoalRing({
    super.key,
    required this.label,
    required this.value,
    required this.target,
    required this.valueLabel,
    required this.color,
  });

  final String label;
  final double value;
  final double target;
  final String valueLabel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = target <= 0 ? 0.0 : (value / target).clamp(0.0, 1.0);
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 76,
          height: 76,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 76,
                height: 76,
                child: CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 7,
                  color: theme.colorScheme.outline.withValues(alpha: 0.15),
                ),
              ),
              SizedBox(
                width: 76,
                height: 76,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 7,
                  color: color,
                  backgroundColor: Colors.transparent,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: theme.textTheme.labelLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(valueLabel, style: theme.textTheme.titleSmall),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}
