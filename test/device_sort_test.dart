import 'package:flutter_test/flutter_test.dart';
import 'package:xy_sk120_control/application/providers.dart';
import 'package:xy_sk120_control/domain/models/device_models.dart';

void main() {
  const namedWeak = BleDeviceInfo(id: 'named-weak', name: 'Power', rssi: -80);
  const namedStrong = BleDeviceInfo(
    id: 'named-strong',
    name: 'Meter',
    rssi: -40,
  );
  const unnamedStrong = BleDeviceInfo(
    id: 'unnamed-strong',
    name: '未命名 BLE 设备',
    rssi: -20,
  );
  const unnamedUnknown = BleDeviceInfo(id: 'unnamed-unknown', name: '');

  test('puts named devices before unnamed devices then sorts by signal', () {
    final sorted = sortDiscoveredDevices([
      unnamedStrong,
      namedWeak,
      unnamedUnknown,
      namedStrong,
    ], const {});

    expect(sorted.map((device) => device.id), [
      'named-strong',
      'named-weak',
      'unnamed-strong',
      'unnamed-unknown',
    ]);
  });

  test('puts favorites above name and signal ordering', () {
    final sorted = sortDiscoveredDevices(
      [namedStrong, unnamedUnknown, namedWeak, unnamedStrong],
      const {'unnamed-unknown', 'named-weak'},
    );

    expect(sorted.map((device) => device.id), [
      'named-weak',
      'unnamed-unknown',
      'named-strong',
      'unnamed-strong',
    ]);
  });
}
