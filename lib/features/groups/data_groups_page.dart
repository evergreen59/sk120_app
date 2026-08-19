import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../application/providers.dart';
import '../../domain/models/device_models.dart';
import '../../shared/responsive/responsive.dart';
import '../../shared/widgets/glass_card.dart';

class DataGroupsPage extends ConsumerWidget {
  const DataGroupsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deviceStateProvider);
    final notifier = ref.read(deviceStateProvider.notifier);
    return Scaffold(
      body: SafeArea(
        child: ResponsiveContent(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
            children: [
              SectionTitle(
                title: 'Data Groups',
                subtitle: 'Device Groups · M0–M9 stored on XY-SK120',
              ),
              const SizedBox(height: 18),
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    state.errorMessage!,
                    style: const TextStyle(color: AppColors.red),
                  ),
                ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth > 1000
                      ? 3
                      : constraints.maxWidth > 640
                      ? 2
                      : 1;
                  final width =
                      (constraints.maxWidth - (columns - 1) * 12) / columns;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final group in state.groups)
                        SizedBox(
                          width: width,
                          child: _GroupCard(
                            group: group,
                            busy: state.busy,
                            onRead: () => notifier.readGroup(group.index),
                            onLoad: () => _loadGroup(context, ref, group),
                            onEdit: () => _editGroup(context, ref, group),
                            editable:
                                group.voltageSet != null &&
                                group.currentSet != null,
                            outputOn:
                                state.status.outputState == OutputState.on,
                          ),
                        ),
                    ],
                  );
                },
              ),
              if (state.status.outputState == OutputState.on) ...[
                const SizedBox(height: 16),
                const _SafetyNote(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    required this.busy,
    required this.onRead,
    required this.onLoad,
    required this.onEdit,
    required this.editable,
    required this.outputOn,
  });

  final DataGroup group;
  final bool busy;
  final VoidCallback onRead;
  final VoidCallback onLoad;
  final VoidCallback onEdit;
  final bool editable;
  final bool outputOn;

  @override
  Widget build(BuildContext context) => GlassCard(
    padding: const EdgeInsets.fromLTRB(15, 14, 12, 13),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.electricBlue.withValues(alpha: 0.12),
                borderRadius: AppRadius.small,
              ),
              child: Text(
                'M${group.index}',
                style: const TextStyle(
                  color: AppColors.electricBlue,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                group.name ?? 'M${group.index}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: '编辑数据组',
              onPressed: busy || !editable || outputOn ? null : onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
            ),
            IconButton(
              tooltip: '读取数据组',
              onPressed: busy ? null : onRead,
              icon: const Icon(Icons.download_outlined, size: 19),
            ),
          ],
        ),
        const Divider(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 7,
          children: [
            _Value(
              label: 'V',
              value: group.voltageSet == null
                  ? '--'
                  : '${group.voltageSet!.toStringAsFixed(2)} V',
            ),
            _Value(
              label: 'I',
              value: group.currentSet == null
                  ? '--'
                  : '${group.currentSet!.toStringAsFixed(3)} A',
            ),
            _Value(
              label: 'OPP',
              value: group.overPowerProtection == null
                  ? '--'
                  : '${group.overPowerProtection!.toStringAsFixed(1)} W',
            ),
          ],
        ),
        const SizedBox(height: 13),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonalIcon(
            onPressed: busy || !editable || outputOn ? null : onLoad,
            icon: const Icon(Icons.input_rounded, size: 18),
            label: const Text('预览并加载'),
          ),
        ),
      ],
    ),
  );
}

class _Value extends StatelessWidget {
  const _Value({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('$label  ', style: Theme.of(context).textTheme.bodyMedium),
      Text(value, style: Theme.of(context).textTheme.bodyLarge),
    ],
  );
}

class _SafetyNote extends StatelessWidget {
  const _SafetyNote();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.amber.withValues(alpha: 0.1),
      borderRadius: AppRadius.small,
      border: Border.all(color: AppColors.amber.withValues(alpha: 0.35)),
    ),
    child: const Row(
      children: [
        Icon(Icons.lock_outline_rounded, color: AppColors.amber, size: 18),
        SizedBox(width: 9),
        Expanded(
          child: Text(
            '输出开启时不能保存或调用数据组。请先关闭输出。',
            style: TextStyle(color: AppColors.text, fontSize: 12),
          ),
        ),
      ],
    ),
  );
}

