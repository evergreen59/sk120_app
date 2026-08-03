import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../application/providers.dart';
import '../../domain/models/device_models.dart';
import '../../shared/responsive/responsive.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/metric_card.dart';
import '../../shared/widgets/number_input_dialog.dart';

class ControlPage extends ConsumerWidget {
  const ControlPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deviceStateProvider);
    final notifier = ref.read(deviceStateProvider.notifier);
    final size = screenSizeOf(context);
    return Scaffold(
      body: SafeArea(
        child: ResponsiveContent(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  size == ScreenSize.mobile ? 16 : 28,
                  22,
                  size == ScreenSize.mobile ? 16 : 28,
                  24,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _PageHeader(status: state.status, mode: state.mode),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 14),
                      _ErrorBanner(
                        message: state.errorMessage!,
                        onDismiss: notifier.clearError,
                      ),
                    ],
                    const SizedBox(height: 22),
                    if (!state.status.isConnected)
                      _DisconnectedPanel(state: state)
                    else
                      _ConnectedDashboard(state: state, size: size),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.status, required this.mode});

  final DeviceStatus status;
  final DeviceMode mode;

  @override
  Widget build(BuildContext context) {
    final connected = status.isConnected;
    final color = connected
        ? AppColors.green
        : status.connectionState == DeviceConnectionState.error
        ? AppColors.red
        : AppColors.amber;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('控制台', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 5),
              Text(
                mode == DeviceMode.mock
                    ? '演示设备 · XY-SK120 Demo'
                    : 'XY-SK120 · 实时设备控制',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        StatusBadge(
          label: connected ? '已连接' : _connectionLabel(status.connectionState),
          color: color,
          icon: connected ? Icons.check_circle : Icons.circle,
        ),
      ],
    );
  }

  String _connectionLabel(DeviceConnectionState state) => switch (state) {
    DeviceConnectionState.scanning => '扫描中',
    DeviceConnectionState.connecting => '连接中',
    DeviceConnectionState.reconnecting => '重连中',
    DeviceConnectionState.error => '连接错误',
    _ => '未连接',
  };
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    decoration: BoxDecoration(
      color: AppColors.red.withValues(alpha: 0.1),
      borderRadius: AppRadius.small,
      border: Border.all(color: AppColors.red.withValues(alpha: 0.35)),
    ),
    child: Row(
      children: [
        const Icon(Icons.warning_amber_rounded, color: AppColors.red, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(message, style: const TextStyle(color: AppColors.text)),
        ),
        IconButton(
          tooltip: '关闭提示',
          onPressed: onDismiss,
          icon: const Icon(Icons.close, size: 18),
        ),
      ],
    ),
  );
}

class _DisconnectedPanel extends ConsumerWidget {
  const _DisconnectedPanel({required this.state});

