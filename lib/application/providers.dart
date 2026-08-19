import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/result/result.dart';
import '../data/database/app_database.dart' hide MeasurementSample;
import '../data/repositories/app_repository.dart';
import '../data/repositories/in_memory_repository.dart';
import '../data/transport/universal_ble_transport.dart';
import '../domain/models/device_models.dart';
import '../domain/protocol/modbus_client.dart';
import '../domain/protocol/registers.dart';
import '../domain/repositories/local_repository.dart';
import '../domain/services/mock_power_device.dart';
import '../domain/services/power_device.dart';
import '../domain/services/real_power_device.dart';

final databaseProvider = Provider<Sk120Database>((ref) {
  final database = Sk120Database();
  ref.onDispose(() => unawaited(database.close()));
  return database;
});

final localRepositoryProvider = Provider<LocalRepository>((ref) {
  if (ref.watch(appModeProvider) == DeviceMode.mock) {
    return InMemoryRepository();
  }
  return AppRepository(ref.watch(databaseProvider));
});

final appModeProvider = NotifierProvider<AppModeNotifier, DeviceMode>(
  AppModeNotifier.new,
);

class AppModeNotifier extends Notifier<DeviceMode> {
  @override
  DeviceMode build() => DeviceMode.real;

  void setMode(DeviceMode mode) {
    if (state == mode) return;
    state = mode;
  }
}

final powerDeviceServiceProvider = Provider<PowerDeviceService>((ref) {
  final mode = ref.watch(appModeProvider);
  final repository = ref.watch(localRepositoryProvider);
  UniversalBleTransport? transport;
  final PowerDevice device;
  if (mode == DeviceMode.mock) {
    device = MockPowerDevice();
  } else {
    transport = UniversalBleTransport();
    final client = ModbusClient(
      transport: transport,
      deviceId: 'xy-sk120',
      onLog: (entry) => unawaited(repository.saveCommunicationLog(entry)),
    );
    device = RealPowerDevice(transport: transport, client: client);
  }
  final service = PowerDeviceService(
    device,
    onSample: (sample) {
      unawaited(repository.saveSample(sample));
    },
    onSession: (session) {
      unawaited(repository.saveSession(session));
    },
  );
  ref.onDispose(() {
    unawaited(service.dispose());
    final adapter = transport;
    if (adapter != null) unawaited(adapter.dispose());
  });
  return service;
});

class DeviceUiState {
  const DeviceUiState({
    required this.status,
    required this.mode,
    this.scanning = false,
    this.busy = false,
    this.discoveredDevices = const [],
    this.favoriteDeviceIds = const {},
    this.groups = const [],
    this.samples = const [],
    this.errorMessage,
  });

  final DeviceStatus status;
  final DeviceMode mode;
  final bool scanning;
  final bool busy;
  final List<BleDeviceInfo> discoveredDevices;
  final Set<String> favoriteDeviceIds;
  final List<DataGroup> groups;
  final List<MeasurementSample> samples;
  final String? errorMessage;

  DeviceUiState copyWith({
    DeviceStatus? status,
    DeviceMode? mode,
    bool? scanning,
    bool? busy,
    List<BleDeviceInfo>? discoveredDevices,
    Set<String>? favoriteDeviceIds,
    List<DataGroup>? groups,
    List<MeasurementSample>? samples,
    String? errorMessage,
    bool clearError = false,
  }) => DeviceUiState(
    status: status ?? this.status,
    mode: mode ?? this.mode,
    scanning: scanning ?? this.scanning,
    busy: busy ?? this.busy,
    discoveredDevices: discoveredDevices ?? this.discoveredDevices,
    favoriteDeviceIds: favoriteDeviceIds ?? this.favoriteDeviceIds,
    groups: groups ?? this.groups,
    samples: samples ?? this.samples,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}

final deviceStateProvider =
    NotifierProvider<DeviceStateNotifier, DeviceUiState>(
      DeviceStateNotifier.new,
    );

class DeviceStateNotifier extends Notifier<DeviceUiState> {
  static const _favoriteDeviceIdsSettingKey = 'favorite_ble_device_ids';

  late PowerDeviceService _service;
  StreamSubscription<DeviceStatus>? _statusSubscription;
  StreamSubscription<MeasurementSample>? _sampleSubscription;
  StreamSubscription<BleDeviceInfo>? _scanSubscription;
  Timer? _scanTimeout;
  Future<void>? _favoritesRestore;