Future<void> _loadGroup(
  BuildContext context,
  WidgetRef ref,
  DataGroup group,
) async {
  final notifier = ref.read(deviceStateProvider.notifier);
  final latest = await notifier.readGroup(group.index);
  if (latest == null) return;
  if (!context.mounted) return;
  final confirmed = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.58),
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '预览 M${group.index}',
              style: const TextStyle(fontSize: 0, color: Colors.transparent),
            ),
            Text(
              'Load M${group.index}?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            const Text(
              '确认后将通过 EXTRACT-M 调用该组。',
              style: TextStyle(fontSize: 0, color: Colors.transparent),
            ),
            Text('Voltage  ${latest.voltageSet?.toStringAsFixed(3) ?? '--'} V'),
            Text('Current  ${latest.currentSet?.toStringAsFixed(3) ?? '--'} A'),
            Text(
              'OPP  ${latest.overPowerProtection?.toStringAsFixed(1) ?? '--'} W',
            ),
            const SizedBox(height: 12),
            const Text(
              'Loading a data group never turns output ON.',
              style: TextStyle(color: AppColors.amber, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GlassButton(
                    primary: true,
                    child: const Text('确认加载'),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  if (confirmed == true) await notifier.activateGroup(latest.index);
}

Future<void> _editGroup(
  BuildContext context,
  WidgetRef ref,
  DataGroup group,
) async {
  final edited = await showDialog<DataGroup>(
    context: context,
    builder: (context) => _GroupEditor(group: group),
  );
  if (edited != null) {
    await ref.read(deviceStateProvider.notifier).writeGroup(edited);
  }
}

class _GroupEditor extends StatefulWidget {
  const _GroupEditor({required this.group});

  final DataGroup group;

  @override
  State<_GroupEditor> createState() => _GroupEditorState();
}

class _GroupEditorState extends State<_GroupEditor> {
  String? _error;
  late final TextEditingController _name;
  late final TextEditingController _voltage;
  late final TextEditingController _current;
  late final TextEditingController _opp;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(
      text: widget.group.name ?? 'M${widget.group.index}',
    );
    _voltage = TextEditingController(
      text: widget.group.voltageSet?.toString() ?? '12',
    );
    _current = TextEditingController(
      text: widget.group.currentSet?.toString() ?? '1.25',
    );
    _opp = TextEditingController(
      text: widget.group.overPowerProtection?.toString() ?? '20',
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _voltage.dispose();
    _current.dispose();
    _opp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('编辑 M${widget.group.index}'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: '名称'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _voltage,
            decoration: const InputDecoration(labelText: '电压 V'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _current,
            decoration: const InputDecoration(labelText: '电流 A'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _opp,
            decoration: const InputDecoration(labelText: '过功率 W'),
          ),
        ],
      ),
    ),
    actions: [
      if (_error != null)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(_error!, style: const TextStyle(color: Colors.red)),
        ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('取消'),
      ),
      FilledButton(
        onPressed: () {
          final voltage = double.tryParse(_voltage.text);
          final current = double.tryParse(_current.text);
          final opp = double.tryParse(_opp.text);
          if (voltage == null ||
              current == null ||
              opp == null ||
              voltage < 0 ||
              voltage > 36 ||
              current < 0 ||
              current > 5 ||
              opp < 0 ||
              opp > 120) {
            setState(() => _error = '请输入有效范围：电压 0-36V，电流 0-5A，过功率 0-120W');
            return;
          }
          Navigator.pop(
            context,
            widget.group.copyWith(
              name: _name.text.trim().isEmpty
                  ? 'M${widget.group.index}'
                  : _name.text.trim(),
              voltageSet: voltage,
              currentSet: current,
              overPowerProtection: opp,
            ),
          );
        },
        child: const Text('保存'),
      ),
    ],
  );
}