  final DeviceUiState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(deviceStateProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.electricBlue.withValues(alpha: 0.13),
                      borderRadius: AppRadius.medium,
                    ),
                    child: const Icon(
                      Icons.bluetooth_searching_rounded,
                      color: AppColors.electricBlue,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '发现设备',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '连接 XY-SK120 后即可读取状态和控制输出。',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  if (state.scanning)
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: state.scanning
                        ? notifier.stopScan
                        : notifier.startScan,
                    icon: Icon(
                      state.scanning ? Icons.stop_rounded : Icons.radar_rounded,
                    ),
                    label: Text(state.scanning ? '停止扫描' : '开始扫描'),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () => ref
                        .read(appModeProvider.notifier)
                        .setMode(DeviceMode.mock),
                    icon: const Icon(Icons.science_outlined),
                    label: const Text('启用演示模式'),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (state.discoveredDevices.isNotEmpty) ...[
          const SizedBox(height: 18),
          SectionTitle(
            title: '附近设备',
            subtitle: '${state.discoveredDevices.length} 个设备',
          ),
          const SizedBox(height: 10),
          ...state.discoveredDevices.map(
            (device) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _DeviceRow(
                device: device,
                isFavorite: state.favoriteDeviceIds.contains(device.id),
                onFavorite: () => notifier.toggleFavoriteDevice(device.id),
                onConnect: () => notifier.connect(deviceId: device.id),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _DeviceRow extends StatelessWidget {
  const _DeviceRow({
    required this.device,
    required this.isFavorite,
    required this.onFavorite,
    required this.onConnect,
  });

  final BleDeviceInfo device;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) => GlassCard(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    child: Row(
      children: [
        const Icon(Icons.bluetooth, color: AppColors.cyan, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(device.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 3),
              Text(
                '${device.id}  ·  RSSI ${device.rssi ?? '--'} dBm',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onFavorite,
          tooltip: isFavorite ? '取消收藏' : '收藏设备',
          color: isFavorite ? AppColors.amber : AppColors.muted,
          icon: Icon(
            isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
          ),
        ),
        IconButton.filledTonal(
          onPressed: onConnect,
          tooltip: '连接设备',
          icon: const Icon(Icons.link_rounded),
        ),
      ],
    ),
  );
}

class _ConnectedDashboard extends ConsumerWidget {
  const _ConnectedDashboard({required this.state, required this.size});

  final DeviceUiState state;
  final ScreenSize size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(deviceStateProvider.notifier);
    final status = state.status;
    final main = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PowerReadout(status: status),
        const SizedBox(height: 14),
        _SetpointPanel(
          status: status,
          onVoltage: (value) => notifier.setVoltage(value),
          onCurrent: (value) => notifier.setCurrent(value),
        ),
        const SizedBox(height: 14),
        _QuickPresetPanel(
          onApply: (voltage, current) async {
            await notifier.setVoltage(voltage);
            await notifier.setCurrent(current);
          },
        ),
        const SizedBox(height: 14),
        _OutputPanel(
          status: status,
          busy: state.busy,
          onToggle: () async {
            if (status.outputState == OutputState.unknown) {
              await notifier.refresh();
              return;
            }
            final enabling = status.outputState == OutputState.off;
            if (enabling) {
              final confirmed = await _confirmOutput(context, status);
              if (!confirmed) return;
            }
            await notifier.setOutput(enabling);
          },
          onRefresh: notifier.refresh,
        ),
      ],
    );
    final side = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: '设备状态',
          subtitle: '最近更新 ${_timeLabel(status.lastUpdated)}',
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            MetricCard(
              label: '输入电压',
              value: _number(status.inputVoltage, 1),
              unit: 'V',
              icon: Icons.input_rounded,
              accent: AppColors.cyan,
            ),
            MetricCard(
              label: '内部温度',
              value: _number(status.internalTemperature, 1),
              unit: 'F/C',
              icon: Icons.thermostat_outlined,
              accent: AppColors.amber,
            ),
            MetricCard(
              label: '输出 AH',
              value: status.outputAh?.toString() ?? '--',
              unit: 'mAh',
              icon: Icons.battery_charging_full_rounded,
              accent: AppColors.green,
            ),
            MetricCard(
              label: '输出 WH',
              value: status.outputWh?.toString() ?? '--',
              unit: 'mWh',
              icon: Icons.energy_savings_leaf_outlined,
              accent: AppColors.electricBlue,
            ),
          ],
        ),
        const SizedBox(height: 14),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('运行模式', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              _InfoLine(label: 'CV / CC', value: _cvccLabel(status.cvccState)),
              _InfoLine(label: '保护状态', value: status.protectionLabel),
              _InfoLine(label: '输出时长', value: _duration(status.outputDuration)),
            ],
          ),
        ),
      ],
    );
    if (size == ScreenSize.mobile) return main;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: main),
        const SizedBox(width: 18),
        Expanded(flex: 2, child: side),
      ],
    );
  }
}

class _PowerReadout extends StatelessWidget {
  const _PowerReadout({required this.status});

  final DeviceStatus status;

  @override
  Widget build(BuildContext context) => GlassCard(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
    color: AppColors.surfaceRaised.withValues(alpha: 0.86),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OUTPUT POWER',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(letterSpacing: 1.3, fontSize: 11),
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            '${_number(status.outputPower, 2)} W',
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w700,
              color: AppColors.cyan,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            StatusBadge(
              label: _cvccLabel(status.cvccState),
              color: status.cvccState == CvccState.unknown
                  ? AppColors.amber
                  : AppColors.electricBlue,
            ),
            StatusBadge(
              label: status.outputState == OutputState.on
                  ? 'OUTPUT ON'
                  : status.outputState == OutputState.off
                  ? 'OUTPUT OFF'
                  : 'OUTPUT UNKNOWN',
              color: status.outputState == OutputState.on
                  ? AppColors.green
                  : status.outputState == OutputState.off
                  ? AppColors.dim
                  : AppColors.amber,
            ),
          ],
        ),
      ],
    ),
  );
}

