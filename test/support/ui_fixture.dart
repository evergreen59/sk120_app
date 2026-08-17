import 'package:xy_sk120_control/domain/models/device_models.dart';
import 'package:xy_sk120_control/domain/services/mock_power_device.dart';
import 'package:xy_sk120_control/domain/services/power_device.dart';

/// Uses the production MockPowerDevice implementation while preventing its
/// app-level auto-connect branch from starting a polling timer in widget tests.
class UiMockPowerDevice extends MockPowerDevice {
  void seedConnectedOutput() => emitStatus(uiConnectedStatus);
}

class UiMockPowerDeviceService extends PowerDeviceService {
  UiMockPowerDeviceService(super.device);

  // DeviceStateNotifier auto-connects mock services. The seeded status is
  // already connected, so expose a real-mode test boundary to keep the frame
  // matrix timer-free without changing production behavior.
  @override
  DeviceMode get mode => DeviceMode.real;
}

const uiConnectedStatus = DeviceStatus(
  connectionState: DeviceConnectionState.connected,
  outputState: OutputState.on,
  cvccState: CvccState.cv,
  protectionStatus: ProtectionStatus.normal,
  protectionRaw: 0,
  keyLocked: false,
  backlightLevel: 3,
  voltageSet: 12,
  currentSet: 1.25,
  outputVoltage: 11.995,
  outputCurrent: 1.251,
  outputPower: 15,
  inputVoltage: 24.1,
  outputAh: 1250,
  outputWh: 32,
  outputDuration: Duration(minutes: 2, seconds: 35),
  internalTemperature: 32.5,
  externalTemperature: 28,
  model: 'XY-SK120 Mock',
  firmwareVersion: 'demo-1.0',
  slaveAddress: 1,
  baudRate: DeviceBaudRate.baud115200,
  baudRateRaw: 6,
  mpptEnabled: false,
  mpptCoefficient: 0,
  constantPowerEnabled: false,
  constantPowerValue: 0,
);
