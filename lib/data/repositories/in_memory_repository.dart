import 'dart:convert';

import '../../domain/models/device_models.dart';
import '../../domain/repositories/local_repository.dart';

class InMemoryRepository implements LocalRepository {
  final List<Preset> _presets = [];
  final List<MeasurementSample> _samples = [];
  final List<OutputSession> _sessions = [];
  final List<DataGroup> _groups = [];
  final List<CommunicationLogEntry> _logs = [];
  final Map<String, String> _settings = {};
  int _nextPresetId = 1;

  @override
  Future<void> saveSample(MeasurementSample sample) async =>
      _samples.add(sample);

  @override
  Future<void> saveSession(OutputSession session) async =>
      _sessions.add(session);

  @override
  Future<List<OutputSession>> loadSessions(String deviceId) async => _sessions
      .where((session) => session.deviceId == deviceId)
      .toList()
      .reversed
      .toList();

  @override
  Future<void> savePreset(Preset preset, {String? deviceId}) async =>
      _presets.add(
        Preset(
          id: preset.id ?? _nextPresetId++,
          name: preset.name,
          voltage: preset.voltage,
          current: preset.current,
        ),
      );

  @override
  Future<List<Preset>> loadPresets({String? deviceId}) async =>
      List<Preset>.from(_presets);

  @override
  Future<void> saveGroup(DataGroup group, {required String deviceId}) async {
    _groups.removeWhere(
      (saved) =>
          saved.index == group.index &&
          saved.name?.startsWith('$deviceId:') == true,
    );
    _groups.add(
      group.copyWith(name: '$deviceId:${group.name ?? 'M${group.index}'}'),
    );
  }

  @override
  Future<List<DataGroup>> loadGroups(String deviceId) async => _groups
      .where((group) => group.name?.startsWith('$deviceId:') == true)
      .map(
        (group) =>
            group.copyWith(name: group.name!.substring(deviceId.length + 1)),
      )
      .toList();

  @override
  Future<void> saveCommunicationLog(CommunicationLogEntry entry) async =>
      _logs.add(entry);

  @override
  Future<List<CommunicationLogEntry>> loadCommunicationLogs(
    String deviceId,
  ) async => _logs
      .where((entry) => entry.deviceId == deviceId)
      .toList()
      .reversed
      .toList();

  @override
  Future<void> setSetting(String key, String value) async =>
      _settings[key] = value;

  @override
  Future<String?> getSetting(String key) async => _settings[key];

  @override
  Future<String> exportSessionsCsv(String deviceId) async {
    final rows = await loadSessions(deviceId);
    final buffer = StringBuffer(
      'device_id,start_time,end_time,duration_seconds,average_voltage,average_current,max_power,total_ah,total_wh\n',
    );
    for (final row in rows) {
      buffer.writeln(
        [
          row.deviceId,
          row.startTime.toIso8601String(),
          row.endTime?.toIso8601String() ?? '',
          row.outputDuration.inSeconds,
          row.averageVoltage ?? '',
          row.averageCurrent ?? '',
          row.maxPower ?? '',
          row.totalAh ?? '',
          row.totalWh ?? '',
        ].map(_csv).join(','),
      );
    }
    return buffer.toString();
  }

  @override
  Future<String> exportSessionsJson(String deviceId) async => jsonEncode(
    (await loadSessions(deviceId))
        .map(
          (row) => {
            'deviceId': row.deviceId,
            'startTime': row.startTime.toIso8601String(),
            'endTime': row.endTime?.toIso8601String(),
            'durationSeconds': row.outputDuration.inSeconds,
            'averageVoltage': row.averageVoltage,
            'averageCurrent': row.averageCurrent,
            'maxPower': row.maxPower,
            'totalAh': row.totalAh,
            'totalWh': row.totalWh,
          },
        )
        .toList(),
  );

  @override
  Future<String> exportLogsCsv(String deviceId) async {
    final rows = await loadCommunicationLogs(deviceId);
    final buffer = StringBuffer(
      'device_id,timestamp,direction,raw_hex,parsed,success,error\n',
    );
    for (final row in rows) {
      buffer.writeln(
        [
          row.deviceId,
          row.timestamp.toIso8601String(),
          row.direction.name,
          row.rawBytes
              .map(
                (byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase(),
              )
              .join(' '),
          row.parsedMessage ?? '',
          row.success,
          row.error ?? '',
        ].map(_csv).join(','),
      );
    }
    return buffer.toString();
  }

  @override
  Future<String> exportLogsJson(String deviceId) async => jsonEncode(
    (await loadCommunicationLogs(deviceId))
        .map(
          (row) => {
            'deviceId': row.deviceId,
            'timestamp': row.timestamp.toIso8601String(),
            'direction': row.direction.name,
            'rawBytes': row.rawBytes,
            'parsedMessage': row.parsedMessage,
            'success': row.success,
            'error': row.error,
          },
        )
        .toList(),
  );

  static String _csv(Object value) {
    final text = value.toString();
    return text.contains(',') || text.contains('"') || text.contains('\n')
        ? '"${text.replaceAll('"', '""')}"'
        : text;
  }
}