class _SetpointPanel extends StatelessWidget {
  const _SetpointPanel({
    required this.status,
    required this.onVoltage,
    required this.onCurrent,
  });

  final DeviceStatus status;
  final ValueChanged<double> onVoltage;
  final ValueChanged<double> onCurrent;

  @override
  Widget build(BuildContext context) => GlassCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: '设定值', subtitle: '范围：0–36 V · 0–5 A'),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) => Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: constraints.maxWidth >= 440
                    ? (constraints.maxWidth - 12) / 2
                    : constraints.maxWidth,
                child: _AdjustTile(
                  label: '电压设定',
                  value: _number(status.voltageSet, 2),
                  unit: 'V',
                  accent: AppColors.electricBlue,
                  onChanged: onVoltage,
                  min: 0,
                  max: 36,
                  fractionDigits: 2,
                  steps: const [10, 1, 0.1, 0.01],
                  initialStep: 0.1,
                ),
              ),
              SizedBox(
                width: constraints.maxWidth >= 440
                    ? (constraints.maxWidth - 12) / 2
                    : constraints.maxWidth,
                child: _AdjustTile(
                  label: '电流设定',
                  value: _number(status.currentSet, 3),
                  unit: 'A',
                  accent: AppColors.cyan,
                  onChanged: onCurrent,
                  min: 0,
                  max: 5,
                  fractionDigits: 3,
                  steps: const [1, 0.1, 0.01, 0.001],
                  initialStep: 0.01,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _AdjustTile extends StatefulWidget {
  const _AdjustTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.accent,
    required this.onChanged,
    required this.min,
    required this.max,
    required this.fractionDigits,
    required this.steps,
    required this.initialStep,
  });

  final String label;
  final String value;
  final String unit;
  final Color accent;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final int fractionDigits;
  final List<double> steps;
  final double initialStep;

  @override
  State<_AdjustTile> createState() => _AdjustTileState();
}

class _AdjustTileState extends State<_AdjustTile> {
  late double _step;

  @override
  void initState() {
    super.initState();
    _step = widget.initialStep;
  }

  void _adjust(int direction) {
    final current = double.tryParse(widget.value) ?? widget.min;
    final adjusted = (current + direction * _step)
        .clamp(widget.min, widget.max)
        .toDouble();
    widget.onChanged(
      double.parse(adjusted.toStringAsFixed(widget.fractionDigits)),
    );
  }

