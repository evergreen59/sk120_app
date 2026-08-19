import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme.dart';
import '../../application/providers.dart';
import '../../domain/models/device_models.dart';
import '../../shared/responsive/responsive.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/metric_card.dart';

enum _ChartWindow { live, oneMinute, fiveMinutes, tenMinutes }

class MonitoringPage extends ConsumerStatefulWidget {
  const MonitoringPage({super.key});

  @override
  ConsumerState<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends ConsumerState<MonitoringPage> {
  _ChartWindow _window = _ChartWindow.live;
  bool _paused = false;
  final List<MeasurementSample> _pausedSamples = [];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deviceStateProvider);
    final status = state.status;
    final samples = _filteredSamples(_paused ? _pausedSamples : state.samples);
    return Scaffold(
      body: SafeArea(
        child: ResponsiveContent(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
            children: [
              SectionTitle(
                title: 'Real-time Monitor',
                subtitle: status.isConnected
                    ? 'Live telemetry · 2 s sampling'
                    : 'Connect a device to begin sampling',
                action: TextButton.icon(
                  onPressed: () => context.push('/monitor/history'),
                  icon: const Icon(Icons.history_rounded, size: 17),
                  label: const Text('View History'),
                ),
              ),
              const SizedBox(height: 20),
              _MetricGrid(status: status),
              const SizedBox(height: 18),
              GlassCard(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '输出曲线',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        IconButton(
                          tooltip: _paused ? '继续' : '暂停',
                          onPressed: () {
                            setState(() {
                              _paused = !_paused;
                              if (_paused) {
                                _pausedSamples
                                  ..clear()
                                  ..addAll(_filteredSamples(state.samples));
                              }
                            });
                          },
                          icon: Icon(
                            _paused
                                ? Icons.play_arrow_rounded
                                : Icons.pause_rounded,
                          ),
                        ),
                        IconButton(
                          tooltip: '清空曲线',
                          onPressed: () => setState(() {
                            if (_paused) {
                              _pausedSamples.clear();
                            } else {
                              ref
                                  .read(deviceStateProvider.notifier)
                                  .clearSamples();
                            }
                          }),
                          icon: const Icon(Icons.delete_sweep_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GlassSegmentedControl<_ChartWindow>(
                      items: const [
                        (_ChartWindow.live, 'Real-time'),
                        (_ChartWindow.oneMinute, '1m'),
                        (_ChartWindow.fiveMinutes, '5m'),
                        (_ChartWindow.tenMinutes, '10m'),
                      ],
                      value: _window,
                      onChanged: (next) => setState(() => _window = next),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 260,
                      child: _OutputChart(samples: samples),
                    ),
                    const SizedBox(height: 8),
                    const Wrap(
                      spacing: 16,
                      runSpacing: 6,
                      children: [
                        _Legend(color: AppColors.electricBlue, label: '电压 V'),
                        _Legend(color: AppColors.cyan, label: '电流 A × 10'),
                        _Legend(color: AppColors.amber, label: '功率 W'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _DetailTable(status: status),
            ],
          ),
        ),
      ),
    );
  }

  List<MeasurementSample> _filteredSamples(List<MeasurementSample> samples) {
    final now = DateTime.now();
    final duration = switch (_window) {
      _ChartWindow.live => const Duration(seconds: 30),
      _ChartWindow.oneMinute => const Duration(minutes: 1),
      _ChartWindow.fiveMinutes => const Duration(minutes: 5),
      _ChartWindow.tenMinutes => const Duration(minutes: 10),
    };
    return samples
        .where((sample) => now.difference(sample.timestamp) <= duration)
        .toList();
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.status});

  final DeviceStatus status;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth > 1050
          ? 5
          : constraints.maxWidth > 650
          ? 3
          : 2;
      final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          SizedBox(
            width: width,
            child: MetricCard(
              label: 'VOUT',
              value: _number(status.outputVoltage, 3),
              unit: 'V',
              icon: Icons.trending_up_rounded,
              accent: AppColors.electricBlue,
            ),
          ),
          SizedBox(
            width: width,
            child: MetricCard(
              label: 'IOUT',
              value: _number(status.outputCurrent, 3),
              unit: 'A',
              icon: Icons.bolt_rounded,
              accent: AppColors.cyan,
            ),
          ),
          SizedBox(
            width: width,
            child: MetricCard(
              label: 'POWER',
              value: _number(status.outputPower, 2),
              unit: 'W',
              icon: Icons.flash_on_rounded,
              accent: AppColors.amber,
            ),
          ),
          SizedBox(
            width: width,
            child: MetricCard(
              label: '温度',
              value: _number(status.internalTemperature, 1),
              unit: 'F/C',
              icon: Icons.thermostat_outlined,
              accent: AppColors.red,
            ),
          ),
          SizedBox(
            width: width,
            child: MetricCard(
              label: '输入',
              value: _number(status.inputVoltage, 1),
              unit: 'V',
              icon: Icons.power_rounded,
              accent: AppColors.green,
            ),
          ),
        ],
      );
    },
  );
}

