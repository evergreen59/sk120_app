import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme.dart';
import '../../application/providers.dart';
import '../../domain/models/device_models.dart';
import '../../shared/responsive/responsive.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/number_input_dialog.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _engineeringMode = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deviceStateProvider);
    final mode = ref.watch(appModeProvider);
    final notifier = ref.read(deviceStateProvider.notifier);
    final status = state.status;
    return Scaffold(
      body: SafeArea(
        child: ResponsiveContent(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
            children: [
              const SectionTitle(title: '设置', subtitle: '连接、设备参数与工程诊断'),
              const SizedBox(height: 18),
              _Section(
                title: '运行模式',
                icon: Icons.swap_horiz_rounded,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(child: Text('设备通信模式')),
                        SegmentedButton<DeviceMode>(
                          showSelectedIcon: false,
                          segments: const [
                            ButtonSegment(
                              value: DeviceMode.real,
                              label: Text('Real BLE'),
                            ),
                            ButtonSegment(
                              value: DeviceMode.mock,
                              label: Text('Mock'),
                            ),
                          ],
                          selected: {mode},
                          onSelectionChanged: (selection) {
                            if (selection.isNotEmpty) {
                              ref
                                  .read(appModeProvider.notifier)
                                  .setMode(selection.first);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      mode == DeviceMode.real
                          ? '真实模式使用 BLE + Modbus RTU；未连接时不会伪造设备状态。'
                          : 'Mock 模式使用隔离的演示设备，不会访问 BLE。',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Section(
                title: '连接管理',
                icon: Icons.bluetooth_connected_rounded,
                child: Row(
                  children: [
                    Expanded(
                      child: _SettingValue(
                        label: '设备',
                        value: status.isConnected ? 'XY-SK120' : '未连接',
                      ),
                    ),
                    if (status.isConnected)
                      FilledButton.tonalIcon(
                        onPressed: state.busy ? null : notifier.disconnect,
                        icon: const Icon(Icons.link_off_rounded),
                        label: const Text('断开'),
                      )
                    else if (mode == DeviceMode.mock)
                      FilledButton.icon(
                        onPressed: state.busy ? null : notifier.connect,
                        icon: const Icon(Icons.link_rounded),
                        label: const Text('连接演示设备'),
                      )
                    else
                      Text(
                        '请在控制页扫描',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Section(
                title: '设备设置',
                icon: Icons.tune_rounded,
                child: Column(
                  children: [
                    _SettingRow(
                      label: '按键锁',
                      detail: 'LOCK',
                      trailing: Switch(
                        key: const ValueKey('key-lock-switch'),
                        value: status.keyLocked ?? false,
                        onChanged: status.isConnected
                            ? notifier.setKeyLock
                            : null,
                      ),
                    ),
                    _SettingRow(
                      label: '背光亮度',
                      detail: 'B-LED',
                      trailing: SizedBox(
                        width: 170,
                        child: Slider(
                          key: const ValueKey('backlight-slider'),
                          value: (status.backlightLevel ?? 0)
                              .clamp(0, 5)
                              .toDouble(),
                          min: 0,
                          max: 5,
                          divisions: 5,
                          label: '${status.backlightLevel ?? 0}',
                          onChanged: status.isConnected
                              ? (value) => notifier.setBacklight(value.round())
                              : null,
                        ),
                      ),
                    ),
                    _SettingRow(
                      label: '息屏时间',
                      detail: 'SLEEP',
                      trailing: TextButton(
                        onPressed: status.isConnected
                            ? () => _setSleep(context, notifier)
                            : null,
                        child: const Text('设置分钟'),
                      ),
                    ),
                    _SettingRow(
                      label: '蜂鸣器',
                      detail: 'BUZZER',
                      trailing: Switch(
                        value: false,
                        onChanged: status.isConnected
                            ? notifier.setBuzzer
                            : null,
                      ),
                    ),
                    _SettingRow(
                      label: '从机地址',
                      detail: 'SLAVE-ADD',
                      trailing: TextButton(
                        onPressed: status.isConnected
                            ? () => _setInteger(
                                context,
                                '从机地址',
                                status.slaveAddress,
                                1,
                                255,
                                notifier.setSlaveAddress,
                              )
                            : null,
                        child: Text(status.slaveAddress.toString()),
                      ),
                    ),
                    _SettingRow(
                      label: '波特率',
                      detail: 'BAUDRATE_L',
                      trailing: DropdownButton<DeviceBaudRate>(
                        key: const ValueKey('baud-rate-menu'),
                        value: status.baudRate,
                        hint: Text(status.baudRateLabel),
                        onChanged: status.isConnected
                            ? (value) {
                                if (value != null) notifier.setBaudRate(value);
                              }
                            : null,
                        items: [
                          for (final rate in DeviceBaudRate.values)
                            DropdownMenuItem(
                              value: rate,
                              child: Text(rate.label),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Section(
                title: '输出模式',
                icon: Icons.auto_graph_rounded,
                child: Column(
                  children: [
                    _SettingRow(
                      label: 'MPPT',
                      detail: 'MPPT-SW',
                      trailing: Switch(
                        value: status.mpptEnabled ?? false,
                        onChanged: status.isConnected
                            ? (value) => notifier.setMppt(
                                enabled: value,
                                coefficient: status.mpptCoefficient,
                              )
                            : null,
                      ),
                    ),
                    _SettingRow(
                      label: '恒功率',
                      detail: 'CW-SW',
                      trailing: Switch(
                        value: status.constantPowerEnabled ?? false,
                        onChanged: status.isConnected
                            ? (value) => _setConstantPower(
                                context,
                                notifier,
                                value,
                                status.constantPowerValue ?? 20,
                              )
                            : null,
                      ),
                    ),
                    _SettingRow(
                      label: '目标功率',
                      detail: 'CW',
                      trailing: Text(
                        '${status.constantPowerValue?.toStringAsFixed(1) ?? '--'} W',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Section(
                title: '保护状态',
                icon: Icons.shield_outlined,
                child: Column(
                  children: [
                    _SettingRow(
                      label: '保护寄存器',
                      detail: 'PROTECT',
                      trailing: Text(
                        status.protectionLabel,
                        style: const TextStyle(
                          color: AppColors.amber,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const Divider(height: 18),
                    _SettingRow(
                      label: '低压 / 过压',
                      detail: 'S-LVP / S-OVP',
                      trailing: const Text('数据组参数'),
                    ),
                    _SettingRow(
                      label: '过流 / 过功率',
                      detail: 'S-OCP / S-OPP',
                      trailing: const Text('数据组参数'),
                    ),
                    _SettingRow(
                      label: '过温 / 最大时长',
                      detail: 'S-OTP / S-OHP',
                      trailing: const Text('数据组参数'),
                    ),
                    _SettingRow(
                      label: '外部过温',
                      detail: 'S-ETP',
                      trailing: const Text('原始值只读'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'PROTECT 按说明书状态码显示；F-C 仍保留原始值。校准区默认不提供普通写入。',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Section(
                title: '工程模式',
                icon: Icons.build_circle_outlined,
                child: Column(
                  children: [
                    _SettingRow(
                      label: '诊断面板',
                      detail: 'BLE / Modbus 原始数据',
                      trailing: Switch(
                        value: _engineeringMode,
                        onChanged: (value) =>
                            setState(() => _engineeringMode = value),
                      ),
                    ),
                    if (_engineeringMode) ...[
                      const Divider(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '通信日志',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => context.push('/settings/logs'),
                            icon: const Icon(Icons.article_outlined),
                            label: const Text('打开'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const _EngineeringInfo(),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  'XY-SK120 Control 1.0.0  ·  Flutter 3.44.8  ·  协议寄存器表 v1',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    color: AppColors.dim,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) => GlassCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.cyan, size: 19),
            const SizedBox(width: 9),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 15),
        child,
      ],
    ),
  );
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.label,
    required this.detail,
    required this.trailing,
  });

  final String label;
  final String detail;
  final Widget trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 2),
              Text(
                detail,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
        trailing,
      ],
    ),
  );
}

class _SettingValue extends StatelessWidget {
  const _SettingValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text('$label  ', style: Theme.of(context).textTheme.bodyMedium),
      Text(value, style: Theme.of(context).textTheme.bodyLarge),
    ],
  );
}

class _EngineeringInfo extends StatelessWidget {
  const _EngineeringInfo();

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: const [
      Chip(avatar: Icon(Icons.lock_outline, size: 15), label: Text('校准区只读')),
      Chip(avatar: Icon(Icons.lock_outline, size: 15), label: Text('OZONE 只读')),
      Chip(
        avatar: Icon(Icons.info_outline, size: 15),
        label: Text('未知编码保留原始值'),
      ),
    ],
  );
}

Future<void> _setSleep(
  BuildContext context,
  DeviceStateNotifier notifier,
) async {
  final value = await showNumberInputDialog<int>(
    context,
    title: '息屏时间',
    initialValue: '10',
    labelText: '分钟',
    keyboardType: TextInputType.number,
    parse: (text) {
      final minutes = int.tryParse(text);
      return minutes != null && minutes >= 0 && minutes <= 65535
          ? minutes
          : null;
    },
  );
  if (value != null) await notifier.setSleepMinutes(value);
}

Future<void> _setConstantPower(
  BuildContext context,
  DeviceStateNotifier notifier,
  bool enabled,
  double initial,
) async {
  final value = await showNumberInputDialog<double>(
    context,
    title: '恒功率目标',
    initialValue: initial.toStringAsFixed(1),
    labelText: '0–120 W',
    confirmLabel: '应用',
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    parse: (text) {
      final watts = double.tryParse(text);
      return watts != null && watts >= 0 && watts <= 120 ? watts : null;
    },
  );
  if (value != null) {
    await notifier.setConstantPower(enabled: enabled, watts: value);
  }
}

Future<void> _setInteger(
  BuildContext context,
  String label,
  int initial,
  int min,
  int max,
  Future<void> Function(int value) onSubmit,
) async {
  final value = await showNumberInputDialog<int>(
    context,
    title: label,
    initialValue: initial.toString(),
    labelText: '$min–$max',
    keyboardType: TextInputType.number,
    parse: (text) {
      final parsed = int.tryParse(text);
      return parsed != null && parsed >= min && parsed <= max ? parsed : null;
    },
  );
  if (value != null) await onSubmit(value);
}
