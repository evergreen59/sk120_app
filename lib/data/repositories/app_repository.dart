import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/models/device_models.dart';
import '../../domain/repositories/local_repository.dart';
import '../database/app_database.dart'
    hide MeasurementSample, OutputSession, Preset;

class AppRepository implements LocalRepository {
  AppRepository(this.database);

  final Sk120Database database;

  Future<void> saveDevice({
    required String id,
    required String name,
    String? model,
    String? firmwareVersion,
    String? bleDeviceId,
    int? rssi,
    required DeviceMode mode,
  }) {
    return database
        .into(database.devices)
        .insertOnConflictUpdate(
          DevicesCompanion.insert(
            id: id,
            name: name,
            model: Value(model),
            firmwareVersion: Value(firmwareVersion),
            bleDeviceId: Value(bleDeviceId),
            lastRssi: Value(rssi),
            lastSeen: Value(DateTime.now()),
            createdAt: DateTime.now(),
            mode: mode.name,
          ),
        );
  }

  @override
  Future<void> saveSample(MeasurementSample sample) {
    return database
        .into(database.measurementSamples)
        .insert(
          MeasurementSamplesCompanion.insert(
            deviceId: sample.deviceId,
            timestamp: sample.timestamp,
            voltage: Value(sample.voltage),
            current: Value(sample.current),
            power: Value(sample.power),
            temperature: Value(sample.temperature),
            inputVoltage: Value(sample.inputVoltage),
            ah: Value(sample.ah),
            wh: Value(sample.wh),
            outputState: sample.outputState.name,
          ),
        );
  }

  @override
  Future<void> saveSession(OutputSession session) {
    return database
        .into(database.outputSessions)
        .insert(
          OutputSessionsCompanion.insert(
            deviceId: session.deviceId,
            startTime: session.startTime,
            endTime: Value(session.endTime),
            durationSeconds: session.outputDuration.inSeconds,
            averageVoltage: Value(session.averageVoltage),
            averageCurrent: Value(session.averageCurrent),
            maxPower: Value(session.maxPower),
            totalAh: Value(session.totalAh),
            totalWh: Value(session.totalWh),
          ),
        );
  }

  @override
  Future<List<OutputSession>> loadSessions(String deviceId) async {
    final rows =
        await (database.select(database.outputSessions)
              ..where((table) => table.deviceId.equals(deviceId))
              ..orderBy([
                (table) => OrderingTerm(
                  expression: table.startTime,
                  mode: OrderingMode.desc,
                ),
              ]))
            .get();
    return rows
        .map(
          (row) => OutputSession(
            id: row.id,
            deviceId: row.deviceId,
            startTime: row.startTime,
            endTime: row.endTime,
            outputDuration: Duration(seconds: row.durationSeconds),
            averageVoltage: row.averageVoltage,
            averageCurrent: row.averageCurrent,
            maxPower: row.maxPower,
            totalAh: row.totalAh,
            totalWh: row.totalWh,
          ),
        )
        .toList();
  }

  @override
  Future<void> savePreset(Preset preset, {String? deviceId}) {
    final companion = PresetsCompanion.insert(
      deviceId: Value(deviceId),
      name: preset.name,
      voltage: preset.voltage,
      current: preset.current,
      createdAt: DateTime.now(),
    );
    if (preset.id == null) {
      return database.into(database.presets).insert(companion).then((_) {});
    }
    return (database.update(database.presets)
          ..where((table) => table.id.equals(preset.id!)))
        .write(companion)
        .then((_) {});
  }

  @override
  Future<List<Preset>> loadPresets({String? deviceId}) async {
    final query = database.select(database.presets)
      ..orderBy([(table) => OrderingTerm(expression: table.createdAt)]);
    if (deviceId != null) {
      query.where(
        (table) => table.deviceId.equals(deviceId) | table.deviceId.isNull(),
      );
    }
    final rows = await query.get();
    return rows
        .map(
          (row) => Preset(
            id: row.id,
            name: row.name,
            voltage: row.voltage,
            current: row.current,
          ),
        )
        .toList();
  }