  @override
  DeviceUiState build() {
    _service = ref.watch(powerDeviceServiceProvider);
    _statusSubscription = _service.statusStream.listen((status) {
      state = state.copyWith(status: status, clearError: true);
    });
    _sampleSubscription = _service.sampleStream.listen((sample) {
      final samples = [...state.samples, sample];
      if (samples.length > 600) samples.removeRange(0, samples.length - 600);
      state = state.copyWith(samples: samples);
    });
    ref.onDispose(() {
      _scanTimeout?.cancel();
      unawaited(_statusSubscription?.cancel());
      unawaited(_sampleSubscription?.cancel());
      unawaited(_scanSubscription?.cancel());
    });
    final initial = DeviceUiState(
      status: _service.status,
      mode: _service.mode,
      groups: List<DataGroup>.generate(
        10,
        (index) => DataGroup(index: index, name: 'M$index'),
      ),
    );
    unawaited(_restoreLocalGroups());
    _favoritesRestore = _restoreFavoriteDevices();
    if (_service.mode == DeviceMode.mock) {
      unawaited(Future<void>.microtask(() => connect()));
    }
    return initial;
  }

  Future<void> _restoreLocalGroups() async {
    final saved = await ref
        .read(localRepositoryProvider)
        .loadGroups(_service.id);
    if (saved.isEmpty) return;
    final groups = [...state.groups];
    for (final group in saved) {
      if (group.index >= 0 && group.index < groups.length) {
        groups[group.index] = groups[group.index].copyWith(name: group.name);
      }
    }
    state = state.copyWith(groups: groups);
  }

