import '../models/device_models.dart';

abstract interface class LocalRepository {
  Future<void> saveSample(MeasurementSample sample);
  Future<void> saveSession(OutputSession session);
  Future<List<OutputSession>> loadSessions(String deviceId);
  Future<void> savePreset(Preset preset, {String? deviceId});
  Future<List<Preset>> loadPresets({String? deviceId});
  Future<void> saveGroup(DataGroup group, {required String deviceId});
  Future<List<DataGroup>> loadGroups(String deviceId);
  Future<void> saveCommunicationLog(CommunicationLogEntry entry);
  Future<List<CommunicationLogEntry>> loadCommunicationLogs(String deviceId);
  Future<void> setSetting(String key, String value);
  Future<String?> getSetting(String key);
  Future<String> exportSessionsCsv(String deviceId);
  Future<String> exportSessionsJson(String deviceId);
  Future<String> exportLogsCsv(String deviceId);
  Future<String> exportLogsJson(String deviceId);
}
