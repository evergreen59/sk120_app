import 'dart:async';

import '../models/device_models.dart';
import 'power_device.dart';

class DevicePollingService {
  DevicePollingService({
    required this.device,
    this.interval = const Duration(milliseconds: 750),
    this.sampleInterval = const Duration(seconds: 2),
    this.onSample,
  });

  final PowerDevice device;
  final Duration interval;
  final Duration sampleInterval;
  final void Function(MeasurementSample sample)? onSample;

  Timer? _timer;
  DateTime? _lastSample;
  bool _running = false;

  bool get isRunning => _running;

  Future<void> start() async {
    if (_running) return;
    _running = true;
    _lastSample = null;
    await device.readStatus();
    _timer = Timer.periodic(interval, (_) => _poll());
  }

  Future<void> _poll() async {
    if (!_running || !device.status.isConnected) return;
    final result = await device.readStatus();
    if (result.isFailure) return;
    final now = DateTime.now();
    if (_lastSample == null || now.difference(_lastSample!) >= sampleInterval) {
      _lastSample = now;
      final status = result.value!;
      onSample?.call(
        MeasurementSample(
          deviceId: device.id,
          timestamp: now,
          voltage: status.outputVoltage,
          current: status.outputCurrent,
          power: status.outputPower,
          temperature: status.internalTemperature,
          inputVoltage: status.inputVoltage,
          ah: status.outputAh,
          wh: status.outputWh,
          outputState: status.outputState,
        ),
      );
    }
  }

  Future<void> stop() async {
    _running = false;
    _timer?.cancel();
    _timer = null;
  }

  Future<void> dispose() => stop();
}
