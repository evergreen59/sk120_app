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
              SectionTitle(title: '数据组', subtitle: 'M0–M9 · 设备侧存储参数'),
              const SizedBox(height: 18),
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
  });

  final DataGroup group;
  final bool busy;
  final VoidCallback onRead;
  final VoidCallback onLoad;
  final VoidCallback onEdit;

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
              onPressed: busy ? null : onEdit,
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
            onPressed: busy ? null : onLoad,
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
            '输出开启时不能写入数据组。关闭输出后再执行加载。',
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
  await notifier.readGroup(group.index);
  final latest = ref.read(deviceStateProvider).groups[group.index];
  if (!context.mounted) return;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('预览 M${group.index}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('以下参数将写入设备当前设定，不会自动开启输出。'),
          const SizedBox(height: 14),
          Text('电压：${latest.voltageSet?.toStringAsFixed(3) ?? '--'} V'),
          Text('电流：${latest.currentSet?.toStringAsFixed(3) ?? '--'} A'),
          Text(
            '过功率：${latest.overPowerProtection?.toStringAsFixed(1) ?? '--'} W',
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
          icon: const Icon(Icons.check_rounded),
          label: const Text('确认加载'),
        ),
      ],
    ),
  );
  if (confirmed == true) await notifier.writeGroup(latest);
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
