import 'package:flutter_test/flutter_test.dart';
import 'package:xy_sk120_control/data/transport/universal_ble_transport.dart';

void main() {
  group('BLE UUID matching', () {
    test('matches 16-bit UUIDs against Bluetooth base UUIDs', () {
      expect(
        bleUuidsEqual('0000ffe0-0000-1000-8000-00805f9b34fb', 'FFE0'),
        isTrue,
      );
      expect(
        bleUuidsEqual('0000ffe1-0000-1000-8000-00805f9b34fb', 'FFE1'),
        isTrue,
      );
      expect(
        bleUuidsEqual('0000ffe2-0000-1000-8000-00805f9b34fb', 'FFE2'),
        isTrue,
      );
    });

    test('accepts equivalent case, braces and compact forms', () {
      expect(
        bleUuidsEqual('{0000FFE0-0000-1000-8000-00805F9B34FB}', 'ffe0'),
        isTrue,
      );
      expect(bleUuidsEqual('0000ffe000001000800000805f9b34fb', 'FFE0'), isTrue);
    });

    test('does not confuse adjacent service and characteristic UUIDs', () {
      expect(
        bleUuidsEqual('0000ffe1-0000-1000-8000-00805f9b34fb', 'FFE0'),
        isFalse,
      );
    });
  });
}
