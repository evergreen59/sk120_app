# Repository Guidelines

## Project Structure

This is a Flutter/Dart cross-platform XY-SK120 controller targeting Android, iOS, macOS, Windows, and Linux. Stack: Flutter 3.44.8 / Dart 3.12.2, `flutter_riverpod` 3.4.2, GoRouter 17.3.0 (`StatefulShellRoute`), Drift 2.34.3 + `drift_flutter` 0.3.1 (SQLite), `fl_chart` 1.2.0, `universal_ble` 2.1.1, `file_saver` 0.3.1 (CSV export), and `patrol` 4.9.0 (integration tests). Application code lives in `lib/`:

- `lib/app/` owns the root `MaterialApp`, theme tokens, and GoRouter (`StatefulShellRoute`) navigation.
- `lib/application/` owns Riverpod state: `providers.dart` defines `appModeProvider` and the device/repository wiring by `DeviceMode`.
- `lib/domain/` contains models, services, Modbus protocol code, and repository interfaces.
  - `lib/domain/models/` — `device_models.dart` defines the `DeviceMode { real, mock }` enum and device value models.
  - `lib/domain/services/` — `PowerDeviceService` owns polling, sample/session collection, and reconnect backoff; `RealPowerDevice` / `MockPowerDevice` are the device implementations; `MockPowerDevice` stays isolated and never touches the BLE adapter, Modbus client, or real-device database.
  - `lib/domain/protocol/` — Modbus frames, register definitions (`registers.dart`), `ModbusRequestQueue` (serializes every request so a new BLE write waits for the prior response), and CRC.
  - `lib/domain/repositories/` — repository interfaces (`ble_transport.dart`, `local_repository.dart`).
- `lib/data/` contains Drift persistence, repositories, and BLE transport.
  - `lib/data/database/` — `app_database.dart` plus generated `app_database.g.dart` (regenerate with `build_runner`).
  - `lib/data/repositories/` — Drift-backed `app_repository.dart` and the mock-only `in_memory_repository.dart`.
  - `lib/data/transport/` — `universal_ble_transport.dart` is the only module that owns the fixed BLE service/characteristic UUIDs and talks to `universal_ble`.
- `lib/shared/` contains reusable glass UI, charts, responsive helpers, and widgets.
- `lib/core/` contains cross-cutting `Result` and `AppError` types (under `result/` and `errors/`).
- `lib/features/` contains screens: `control/`, `monitoring/`, `groups/`, `history/`, `settings/`, and `communication_log/`.
- `test/` contains unit, repository, protocol, and widget tests; `test/support/` holds shared fixtures; golden tests (`test/golden/`, `test/layout/`) carry the `golden` tag (excluded in CI coverage runs); `patrol_test/` holds Patrol integration tests.
- `tool/check_coverage.dart` enforces the coverage gate (CI requires line ≥ 70% and branch ≥ 60%).
- Fonts (`assets/fonts/NotoSansCJKsc-VF.otf`, `AppSans` family), the `OFL.txt` license, repo prompt files, and `XY-SK120-Modbus_Address.md` live in `assets/` or the repository root.

## Architecture Layers & Invariants

```text
UI -> Riverpod (DeviceStateNotifier) -> PowerDeviceService -> RealPowerDevice / MockPowerDevice -> ModbusClient -> BleTransport -> XY-SK120
```

The UI never owns UUIDs, register addresses, CRC code, or database queries. `PowerDeviceService` owns polling, sample/session collection, and reconnect backoff. `ModbusRequestQueue` serializes every request so a new BLE write waits for the prior response. The app starts in Real mode and shows the BLE scan view until a device is connected; enable Mock mode from the scan view or Settings when no hardware is available.

Keep BLE UUIDs in the transport layer and register definitions in `lib/domain/protocol/` / `XY-SK120-Modbus_Address.md`.

## Build, Test, and Development Commands

```bash
flutter pub get                              # Resolve dependencies
dart run build_runner build                  # Regenerate Drift code
dart format --output=none --set-exit-if-changed lib test
flutter analyze                              # Static analysis
flutter test --coverage --branch-coverage --exclude-tags golden  # CI-aligned test run
dart run tool/check_coverage.dart coverage/lcov.info --min-line 70 --min-branch 60  # Coverage gate
flutter run                                  # Launch locally (Real mode by default)
flutter build apk --release                  # Android build
flutter build ios --release --no-codesign    # Unsigned iOS build
flutter build macos --release                # macOS build
flutter build windows --release              # Windows build (needs Windows toolchain)
flutter build linux --release                # Linux build (needs Linux toolchain)
```

CI pins Flutter 3.44.8 and also asserts that generated Drift sources are committed unchanged after `build_runner`. Run `dart run build_runner build` and commit any `*.g.dart` changes together with the schema edits. Use Mock mode when hardware is unavailable.

## Coding Style & Naming

Use standard Dart formatting with two-space indentation and trailing commas for multiline widgets. Classes, enums, and public types use `PascalCase`; methods, variables, providers, and files use `camelCase` / `snake_case.dart`. Prefer immutable models, `const` widgets, exhaustive `switch` expressions, and shared design tokens/widgets over page-local styling. Run `dart format` before committing.

## Testing Guidelines

Name tests by behavior, for example `register_test.dart` or `service_test.dart`. Add protocol tests for register parsing, scaling, CRC, word order, split/concatenated/exception responses, quantity (1/32) and address (1/255) boundaries; add widget tests for changed interaction flows. Golden/layout tests under `test/golden/` and `test/layout/` must keep the `golden` tag so CI can exclude them from coverage (`dart_test.yaml` registers the `golden` tag). Shared fixtures live in `test/support/` (`test_app.dart`, `test_power_device.dart`, `ui_fixture.dart`). Patrol integration tests live in `patrol_test/`. Run `flutter analyze` and `flutter test --coverage --branch-coverage --exclude-tags golden` (plus `tool/check_coverage.dart`) before opening a PR.

## Commits & Pull Requests

Use concise imperative commit titles, matching existing history (for example, `Complete SK120 Modbus protocol support`). PRs should explain user-visible and architectural changes, link related issues, include screenshots for UI work, and report analysis, test, and platform-build results. Do not claim hardware behavior without physical XY-SK120 verification.

## Safety & Configuration

Do not guess undocumented Modbus encodings. Preserve unknown/raw values and add extension points instead. Never bypass output-state confirmation, protection checks, reconnect handling, request serialization (`ModbusRequestQueue`), or the separation between UI, services, protocol, transport, and hardware. Mock mode must stay fully isolated — `MockPowerDevice` and `in_memory_repository.dart` must never trigger BLE, Modbus, or the real-device Drift database. Do not move BLE UUIDs out of `lib/data/transport/` or register definitions out of `lib/domain/protocol/`. Generated `*.g.dart` files under `lib/data/database/` are committed; regenerate and commit them together with schema edits.
