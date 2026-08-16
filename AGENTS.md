# Repository Guidelines

## Project Structure

This is a Flutter/Dart cross-platform XY-SK120 controller. Application code lives in `lib/`:

- `lib/features/` contains screens for control, monitoring, groups, history, settings, and logs.
- `lib/application/` owns Riverpod state and orchestration.
- `lib/domain/` contains models, services, Modbus protocol code, and repository interfaces.
- `lib/data/` contains Drift persistence, repositories, and BLE transport.
- `lib/shared/` contains reusable glass UI, charts, responsive helpers, and widgets.
- `test/` contains unit, repository, protocol, and widget tests; fonts and license files are in `assets/`.

Keep BLE UUIDs in the transport layer and register definitions in `lib/domain/protocol/` / `XY-SK120-Modbus_Address.md`.

## Build, Test, and Development Commands

```bash
flutter pub get                              # Resolve dependencies
dart run build_runner build                  # Regenerate Drift code
dart format --output=none --set-exit-if-changed lib test
flutter analyze                              # Static analysis
flutter test --coverage                      # Run the full test suite
flutter run                                  # Launch locally (Real mode by default)
flutter build apk --release                  # Android build
flutter build ios --release --no-codesign    # Unsigned iOS build
flutter build macos --release                # macOS build
```

Windows and Linux builds require their native host toolchains. Use Mock mode when hardware is unavailable.

## Coding Style & Naming

Use standard Dart formatting with two-space indentation and trailing commas for multiline widgets. Classes, enums, and public types use `PascalCase`; methods, variables, providers, and files use `camelCase` / `snake_case.dart`. Prefer immutable models, `const` widgets, exhaustive `switch` expressions, and shared design tokens/widgets over page-local styling. Run `dart format` before committing.

## Testing Guidelines

Name tests by behavior, for example `register_test.dart` or `service_test.dart`. Add protocol tests for register parsing, scaling, CRC, validation, and safety boundaries; add widget tests for changed interaction flows. Run `flutter analyze` and `flutter test --coverage` before opening a PR.

## Commits & Pull Requests

Use concise imperative commit titles, matching existing history (for example, `Complete SK120 Modbus protocol support`). PRs should explain user-visible and architectural changes, link related issues, include screenshots for UI work, and report analysis, test, and platform-build results. Do not claim hardware behavior without physical XY-SK120 verification.

## Safety & Configuration

Do not guess undocumented Modbus encodings. Preserve unknown/raw values and add extension points instead. Never bypass output-state confirmation, protection checks, reconnect handling, or the separation between UI, services, protocol, transport, and hardware.