  Future<void> _restoreFavoriteDevices() async {
    final encoded = await ref
        .read(localRepositoryProvider)
        .getSetting(_favoriteDeviceIdsSettingKey);
    if (encoded == null || encoded.isEmpty) return;
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! List) return;
      final favorites = decoded.whereType<String>().toSet();
      state = state.copyWith(
        favoriteDeviceIds: favorites,
        discoveredDevices: sortDiscoveredDevices(
          state.discoveredDevices,
          favorites,
        ),
      );
    } on FormatException {
      // Ignore malformed local settings and start with an empty collection.
    }
  }

  Future<void> toggleFavoriteDevice(String deviceId) async {
    await _favoritesRestore;
    final previous = state.favoriteDeviceIds;
    final favorites = {...previous};
    if (!favorites.add(deviceId)) favorites.remove(deviceId);
    state = state.copyWith(
      favoriteDeviceIds: favorites,
      discoveredDevices: sortDiscoveredDevices(
        state.discoveredDevices,
        favorites,
      ),
      clearError: true,
    );
    try {
      final sortedIds = favorites.toList()..sort();
      await ref
          .read(localRepositoryProvider)
          .setSetting(_favoriteDeviceIdsSettingKey, jsonEncode(sortedIds));
    } catch (error) {
      state = state.copyWith(
        favoriteDeviceIds: previous,
        discoveredDevices: sortDiscoveredDevices(
          state.discoveredDevices,
          previous,
        ),
        errorMessage: '保存收藏设备失败：$error',
      );
    }
  }

  Future<void> startScan() async {
    _scanTimeout?.cancel();
    await _service.stopScan();
    await _scanSubscription?.cancel();
    state = state.copyWith(
      scanning: true,
      discoveredDevices: const [],
      clearError: true,
    );
    _scanSubscription = _service.scan().listen(
      (device) {
        final current = [...state.discoveredDevices];
        final index = current.indexWhere((item) => item.id == device.id);
        if (index == -1) {
          current.add(device);
        } else {
          current[index] = device;
        }
        state = state.copyWith(
          discoveredDevices: sortDiscoveredDevices(
            current,
            state.favoriteDeviceIds,
          ),
        );
      },
      onError: (Object error) =>
          state = state.copyWith(scanning: false, errorMessage: '扫描失败：$error'),
    );
    _scanTimeout = Timer(const Duration(seconds: 12), () async {
      await stopScan();
    });
  }

  Future<void> stopScan() async {
    _scanTimeout?.cancel();
    _scanTimeout = null;
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    await _service.stopScan();
    state = state.copyWith(scanning: false);
  }

  Future<void> connect({String? deviceId}) async {
    await stopScan();
    state = state.copyWith(busy: true, clearError: true);
    final result = await _service.connect(deviceId: deviceId);
    String? groupError;
    if (result.isSuccess) {
      // Modbus requests must be serialized; read M0-M9 in order.
      for (var index = 0; index < RegisterCatalog.dataGroupCount; index++) {
        final groupResult = await _service.readDataGroup(index);
        if (groupResult.isSuccess) {
          final existing = state.groups[index];
          final loaded = groupResult.value!.copyWith(name: existing.name);
          final groups = [...state.groups]..[index] = loaded;
          state = state.copyWith(groups: groups);
          unawaited(
            ref
                .read(localRepositoryProvider)
                .saveGroup(loaded, deviceId: _service.id),
          );
        } else {
          groupError ??= '读取 M$index 失败：${groupResult.error?.message ?? ''}';
        }
      }
    }
    state = state.copyWith(
      busy: false,
      status: _service.status,
      errorMessage: result.error?.message ?? groupError,
      clearError: result.isSuccess && groupError == null,
    );
  }

  Future<void> refresh() async {
    state = state.copyWith(busy: true, clearError: true);
    final result = await _service.readStatus();
    state = state.copyWith(
      busy: false,
      status: _service.status,
      errorMessage: result.error?.message,
      clearError: result.isSuccess,
    );
  }

  void clearError() => state = state.copyWith(clearError: true);
  void clearSamples() => state = state.copyWith(samples: const []);

  Future<void> disconnect() async {
    state = state.copyWith(busy: true, clearError: true);
    final result = await _service.disconnect();
    state = state.copyWith(
      busy: false,
      status: _service.status,
      errorMessage: result.error?.message,
      clearError: result.isSuccess,
    );
  }

  Future<void> setVoltage(double value) =>
      _run(() => _service.setVoltage(value));
  Future<void> setCurrent(double value) =>
      _run(() => _service.setCurrent(value));
  Future<void> setOutput(bool enabled) =>
      _run(() => _service.setOutput(enabled));
  Future<void> setBuzzer(bool enabled) =>
      _run(() => _service.setBuzzer(enabled));
  Future<void> setKeyLock(bool locked) =>
      _run(() => _service.setKeyLock(locked));
  Future<void> setBacklight(int level) =>
      _run(() => _service.setBacklight(level));
  Future<void> setSleepMinutes(int minutes) =>
      _run(() => _service.setSleepMinutes(minutes));
  Future<void> setSlaveAddress(int address) =>
      _run(() => _service.setSlaveAddress(address));
  Future<void> setBaudRate(DeviceBaudRate baudRate) =>
      _run(() => _service.setBaudRate(baudRate));
  Future<void> setMppt({required bool enabled, int? coefficient}) =>
      _run(() => _service.setMppt(enabled: enabled, coefficient: coefficient));
  Future<void> setConstantPower({
    required bool enabled,
    required double watts,
  }) => _run(() => _service.setConstantPower(enabled: enabled, watts: watts));

  Future<DataGroup?> readGroup(int index) async {
    state = state.copyWith(busy: true, clearError: true);
    final result = await _service.readDataGroup(index);
    if (result.isSuccess) {
      final groups = [...state.groups];
      final loaded = result.value!.copyWith(name: groups[index].name);
      groups[index] = loaded;
      unawaited(
        ref
            .read(localRepositoryProvider)
            .saveGroup(loaded, deviceId: _service.id),
      );
      state = state.copyWith(groups: groups, busy: false);
      return loaded;
    } else {
      state = state.copyWith(busy: false, errorMessage: result.error?.message);
      return null;
    }
  }

  Future<void> writeGroup(DataGroup group) async {
    state = state.copyWith(busy: true, clearError: true);
    final result = await _service.writeDataGroup(group);
    if (result.isSuccess) {
      final groups = [...state.groups];
      groups[group.index] = group;
      unawaited(
        ref
            .read(localRepositoryProvider)
            .saveGroup(group, deviceId: _service.id),
      );
      state = state.copyWith(groups: groups, busy: false);
    } else {
      state = state.copyWith(busy: false, errorMessage: result.error?.message);
    }
  }

  Future<void> activateGroup(int index) async {
    await _run(() => _service.activateDataGroup(index));
  }

  Future<void> _run(Future<Result<void>> Function() operation) async {
    state = state.copyWith(busy: true, clearError: true);
    final result = await operation();
    state = state.copyWith(
      busy: false,
      status: _service.status,
      errorMessage: result.error?.message,
      clearError: result.isSuccess,
    );
  }
}

List<BleDeviceInfo> sortDiscoveredDevices(
  Iterable<BleDeviceInfo> devices,
  Set<String> favoriteDeviceIds,
) {
  final sorted = devices.toList();
  sorted.sort((first, second) {
    final firstFavorite = favoriteDeviceIds.contains(first.id);
    final secondFavorite = favoriteDeviceIds.contains(second.id);
    if (firstFavorite != secondFavorite) return firstFavorite ? -1 : 1;

    final firstNamed = _hasDeviceName(first);
    final secondNamed = _hasDeviceName(second);
    if (firstNamed != secondNamed) return firstNamed ? -1 : 1;

    final signalComparison = (second.rssi ?? -999).compareTo(
      first.rssi ?? -999,
    );
    if (signalComparison != 0) return signalComparison;
    return first.id.compareTo(second.id);
  });
  return sorted;
}

bool _hasDeviceName(BleDeviceInfo device) {
  final name = device.name.trim();
  return name.isNotEmpty && name != '未命名 BLE 设备';
}
