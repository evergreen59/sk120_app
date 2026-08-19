import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';
import 'package:file_saver/file_saver.dart';

import '../../app/theme/app_theme.dart';
import '../../application/providers.dart';
import '../../domain/models/device_models.dart';
import '../../shared/responsive/responsive.dart';
import '../../shared/widgets/glass_card.dart';

class CommunicationLogPage extends ConsumerStatefulWidget {
  const CommunicationLogPage({super.key});

  @override
  ConsumerState<CommunicationLogPage> createState() =>
      _CommunicationLogPageState();
}

class _CommunicationLogPageState extends ConsumerState<CommunicationLogPage> {
  List<CommunicationLogEntry> _entries = const [];
  bool _loading = true;
  StreamSubscription<List<CommunicationLogEntry>>? _logSubscription;
  bool _paused = false;
  bool _showTx = true;
  bool _showRx = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    final repository = ref.read(localRepositoryProvider);
    final id = ref.read(powerDeviceServiceProvider).id;
    _logSubscription = repository.watchCommunicationLogs(id).listen((logs) {
      if (!mounted) return;
      if (!_paused) {
        setState(() => _entries = logs);
      } else {
        _entries = logs;
      }
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _logSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('通信日志'),
      leading: BackButton(onPressed: () => Navigator.maybePop(context)),
      actions: [
        IconButton(
          tooltip: '导出 CSV',
          onPressed: () => _export(context, true),
          icon: const Icon(Icons.table_view_outlined),
        ),
        IconButton(
          tooltip: '导出 JSON',
          onPressed: () => _export(context, false),
          icon: const Icon(Icons.data_object_rounded),
        ),
        IconButton(
          tooltip: _paused ? '继续' : '暂停',
          onPressed: () => setState(() => _paused = !_paused),
          icon: Icon(_paused ? Icons.play_arrow_rounded : Icons.pause_rounded),
        ),
      ],
    ),
    body: SafeArea(
      child: ResponsiveContent(
        child: Builder(
          builder: (context) {
            final entries = _entries.where((entry) {
              final directionMatch =
                  entry.direction == CommunicationDirection.tx
                  ? _showTx
                  : _showRx;
              final searchMatch =
                  _search.isEmpty ||
                  entry.rawBytes
                      .map((byte) => byte.toRadixString(16))
                      .join(' ')
                      .contains(_search.toLowerCase()) ||
                  (entry.parsedMessage ?? '').toLowerCase().contains(
                    _search.toLowerCase(),
                  );
              return directionMatch && searchMatch;
            }).toList();
            return ListView(
              padding: const EdgeInsets.fromLTRB(28, 18, 28, 28),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search_rounded),
                          hintText: '搜索 HEX 或解析内容',
                          isDense: true,
                        ),
                        onChanged: (value) => setState(() => _search = value),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilterChip(
                      label: const Text('TX'),
                      selected: _showTx,
                      onSelected: (value) => setState(() => _showTx = value),
                    ),
                    const SizedBox(width: 6),
                    FilterChip(
                      label: const Text('RX'),
                      selected: _showRx,
                      onSelected: (value) => setState(() => _showRx = value),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else if (entries.isEmpty)
                  const GlassCard(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('暂无符合条件的通信记录')),
                    ),
                  )
                else
                  ...entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _LogRow(entry: entry),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    ),
  );

  Future<void> _export(BuildContext context, bool csv) async {
    final repository = ref.read(localRepositoryProvider);
    final id = ref.read(powerDeviceServiceProvider).id;
    final content = csv
        ? await repository.exportLogsCsv(id)
        : await repository.exportLogsJson(id);
    try {
      await FileSaver.instance.saveFile(
        name: '${id}_communication_${DateTime.now().millisecondsSinceEpoch}',
        bytes: Uint8List.fromList(utf8.encode(content)),
        fileExtension: csv ? 'csv' : 'json',
        mimeType: csv ? MimeType.csv : MimeType.json,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('文件已保存')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存失败：$error')));
      }
    }
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(csv ? 'CSV 导出内容' : 'JSON 导出内容'),
        content: SizedBox(
          width: 660,
          child: SingleChildScrollView(
            child: SelectableText(
              content,
              style: const TextStyle(fontFamily: AppFonts.sans, fontSize: 11),
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
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({required this.entry});

  final CommunicationLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final tx = entry.direction == CommunicationDirection.tx;
    final color = tx ? AppColors.electricBlue : AppColors.cyan;
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: AppRadius.small,
                ),
                child: Text(
                  tx ? 'TX' : 'RX',
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Text(
                DateFormat('HH:mm:ss.SSS').format(entry.timestamp),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              Icon(
                entry.success
                    ? Icons.check_circle_outline_rounded
                    : Icons.error_outline_rounded,
                color: entry.success ? AppColors.green : AppColors.red,
                size: 17,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            entry.rawBytes
                .map(
                  (byte) =>
                      byte.toRadixString(16).padLeft(2, '0').toUpperCase(),
                )
                .join(' '),
            style: const TextStyle(
              fontFamily: AppFonts.sans,
              letterSpacing: 0.6,
              color: AppColors.text,
              fontSize: 12,
            ),
          ),
          if (entry.parsedMessage != null) ...[
            const SizedBox(height: 6),
            Text(
              entry.parsedMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (entry.error != null) ...[
            const SizedBox(height: 5),
            Text(
              entry.error!,
              style: const TextStyle(color: AppColors.red, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
