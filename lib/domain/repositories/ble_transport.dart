import '../../core/result/result.dart';
import '../models/device_models.dart';

abstract interface class BleTransport {
  Stream<List<int>> get incomingBytes;
  Stream<DeviceConnectionState> get connectionStates;

  Stream<BleDeviceInfo> scan();
  Future<Result<void>> stopScan();
  Future<Result<void>> connect(String deviceId);
  Future<Result<void>> disconnect();
  Future<Result<void>> reconnect(String deviceId);
  Future<Result<void>> writeFrame(List<int> bytes);
  Future<Result<void>> subscribe();
  Future<Result<void>> discoverServices();
}
