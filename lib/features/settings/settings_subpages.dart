import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../application/providers.dart';
import '../../shared/responsive/responsive.dart';
import '../../shared/widgets/glass_card.dart';

class ProtectionPage extends StatefulWidget {
  const ProtectionPage({super.key});
  @override
  State<ProtectionPage> createState() => _ProtectionPageState();
}

class _ProtectionPageState extends State<ProtectionPage> {
  final values = <String, double>{
    'LVP': 10,
    'OVP': 30,
    'OCP': 5,
    'OPP': 100,
    'OTP': 80,
    'External Temperature': 60,
  };
  final enabled = <String, bool>{
    'LVP': true,
    'OVP': true,
    'OCP': true,
    'OPP': true,
    'OTP': true,
    'External Temperature': false,
    'Maximum Output Time': false,
    'Maximum Capacity': false,
    'Maximum Energy': false,
  };

  @override
  Widget build(BuildContext context) => _SubPageScaffold(
    title: 'Protection Settings',
    subtitle: 'Limits are enforced by the device before output is disabled.',
    child: Column(
      children: [
        for (final item in values.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GlassCard(
              padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
              child: Row(
                children: [
                  Icon(
                    item.key == 'OTP' || item.key == 'External Temperature'
                        ? Icons.thermostat_outlined
                        : Icons.shield_outlined,
                    color: item.key == 'OVP' || item.key == 'OCP'
                        ? AppColors.red
                        : AppColors.amber,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.key,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${item.value.toStringAsFixed(item.key == 'OCP' ? 3 : 1)} ${item.key.contains('Temperature') || item.key == 'OTP'
                              ? '°C'
                              : item.key == 'OPP'
                              ? 'W'
                              : item.key == 'OCP'
                              ? 'A'
                              : 'V'}',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ToggleSwitch(
                    value: enabled[item.key] ?? false,
                    color: AppColors.amber,
                    onChanged: (next) =>
                        setState(() => enabled[item.key] = next),
                  ),
                ],
              ),
            ),
          ),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Session Limits',
                style: TextStyle(
                  color: AppColors.dim,
                  fontSize: 11,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              for (final item in [
                'Maximum Output Time',
                'Maximum Capacity',
                'Maximum Energy',
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(child: Text(item)),
                      ToggleSwitch(
                        value: enabled[item] ?? false,
                        color: AppColors.amber,
                        onChanged: (next) =>
                            setState(() => enabled[item] = next),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: GlassButton(
            primary: true,
            color: AppColors.amber,
            child: const Text('Save Settings'),
            onPressed: () => showGlassToast(
              context,
              'Protection settings saved',
              color: AppColors.amber,
            ),
          ),
        ),
      ],
    ),
  );
}

class AdvancedPowerPage extends StatefulWidget {
  const AdvancedPowerPage({super.key});
  @override
  State<AdvancedPowerPage> createState() => _AdvancedPowerPageState();
}

class _AdvancedPowerPageState extends State<AdvancedPowerPage> {
  bool constantPower = false;
  double targetPower = 50;
  String strategy = 'off';
  @override
  Widget build(BuildContext context) => _SubPageScaffold(
    title: 'Advanced Power Control',
    subtitle: 'Constant power and safe power-on strategy',
    child: Column(
      children: [
        GlassCard(
          child: Column(
            children: [
              _subRow(
                'Constant Power',
                'CW-SW',
                ToggleSwitch(
                  value: constantPower,
                  color: AppColors.purple,
                  onChanged: (v) => setState(() => constantPower = v),
                ),
              ),
              _subRow(
                'Target Power',
                '${targetPower.toStringAsFixed(1)} W',
                SizedBox(
                  width: 180,
                  child: Slider(
                    value: targetPower,
                    min: 0,
                    max: 120,
                    onChanged: (v) => setState(() => targetPower = v),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Power-on Output Strategy',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              GlassSegmentedControl<String>(
                items: const [
                  ('off', 'Always OFF'),
                  ('restore', 'Restore Previous'),
                  ('on', 'Always ON'),
                ],
                value: strategy,
                onChanged: (v) => setState(() => strategy = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: GlassButton(
            primary: true,
            color: AppColors.purple,
            child: const Text('Save Settings'),
            onPressed: () => showGlassToast(
              context,
              'Advanced settings saved',
              color: AppColors.purple,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _subRow(String label, String detail, Widget trailing) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 8),
  child: Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            const SizedBox(height: 2),
            Text(
              detail,
              style: const TextStyle(color: AppColors.dim, fontSize: 11),
            ),
          ],
        ),
      ),
      trailing,
    ],
  ),
);

class DeviceSettingsPage extends ConsumerWidget {
  const DeviceSettingsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deviceStateProvider);
    final notifier = ref.read(deviceStateProvider.notifier);
    return _SubPageScaffold(
      title: 'Device Settings',
      subtitle: 'Display, sound, communication and calibration',
      child: Column(
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Display',
                  style: TextStyle(
                    color: AppColors.blueBright,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                _subRow(
                  'Backlight Brightness',
                  '${state.status.backlightLevel ?? 0}/5',
                  SizedBox(
                    width: 180,
                    child: Slider(
                      value: (state.status.backlightLevel ?? 0)
                          .clamp(0, 5)
                          .toDouble(),
                      min: 0,
                      max: 5,
                      divisions: 5,
                      onChanged: state.status.isConnected
                          ? (v) => notifier.setBacklight(v.round())
                          : null,
                    ),
                  ),
                ),
                _subRow(
                  'Auto Sleep Timer',
                  '60 minutes',
                  const Icon(Icons.chevron_right_rounded, color: AppColors.dim),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sound & Communication',
                  style: TextStyle(
                    color: AppColors.cyan,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                _subRow(
                  'Buzzer',
                  'BUZZER',
                  ToggleSwitch(
                    value: false,
                    onChanged: state.status.isConnected
                        ? notifier.setBuzzer
                        : null,
                  ),
                ),
                _subRow(
                  'Modbus Slave Address',
                  '0x${state.status.slaveAddress.toRadixString(16).padLeft(2, '0').toUpperCase()}',
                  const Icon(Icons.chevron_right_rounded, color: AppColors.dim),
                ),
                _subRow(
                  'Baud Rate',
                  state.status.baudRateLabel,
                  const Icon(Icons.chevron_right_rounded, color: AppColors.dim),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            color: AppColors.purple.withValues(alpha: 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Advanced Calibration',
                  style: TextStyle(
                    color: AppColors.purple,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                _subRow(
                  'Internal Temperature Offset',
                  '0.0 °C',
                  const Text('+0.0', style: TextStyle(color: AppColors.muted)),
                ),
                _subRow(
                  'External Temperature Offset',
                  '0.0 °C',
                  const Text('+0.0', style: TextStyle(color: AppColors.muted)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BleDevicesPage extends ConsumerStatefulWidget {
  const BleDevicesPage({super.key});
  @override
  ConsumerState<BleDevicesPage> createState() => _BleDevicesPageState();
}

class _BleDevicesPageState extends ConsumerState<BleDevicesPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deviceStateProvider);
    final notifier = ref.read(deviceStateProvider.notifier);
    final devices = state.discoveredDevices;
    return _SubPageScaffold(
      title: 'BLE Devices',
      subtitle: state.scanning
          ? 'Scanning nearby devices…'
          : 'Select a device to connect',
      child: Column(
        children: [
          GlassCard(
            child: Row(
              children: [
                const Icon(
                  Icons.bluetooth_searching_rounded,
                  color: AppColors.cyan,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text('Nearby devices')),
                GlassButton(
                  onPressed: state.scanning
                      ? notifier.stopScan
                      : notifier.startScan,
                  child: Text(state.scanning ? 'Stop Scan' : 'Scan'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (devices.isEmpty)
            GlassCard(
              child: Column(
                children: [
                  const Icon(
                    Icons.bluetooth_disabled_rounded,
                    color: AppColors.dim,
                    size: 34,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.scanning
                        ? 'Looking for XY-SK120…'
                        : 'No nearby devices',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          else
            for (final device in devices)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.bluetooth_rounded,
                        color: AppColors.cyan,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(device.name),
                            Text(
                              '${device.rssi ?? '--'} dBm · Excellent Signal',
                              style: const TextStyle(
                                color: AppColors.dim,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GlassButton(
                        child: const Text('Connect'),
                        onPressed: () => notifier.connect(deviceId: device.id),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _SubPageScaffold extends StatelessWidget {
  const _SubPageScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final String title;
  final String subtitle;
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ResponsiveContent(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    ),
  );
}