  @override
  Future<void> saveGroup(DataGroup group, {required String deviceId}) {
    final values = jsonEncode(_groupToJson(group));
    final companion = DeviceGroupsCompanion.insert(
      deviceId: deviceId,
      groupIndex: group.index,
      name: Value(group.name),
      valuesJson: values,
      updatedAt: DateTime.now(),
    );
    return database.transaction(() async {
      await (database.delete(database.deviceGroups)..where(
            (table) =>
                table.deviceId.equals(deviceId) &
                table.groupIndex.equals(group.index),
          ))
          .go();
      await database.into(database.deviceGroups).insert(companion);
    });
  }

  @override
  Future<List<DataGroup>> loadGroups(String deviceId) async {
    final rows =
        await (database.select(database.deviceGroups)
              ..where((table) => table.deviceId.equals(deviceId))
              ..orderBy([
                (table) => OrderingTerm(expression: table.groupIndex),
              ]))
            .get();
    return rows.map((row) {
      final values = jsonDecode(row.valuesJson) as Map<String, dynamic>;
      return _groupFromJson(row.groupIndex, row.name, values);
    }).toList();
  }

  @override
  Future<void> saveCommunicationLog(CommunicationLogEntry entry) {
    return database
        .into(database.communicationLogs)
        .insert(
          CommunicationLogsCompanion.insert(
            deviceId: entry.deviceId,
            timestamp: entry.timestamp,
            direction: entry.direction.name,
            rawHex: entry.rawBytes
                .map(
                  (byte) =>
                      byte.toRadixString(16).padLeft(2, '0').toUpperCase(),
                )
                .join(' '),
            parsedMessage: Value(entry.parsedMessage),
            success: entry.success,
            error: Value(entry.error),
          ),
        );
  }

  @override
  Future<List<CommunicationLogEntry>> loadCommunicationLogs(
    String deviceId,
  ) async {
    final rows =
        await (database.select(database.communicationLogs)
              ..where((table) => table.deviceId.equals(deviceId))
              ..orderBy([
                (table) => OrderingTerm(
                  expression: table.timestamp,
                  mode: OrderingMode.desc,
                ),
              ]))
            .get();
    return rows
        .map(
          (row) => CommunicationLogEntry(
            id: row.id,
            deviceId: row.deviceId,
            timestamp: row.timestamp,
            direction: row.direction == CommunicationDirection.tx.name
                ? CommunicationDirection.tx
                : CommunicationDirection.rx,
            rawBytes: _parseHex(row.rawHex),
            parsedMessage: row.parsedMessage,
            success: row.success,
            error: row.error,
          ),
        )
        .toList();
  }

  @override
  Future<void> setSetting(String key, String value) {
    return database
        .into(database.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(key: key, value: value),
        );
  }

