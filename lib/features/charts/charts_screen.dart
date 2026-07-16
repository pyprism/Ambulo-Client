import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/repositories/fitness_stats_repository.dart';
import '../../shared/widgets/empty_state.dart';
import '../fitness/fitness_providers.dart';

enum _ChartMetric { steps, distance, activeMinutes, calories }

enum _ChartPeriod { week, month }

class ChartsScreen extends ConsumerStatefulWidget {
  const ChartsScreen({super.key});

  @override
  ConsumerState<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends ConsumerState<ChartsScreen> {
  _ChartMetric _metric = _ChartMetric.steps;
  _ChartPeriod _period = _ChartPeriod.week;
  final _chartKey = GlobalKey();
  bool _exporting = false;

  String get _metricLabel => switch (_metric) {
    _ChartMetric.steps => 'Steps',
    _ChartMetric.distance => 'Distance (km)',
    _ChartMetric.activeMinutes => 'Active minutes',
    _ChartMetric.calories => 'Calories (est.)',
  };

  double _valueFor(DailyStats day) => switch (_metric) {
    _ChartMetric.steps => day.steps.toDouble(),
    _ChartMetric.distance => day.distanceMeters / 1000,
    _ChartMetric.activeMinutes => day.activeMinutes.toDouble(),
    _ChartMetric.calories => day.calories,
  };

  @override
  Widget build(BuildContext context) {
    final stats = _period == _ChartPeriod.week
        ? ref.watch(weeklyStatsProvider)
        : ref.watch(monthlyStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Charts')),
      body: stats.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load chart data',
          message: '$e',
        ),
        data: (days) => _buildContent(context, days),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<DailyStats> days) {
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
          ],
          selected: {_period},
          onSelectionChanged: (s) => setState(() => _period = s.first),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
            child: RepaintBoundary(
              key: _chartKey,
              child: SizedBox(
                height: 240,
                child: days.every((d) => _valueFor(d) == 0)
                    ? Center(
                        child: Text(
                          'No $_metricLabel data for this period yet',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : _TrendChart(
                        days: days,
                        valueOf: _valueFor,
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
                onPressed: _exporting ? null : () => _exportPng(days),
                icon: const Icon(Icons.image_outlined),
                label: const Text('Export PNG'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _exporting ? null : () => _exportCsv(days),
                icon: const Icon(Icons.table_chart_outlined),
                label: const Text('Export CSV'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _exportPng(List<DailyStats> days) async {
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
      final file = await _writeTempFile('${_metricFileName}_chart.png', bytes);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: '$_metricLabel chart'),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _exportCsv(List<DailyStats> days) async {
    setState(() => _exporting = true);
    try {
      final rows = <List<dynamic>>[
        ['date', _metricLabel],
        for (final day in days)
          [DateFormat('yyyy-MM-dd').format(day.date), _valueFor(day)],
      ];
      final csv = Csv().encode(rows);
      final file = await _writeTempFile(
        '${_metricFileName}_data.csv',
        Uint8List.fromList(csv.codeUnits),
      );
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: '$_metricLabel data'),
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
  };

  Future<File> _writeTempFile(String name, Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({
    required this.days,
    required this.valueOf,
    required this.color,
  });

  final List<DailyStats> days;
  final double Function(DailyStats) valueOf;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final spots = [
      for (var i = 0; i < days.length; i++)
        FlSpot(i.toDouble(), valueOf(days[i])),
    ];
    final maxY = spots.map((s) => s.y).fold<double>(0, (a, b) => a > b ? a : b);
    final step = (days.length / 5).ceil().clamp(1, days.length);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY == 0 ? 1 : maxY * 1.2,
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
                if (index < 0 || index >= days.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('M/d').format(days[index].date),
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
