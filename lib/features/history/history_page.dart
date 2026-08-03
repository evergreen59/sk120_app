import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_theme.dart';
import '../../application/providers.dart';
import '../../domain/models/device_models.dart';
import '../../shared/responsive/responsive.dart';
import '../../shared/widgets/glass_card.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  late Future<List<OutputSession>> _sessions;

  @override
  void initState() {
    super.initState();
    _sessions = _load();
  }

  Future<List<OutputSession>> _load() {
    final service = ref.read(powerDeviceServiceProvider);
    return ref.read(localRepositoryProvider).loadSessions(service.id);
  }

  void _refresh() => setState(() => _sessions = _load());

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ResponsiveContent(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
          children: [
            SectionTitle(
              title: '输出历史',
              subtitle: '输出开启至关闭形成一条会话记录',
              action: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: '导出 CSV',
                    onPressed: () => _export(context, csv: true),
                    icon: const Icon(Icons.table_view_outlined),
                  ),
                  IconButton(
                    tooltip: '导出 JSON',
                    onPressed: () => _export(context, csv: false),
                    icon: const Icon(Icons.data_object_rounded),
                  ),
                  IconButton(
                    tooltip: '刷新',
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            FutureBuilder<List<OutputSession>>(
              future: _sessions,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(42),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return _EmptyState(
                    title: '历史读取失败',
                    detail: snapshot.error.toString(),
                    icon: Icons.error_outline_rounded,
                  );
                }
                final sessions = snapshot.data ?? const <OutputSession>[];
                if (sessions.isEmpty) {
                  return const _EmptyState(
                    title: '暂无输出历史',
                    detail: '完成一次输出会话后，统计数据会显示在这里。',
                    icon: Icons.history_toggle_off_rounded,
                  );
                }
                return Column(
                  children: sessions
                      .map(
                        (session) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _SessionCard(
                            session: session,
                            onTap: () => _showDetails(context, session),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _export(BuildContext context, {required bool csv}) async {
    final service = ref.read(powerDeviceServiceProvider);
    final repository = ref.read(localRepositoryProvider);
    final content = csv
        ? await repository.exportSessionsCsv(service.id)
        : await repository.exportSessionsJson(service.id);
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => _ExportDialog(
        title: csv ? 'CSV 导出内容' : 'JSON 导出内容',
        content: content,
      ),
    );
  }

  Future<void> _showDetails(
    BuildContext context,
    OutputSession session,
  ) async => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('会话详情'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '开始：${DateFormat('yyyy-MM-dd HH:mm:ss').format(session.startTime)}',
          ),
          Text(
            '结束：${session.endTime == null ? '--' : DateFormat('yyyy-MM-dd HH:mm:ss').format(session.endTime!)}',
          ),
          Text('时长：${session.outputDuration.inSeconds} 秒'),
          Text('平均电压：${session.averageVoltage?.toStringAsFixed(3) ?? '--'} V'),
          Text('平均电流：${session.averageCurrent?.toStringAsFixed(3) ?? '--'} A'),
          Text('最大功率：${session.maxPower?.toStringAsFixed(2) ?? '--'} W'),
          Text(
            'AH / WH：${session.totalAh ?? '--'} / ${session.totalWh ?? '--'}',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
      ],
    ),
  );
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.onTap});

  final OutputSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GlassCard(
    onTap: onTap,
    padding: const EdgeInsets.fromLTRB(15, 14, 12, 14),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.green.withValues(alpha: 0.12),
            borderRadius: AppRadius.small,
          ),
          child: const Icon(Icons.power_rounded, color: AppColors.green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('yyyy-MM-dd HH:mm').format(session.startTime),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '${session.outputDuration.inMinutes} min  ·  最大 ${session.maxPower?.toStringAsFixed(2) ?? '--'} W',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        if (session.averageVoltage != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                session.averageVoltage!.toStringAsFixed(2),
                style: const TextStyle(
                  color: AppColors.electricBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '平均 V',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 11),
              ),
            ],
          ),
        const SizedBox(width: 6),
        const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
      ],
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.detail,
    required this.icon,
  });

  final String title;
  final String detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) => GlassCard(
    padding: const EdgeInsets.all(28),
    child: Column(
      children: [
        Icon(icon, size: 36, color: AppColors.dim),
        const SizedBox(height: 12),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(
          detail,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    ),
  );
}

class _ExportDialog extends StatelessWidget {
  const _ExportDialog({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(title),
    content: SizedBox(
      width: 620,
      child: SingleChildScrollView(
        child: SelectableText(
          content.isEmpty ? '暂无数据' : content,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
        ),
      ),
    ),
    actions: [
      TextButton.icon(
        onPressed: () {
          Clipboard.setData(ClipboardData(text: content));
          Navigator.pop(context);
        },
        icon: const Icon(Icons.copy_rounded),
        label: const Text('复制'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('关闭'),
      ),
    ],
  );
}
