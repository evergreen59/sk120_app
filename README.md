# XY-SK120 Control

XY-SK120 Control is a Flutter 3.44.8 / Dart 3.12.2 cross-platform console for XY-SK120 power supplies. It targets Android, iOS, macOS, Windows and Linux and keeps presentation, application state, device service, Modbus and BLE transport separate.

## Stack

- Flutter 3.44.8, Dart 3.12.2
- Riverpod 3.4.2
- GoRouter 17.3.0 with `StatefulShellRoute`
- Drift 2.34.3 + SQLite
- `fl_chart` 1.2.0
- `universal_ble` 2.1.1

## Architecture

```text
UI
  -> Riverpod DeviceStateNotifier
  -> PowerDeviceService
  -> RealPowerDevice / MockPowerDevice
  -> ModbusClient
  -> BleTransport
  -> XY-SK120
```

The UI never owns UUIDs, register addresses, CRC code or database queries. `PowerDeviceService` owns polling, sample/session collection and reconnect backoff. `ModbusRequestQueue` serializes every request so a new BLE write waits for the prior response.

## Run

```bash
flutter pub get
dart run build_runner build
flutter run
```

The app starts in Real mode and shows the BLE scan view until a device is connected. Enable Mock mode from the scan view or Settings when no hardware is available. Mock mode uses an isolated in-memory device and repository and never calls the BLE adapter, Modbus client or real-device database.

## BLE and platform permissions

The real transport is the only location containing the fixed BLE identifiers:

- Service: `FFE0`
- Notify / fallback write: `FFE1`
- Primary write: `FFE2`

Android declares `BLUETOOTH_SCAN` / `BLUETOOTH_CONNECT` for Android 12+, the legacy Bluetooth permissions for Android 11 and below, and location permissions limited to the Android versions that require them for BLE discovery. Runtime requests use the Nearby devices permission group on Android 12+ and do not request location there.

iOS and macOS include Bluetooth usage descriptions; macOS Debug/Profile and Release entitlements both include the Bluetooth capability. Windows and Linux require no BLE runtime permission prompt. A packaged Windows release must declare the `bluetooth` and `radios` capabilities in its package manifest. A Linux Snap must declare and connect the `bluez` plug; unpackaged Linux builds depend on the host BlueZ/DBus policy.

The generated application id is `com.example.xy_sk120_control`; replace it before publishing.

## Modbus and register source

Register addresses, scale factors, access flags and M0-M9 layout come from [`XY-SK120-Modbus_Address.md`](XY-SK120-Modbus_Address.md). The implementation provides function codes `0x03`, `0x06` and `0x10`, big-endian register words and CRC16 with initial `0xFFFF`, polynomial `0xA001`, and low CRC byte first on the wire. Requests enforce the device limits of 1-32 registers and slave addresses 1-255. The default address is 1 and the default port rate is 115200 baud.

The safety range enforced by both domain and UI is 0-36 V, 0-5 A and 0-120 W. Status refreshes are split into `0x0000`-`0x001F` and `0x0020`-`0x0023`; both reads must succeed before a new status is published. `LOCK`, `PROTECT`, `CVCC`, `ONOFF` and the six `B-LED` levels are decoded according to the manual. `BAUDRATE_L` is treated as an enum code from 0 through 8; code 5 is interpreted as 57600 despite the manual's apparent `576000` typo, and codes 7/8 are marked as partially supported. Unknown protection and baud-rate codes retain their raw value for diagnostics.

The manual says each M0-M9 group contains 14 values but its table lists 15 registers. Reads therefore cover all 15 documented registers. Ordinary writes conservatively cover `0x0050`-`0x005D`; `S-ETP` at `0x005E` remains excluded. Saving a group writes its storage slot. Calling a group is a separate operation that reads and previews the slot, requires confirmation, writes only the group number to `EXTRACT-M` (`0x001D`), and then refreshes current status. The protocol does not guarantee that calling a group preserves output state, so calls are allowed only while output is confirmed off.

## Unknown protocol fields

The following remain explicit raw/extension points until confirmed against a real XY-SK120:

- `F-C` temperature encoding
- model and firmware word encoding
- `BUZZER`, `MPPT`, `BatFul`, `CW`, `S-INI` and `S-ETP` value semantics
- calibration, self-calibration, OZONE and Wi-Fi registers that are absent from the newer manual
- AH/WH units and rollover behavior beyond the documented high/low word composition

Unknown output state is displayed as Unknown and is never rendered as OFF. Temperatures use the manual's neutral `F/C` unit until `F-C` is confirmed. Calibration, OZONE and other engineering registers are not exposed as ordinary write controls.

## Local data

Drift tables cover devices, presets, measurement samples, output sessions, device groups, communication logs and app settings. The History and Engineering pages expose CSV/JSON export text for copying; the repository also provides export methods for integrating a native file/share surface later.

## Tests and generation

```bash
dart run build_runner build
flutter analyze
flutter test
```

Tests cover all three manual communication examples byte for byte, CRC and word order, split/concatenated/exception responses, request serialization, 1/32 quantity and 1/255 address boundaries, atomic split status refresh, decoded protocol states, data-group save/call separation, Mock safety behavior, settings/group widgets, Drift CRUD and export round trips, and the responsive shell.

## Builds

```bash
flutter build apk
flutter build ios --no-codesign
flutter build macos
flutter build windows
flutter build linux
```

Android APK, unsigned iOS and macOS builds can be verified on a macOS host. Windows and Linux native builds require their respective host toolchains and are generated here but must be validated on Windows/Linux. iOS and macOS signing, bundle identifiers, provisioning and production Bluetooth permissions remain release configuration work.

## Real-device checklist

Before release, verify UUID discovery, notification fragmentation and coalescing, read/write echo behavior, Modbus exception and timeout handling, disconnect/reconnect behavior, polling stability and all five platform permission prompts with a physical device. Protocol-specific checks still required are: all 12 protection codes; slave addresses 248-255; baud code 5 as 57600; optional 2400/4800 rates; M0-M9 save and call behavior; output state after `EXTRACT-M`; and BLE behavior after changing serial parameters.