  @override
  Future<String?> getSetting(String key) async {
    final row = await (database.select(
      database.appSettings,
    )..where((table) => table.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  @override
  Future<String> exportSessionsCsv(String deviceId) async {
    final sessions = await loadSessions(deviceId);
    final buffer = StringBuffer(
      'device_id,start_time,end_time,duration_seconds,average_voltage,average_current,max_power,total_ah,total_wh\n',
    );
    for (final session in sessions) {
      buffer.writeln(
        [
          session.deviceId,
          session.startTime.toIso8601String(),
          session.endTime?.toIso8601String() ?? '',
          session.outputDuration.inSeconds,
          session.averageVoltage ?? '',
          session.averageCurrent ?? '',
          session.maxPower ?? '',
          session.totalAh ?? '',
          session.totalWh ?? '',
        ].map(_csvCell).join(','),
      );
    }
    return buffer.toString();
  }

  @override
  Future<String> exportSessionsJson(String deviceId) async {
    final sessions = await loadSessions(deviceId);
    return jsonEncode(
      sessions
          .map(
            (session) => {
              'deviceId': session.deviceId,
              'startTime': session.startTime.toIso8601String(),
              'endTime': session.endTime?.toIso8601String(),
              'durationSeconds': session.outputDuration.inSeconds,
              'averageVoltage': session.averageVoltage,
              'averageCurrent': session.averageCurrent,
              'maxPower': session.maxPower,
              'totalAh': session.totalAh,
              'totalWh': session.totalWh,
            },
          )
          .toList(),
    );
  }

  @override
  Future<String> exportLogsCsv(String deviceId) async {
    final logs = await loadCommunicationLogs(deviceId);
    final buffer = StringBuffer(
      'device_id,timestamp,direction,raw_hex,parsed,success,error\n',
    );
    for (final log in logs) {
      buffer.writeln(
        [
          log.deviceId,
          log.timestamp.toIso8601String(),
          log.direction.name,
          log.rawBytes
              .map(
                (byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase(),
              )
              .join(' '),
          log.parsedMessage ?? '',
          log.success,
          log.error ?? '',
        ].map(_csvCell).join(','),
      );
    }
    return buffer.toString();
  }

  @override
  Future<String> exportLogsJson(String deviceId) async {
    final logs = await loadCommunicationLogs(deviceId);
    return jsonEncode(
      logs
          .map(
            (log) => {
              'deviceId': log.deviceId,
              'timestamp': log.timestamp.toIso8601String(),
              'direction': log.direction.name,
              'rawBytes': log.rawBytes,
              'parsedMessage': log.parsedMessage,
              'success': log.success,
              'error': log.error,
            },
          )
          .toList(),
    );
  }

  static String _csvCell(Object value) {
    final text = value.toString();
    return text.contains(',') || text.contains('"') || text.contains('\n')
        ? '"${text.replaceAll('"', '""')}"'
        : text;
  }

  static List<int> _parseHex(String hex) => hex
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .map((part) => int.tryParse(part, radix: 16) ?? 0)
      .toList();

  static Map<String, Object?> _groupToJson(DataGroup group) => {
    'voltageSet': group.voltageSet,
    'currentSet': group.currentSet,
    'lowVoltageProtection': group.lowVoltageProtection,
    'overVoltageProtection': group.overVoltageProtection,
    'overCurrentProtection': group.overCurrentProtection,
    'overPowerProtection': group.overPowerProtection,
    'maxOutputHours': group.maxOutputHours,
    'maxOutputMinutes': group.maxOutputMinutes,
    'maxOutputAh': group.maxOutputAh,
    'maxOutputWh': group.maxOutputWh,
    'overTemperatureProtection': group.overTemperatureProtection,
    'powerOnOutput': group.powerOnOutput,
    'externalTemperatureProtection': group.externalTemperatureProtection,
  };

  static DataGroup _groupFromJson(
    int index,
    String? name,
    Map<String, dynamic> values,
  ) => DataGroup(
    index: index,
    name: name,
    voltageSet: (values['voltageSet'] as num?)?.toDouble(),
    currentSet: (values['currentSet'] as num?)?.toDouble(),
    lowVoltageProtection: (values['lowVoltageProtection'] as num?)?.toDouble(),
    overVoltageProtection: (values['overVoltageProtection'] as num?)
        ?.toDouble(),
    overCurrentProtection: (values['overCurrentProtection'] as num?)
        ?.toDouble(),
    overPowerProtection: (values['overPowerProtection'] as num?)?.toDouble(),
    maxOutputHours: (values['maxOutputHours'] as num?)?.toInt(),
    maxOutputMinutes: (values['maxOutputMinutes'] as num?)?.toInt(),
    maxOutputAh: (values['maxOutputAh'] as num?)?.toInt(),
    maxOutputWh: (values['maxOutputWh'] as num?)?.toInt(),
    overTemperatureProtection: (values['overTemperatureProtection'] as num?)
        ?.toInt(),
    powerOnOutput: (values['powerOnOutput'] as num?)?.toInt(),
    externalTemperatureProtection:
        (values['externalTemperatureProtection'] as num?)?.toInt(),
  );
}