class _OutputChart extends StatelessWidget {
  const _OutputChart({required this.samples});

  final List<MeasurementSample> samples;

  @override
  Widget build(BuildContext context) {
    if (samples.length < 2) {
      return Center(
        child: Text('等待采样数据…', style: Theme.of(context).textTheme.bodyMedium),
      );
    }
    final origin = samples.first.timestamp;
    final powerSpots = samples
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.power ?? 0))
        .toList();
    final voltageSpots = samples
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.voltage ?? 0))
        .toList();
    final currentSpots = samples
        .asMap()
        .entries
        .map(
          (entry) =>
              FlSpot(entry.key.toDouble(), (entry.value.current ?? 0) * 10),
        )
        .toList();
    final allSpots = [...powerSpots, ...voltageSpots, ...currentSpots];
    final maxY =
        allSpots
            .map((spot) => spot.y)
            .fold<double>(1, (max, value) => value > max ? value : max) *
        1.2;
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: powerSpots.last.x,
        minY: 0,
        maxY: maxY,
        gridData: const FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(0),
                style: const TextStyle(color: AppColors.dim, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final index = value.round();
                if (index < 0 || index >= samples.length || index % 2 != 0) {
                  return const SizedBox.shrink();
                }
                final time = origin.add(
                  samples[index].timestamp.difference(origin),
                );
                return Text(
                  '${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: AppColors.dim, fontSize: 9),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots
                .map(
                  (spot) => LineTooltipItem(
                    spot.y.toStringAsFixed(2),
                    const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: voltageSpots,
            isCurved: true,
            color: AppColors.electricBlue,
            barWidth: 2.2,
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: currentSpots,
            isCurved: true,
            color: AppColors.cyan,
            barWidth: 2.2,
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: powerSpots,
            isCurved: true,
            color: AppColors.amber,
            barWidth: 2.4,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.amber.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 250),
      transformationConfig: const FlTransformationConfig(
        scaleAxis: FlScaleAxis.horizontal,
        minScale: 1,
        maxScale: 4,
        panEnabled: true,
        scaleEnabled: true,
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
      ),
    ],
  );
}

class _DetailTable extends StatelessWidget {
  const _DetailTable({required this.status});

  final DeviceStatus status;

  @override
  Widget build(BuildContext context) => GlassCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('采集详情', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        _row(context, 'CV / CC', _cvcc(status.cvccState)),
        _row(context, '保护状态', status.protectionLabel),
        _row(
          context,
          'AH / WH',
          '${status.outputAh ?? '--'} mAh  /  ${status.outputWh ?? '--'} mWh',
        ),
        _row(
          context,
          '输出时长',
          '${status.outputDuration.inHours} h ${(status.outputDuration.inMinutes % 60).toString().padLeft(2, '0')} min ${(status.outputDuration.inSeconds % 60).toString().padLeft(2, '0')} s',
        ),
      ],
    ),
  );

  Widget _row(BuildContext context, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    ),
  );
}

String _number(double? value, int digits) =>
    value == null ? '--' : value.toStringAsFixed(digits);
String _cvcc(CvccState state) => switch (state) {
  CvccState.cv => 'CV',
  CvccState.cc => 'CC',
  CvccState.unknown => '未知',
};
