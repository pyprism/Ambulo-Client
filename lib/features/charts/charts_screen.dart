import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/repositories/fitness_stats_repository.dart';
import '../../shared/format/app_date_format.dart';
import '../../shared/widgets/empty_state.dart';
import '../fitness/fitness_providers.dart';

enum _ChartMetric { steps, distance, activeMinutes, calories, weight }

enum _ChartPeriod { week, month, custom }

// Health Connect (and any future import) predates any real user data by a
// wide margin — a generous lower bound for "how far back can you pick",
// matching HealthConnectRepository's own earliest-possible-date anchor.
final _earliestPickableDate = DateTime(2010);

class ChartsScreen extends ConsumerStatefulWidget {
  const ChartsScreen({super.key});

  @override
  ConsumerState<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends ConsumerState<ChartsScreen> {
  _ChartMetric _metric = _ChartMetric.steps;
  _ChartPeriod _period = _ChartPeriod.week;
  DateTimeRange? _customRange;
  final _chartKey = GlobalKey();
  bool _exporting = false;

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: _earliestPickableDate,
      lastDate: now,
      initialDateRange:
          _customRange ??
          DateTimeRange(start: now.subtract(const Duration(days: 6)), end: now),
    );
    if (picked == null) return;
    setState(() {
      _customRange = picked;
      _period = _ChartPeriod.custom;
    });
  }

  String get _metricLabel => switch (_metric) {
    _ChartMetric.steps => 'Steps',
    _ChartMetric.distance => 'Distance (km)',
    _ChartMetric.activeMinutes => 'Active minutes',
    _ChartMetric.calories => 'Calories (est.)',
    _ChartMetric.weight => 'Weight (kg)',
  };

  // Only called for the DailyStats-backed metrics — weight is handled
  // separately in build() since it isn't a daily rollup.
  double _valueFor(DailyStats day) => switch (_metric) {
    _ChartMetric.steps => day.steps.toDouble(),
    _ChartMetric.distance => day.distanceMeters / 1000,
    _ChartMetric.activeMinutes => day.activeMinutes.toDouble(),
    _ChartMetric.calories => day.calories,
    _ChartMetric.weight => throw StateError('handled in build()'),
  };

  @override
  Widget build(BuildContext context) {
    // Weight is a point-in-time reading, not a daily rollup — it comes
    // straight from HealthSample history rather than DailyStats, and
    // (unlike the other metrics) can have more than one reading a day.
    if (_metric == _ChartMetric.weight) {
      final weightHistory = switch (_period) {
        _ChartPeriod.week => ref.watch(weeklyWeightProvider),
        _ChartPeriod.month => ref.watch(monthlyWeightProvider),
        _ChartPeriod.custom => ref.watch(
          weightHistoryForRangeProvider(_customRange!),
        ),
      };
      return Scaffold(
        appBar: AppBar(title: const Text('Charts')),
        body: weightHistory.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => EmptyState(
            icon: Icons.error_outline,
            title: 'Could not load chart data',
            message: '$e',
          ),
          data: (points) => _buildContent(context, points),
        ),
      );
    }

    final stats = switch (_period) {
      _ChartPeriod.week => ref.watch(weeklyStatsProvider),
      _ChartPeriod.month => ref.watch(monthlyStatsProvider),
      _ChartPeriod.custom => ref.watch(statsForRangeProvider(_customRange!)),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Charts')),
      body: stats.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load chart data',
          message: '$e',
        ),
        data: (days) => _buildContent(context, [
          for (final day in days) (day.date, _valueFor(day)),
        ]),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<(DateTime, double)> points) {
    // Weight readings simply don't exist until logged — an empty list means
    // no data. The daily-rollup metrics always have one entry per day in
    // range, so "no data" instead shows up as every value being zero.
    final isEmpty = _metric == _ChartMetric.weight
        ? points.isEmpty
        : points.every((p) => p.$2 == 0);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SegmentedButton<_ChartMetric>(
              segments: const [
                ButtonSegment(value: _ChartMetric.steps, label: Text('Steps')),
                ButtonSegment(
                  value: _ChartMetric.distance,
                  label: Text('Distance'),
                ),
                ButtonSegment(
                  value: _ChartMetric.activeMinutes,
                  label: Text('Active min'),
                ),
                ButtonSegment(
                  value: _ChartMetric.calories,
                  label: Text('Calories'),
                ),
                ButtonSegment(
                  value: _ChartMetric.weight,
                  label: Text('Weight'),
                ),
              ],
              selected: {_metric},
              onSelectionChanged: (s) => setState(() => _metric = s.first),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SegmentedButton<_ChartPeriod>(
          segments: const [
            ButtonSegment(value: _ChartPeriod.week, label: Text('Week')),
            ButtonSegment(value: _ChartPeriod.month, label: Text('Month')),
            ButtonSegment(
              value: _ChartPeriod.custom,
              label: Text('Custom'),
              icon: Icon(Icons.date_range_outlined),
            ),
          ],
          selected: {_period},
          onSelectionChanged: (s) {
            if (s.first == _ChartPeriod.custom) {
              _pickCustomRange();
            } else {
              setState(() => _period = s.first);
            }
          },
        ),
        if (_period == _ChartPeriod.custom && _customRange != null) ...[
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickCustomRange,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${AppDateFormat.date(_customRange!.start)} – '
                  '${AppDateFormat.date(_customRange!.end)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 4),
                const Icon(Icons.edit_outlined, size: 16),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
            child: RepaintBoundary(
              key: _chartKey,
              child: SizedBox(
                height: 240,
                child: isEmpty
                    ? Center(
                        child: Text(
                          'No $_metricLabel data for this period yet',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : _TrendChart(
                        points: points,
                        zeroBaseline: _metric != _ChartMetric.weight,
                        color: Theme.of(context).colorScheme.primary,
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _exporting ? null : () => _exportPng(points),
                icon: const Icon(Icons.image_outlined),
                label: const Text('Export PNG'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _exporting ? null : () => _exportCsv(points),
                icon: const Icon(Icons.table_chart_outlined),
                label: const Text('Export CSV'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _exportPng(List<(DateTime, double)> points) async {
    setState(() => _exporting = true);
    try {
      final boundary =
          _chartKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 2.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              bytes,
              name: '${_metricFileName}_chart.png',
              mimeType: 'image/png',
            ),
          ],
          text: '$_metricLabel chart',
        ),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _exportCsv(List<(DateTime, double)> points) async {
    setState(() => _exporting = true);
    try {
      final dateFormat = _metric == _ChartMetric.weight
          ? DateFormat('yyyy-MM-dd HH:mm')
          : DateFormat('yyyy-MM-dd');
      final rows = <List<dynamic>>[
        ['date', _metricLabel],
        for (final point in points) [dateFormat.format(point.$1), point.$2],
      ];
      final csv = Csv().encode(rows);
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              Uint8List.fromList(csv.codeUnits),
              name: '${_metricFileName}_data.csv',
              mimeType: 'text/csv',
            ),
          ],
          text: '$_metricLabel data',
        ),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  String get _metricFileName => switch (_metric) {
    _ChartMetric.steps => 'steps',
    _ChartMetric.distance => 'distance',
    _ChartMetric.activeMinutes => 'active_minutes',
    _ChartMetric.calories => 'calories',
    _ChartMetric.weight => 'weight',
  };
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({
    required this.points,
    required this.zeroBaseline,
    required this.color,
  });

  final List<(DateTime, double)> points;

  /// True for count-like metrics (steps, calories, ...) where zero is a
  /// meaningful baseline. False for weight, which has no natural zero and
  /// reads better as a tight range around the actual readings.
  final bool zeroBaseline;

  final Color color;

  @override
  Widget build(BuildContext context) {
    final spots = [
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].$2),
    ];
    final values = spots.map((s) => s.y);
    final maxY = values.fold<double>(0, (a, b) => a > b ? a : b);
    final minY = zeroBaseline
        ? 0.0
        : values.fold<double>(maxY, (a, b) => a < b ? a : b);
    final step = (points.length / 5).ceil().clamp(1, points.length);

    return LineChart(
      LineChartData(
        minY: zeroBaseline
            ? 0
            : (minY == maxY ? minY - 1 : minY - (maxY - minY) * 0.1),
        maxY: maxY == 0
            ? 1
            : (zeroBaseline ? maxY * 1.2 : maxY + (maxY - minY) * 0.1),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: step.toDouble(),
              getTitlesWidget: (value, meta) {
                final index = value.round();
                if (index < 0 || index >= points.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    AppDateFormat.shortAxisDate(points[index].$1),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
}