  @override
  Widget build(BuildContext context) => Container(
    key: ValueKey('adjust-tile-${widget.unit}'),
    padding: const EdgeInsets.fromLTRB(14, 13, 10, 10),
    decoration: BoxDecoration(
      color: AppColors.background.withValues(alpha: 0.38),
      borderRadius: AppRadius.small,
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '${widget.value} ${widget.unit}',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: widget.accent,
                  ),
                ),
              ),
            ),
            IconButton(
              key: ValueKey('adjust-decrease-${widget.unit}'),
              tooltip: '减少',
              onPressed: () => _adjust(-1),
              icon: const Icon(Icons.remove_rounded),
            ),
            IconButton(
              key: ValueKey('adjust-increase-${widget.unit}'),
              tooltip: '增加',
              onPressed: () => _adjust(1),
              icon: const Icon(Icons.add_rounded),
            ),
            IconButton.filledTonal(
              tooltip: '输入数值',
              onPressed: () async {
                final next = await _numberDialog(
                  context,
                  widget.label,
                  widget.value,
                  widget.min,
                  widget.max,
                );
                if (next != null) widget.onChanged(next);
              },
              icon: const Icon(Icons.edit_outlined, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text('微调挡位', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(width: 10),
            Expanded(
              child: SegmentedButton<double>(
                key: ValueKey('adjust-step-${widget.unit}'),
                showSelectedIcon: false,
                segments: widget.steps
                    .map(
                      (step) => ButtonSegment<double>(
                        value: step,
                        label: Text(_stepLabel(step)),
                      ),
                    )
                    .toList(),
                selected: {_step},
                onSelectionChanged: (selection) {
                  setState(() => _step = selection.single);
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

String _stepLabel(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toString();

class _OutputPanel extends StatelessWidget {
  const _OutputPanel({
    required this.status,
    required this.busy,
    required this.onToggle,
    required this.onRefresh,
  });

  final DeviceStatus status;
  final bool busy;
  final VoidCallback onToggle;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final enabled = status.outputState == OutputState.on;
    final unknown = status.outputState == OutputState.unknown;
    return GlassCard(
      color:
          (enabled
                  ? AppColors.green
                  : unknown
                  ? AppColors.amber
                  : AppColors.surface)
              .withValues(alpha: enabled || unknown ? 0.1 : 0.82),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('输出控制', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  unknown
                      ? '设备状态未知，发送前请重新读取。'
                      : enabled
                      ? '当前输出已开启。'
                      : '当前输出已关闭。',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            tooltip: '读取状态',
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: busy ? null : onToggle,
            style: FilledButton.styleFrom(
              backgroundColor: enabled ? AppColors.red : AppColors.green,
              foregroundColor: AppColors.background,
            ),
            icon: busy
                ? const SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(enabled ? Icons.power_off_rounded : Icons.power_rounded),
            label: Text(
              unknown
                  ? '状态未知'
                  : enabled
                  ? '关闭输出'
                  : '开启输出',
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickPresetPanel extends StatelessWidget {
  const _QuickPresetPanel({required this.onApply});

  final Future<void> Function(double voltage, double current) onApply;

  @override
  Widget build(BuildContext context) => GlassCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: '快捷预设', subtitle: '只更新电压和电流设定，不会自动开启输出'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _PresetButton(
              label: '5 V / 1 A',
              voltage: 5,
              current: 1,
              onApply: onApply,
            ),
            _PresetButton(
              label: '9 V / 1 A',
              voltage: 9,
              current: 1,
              onApply: onApply,
            ),
            _PresetButton(
              label: '12 V / 2 A',
              voltage: 12,
              current: 2,
              onApply: onApply,
            ),
            _PresetButton(
              label: '24 V / 1 A',
              voltage: 24,
              current: 1,
              onApply: onApply,
            ),
            _PresetButton(
              label: '36 V / 1 A',
              voltage: 36,
              current: 1,
              onApply: onApply,
            ),
          ],
        ),
      ],
    ),
  );
}

class _PresetButton extends StatelessWidget {
  const _PresetButton({
    required this.label,
    required this.voltage,
    required this.current,
    required this.onApply,
  });

  final String label;
  final double voltage;
  final double current;
  final Future<void> Function(double voltage, double current) onApply;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: () => onApply(voltage, current),
    icon: const Icon(Icons.bookmark_outline_rounded, size: 16),
    label: Text(label),
  );
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
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

Future<bool> _confirmOutput(BuildContext context, DeviceStatus status) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('确认开启输出'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('请确认以下设定值后再启动设备。'),
          const SizedBox(height: 14),
          Text('电压：${_number(status.voltageSet, 3)} V'),
          Text('电流：${_number(status.currentSet, 3)} A'),
          Text(
            '功率：${_number((status.voltageSet ?? 0) * (status.currentSet ?? 0), 2)} W',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('取消'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.power_rounded),
          label: const Text('确认开启'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

Future<double?> _numberDialog(
  BuildContext context,
  String label,
  String initial,
  double min,
  double max,
) async {
  return showNumberInputDialog<double>(
    context,
    title: '设置$label',
    initialValue: initial == '--' ? '' : initial,
    labelText: '$min–$max',
    autofocus: true,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    parse: (text) {
      final value = double.tryParse(text);
      return value != null && value >= min && value <= max ? value : null;
    },
  );
}

String _number(double? value, int fraction) =>
    value == null ? '--' : value.toStringAsFixed(fraction);
String _timeLabel(DateTime? time) => time == null
    ? '--'
    : '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
String _duration(Duration duration) =>
    '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
String _cvccLabel(CvccState state) => switch (state) {
  CvccState.cv => 'CV',
  CvccState.cc => 'CC',
  CvccState.unknown => '未知',
};
