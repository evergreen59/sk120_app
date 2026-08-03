// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DevicesTable extends Devices with TableInfo<$DevicesTable, Device> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firmwareVersionMeta = const VerificationMeta(
    'firmwareVersion',
  );
  @override
  late final GeneratedColumn<String> firmwareVersion = GeneratedColumn<String>(
    'firmware_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bleDeviceIdMeta = const VerificationMeta(
    'bleDeviceId',
  );
  @override
  late final GeneratedColumn<String> bleDeviceId = GeneratedColumn<String>(
    'ble_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastRssiMeta = const VerificationMeta(
    'lastRssi',
  );
  @override
  late final GeneratedColumn<int> lastRssi = GeneratedColumn<int>(
    'last_rssi',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSeenMeta = const VerificationMeta(
    'lastSeen',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeen = GeneratedColumn<DateTime>(
    'last_seen',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    model,
    firmwareVersion,
    bleDeviceId,
    lastRssi,
    lastSeen,
    createdAt,
    mode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<Device> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    }
    if (data.containsKey('firmware_version')) {
      context.handle(
        _firmwareVersionMeta,
        firmwareVersion.isAcceptableOrUnknown(
          data['firmware_version']!,
          _firmwareVersionMeta,
        ),
      );
    }
    if (data.containsKey('ble_device_id')) {
      context.handle(
        _bleDeviceIdMeta,
        bleDeviceId.isAcceptableOrUnknown(
          data['ble_device_id']!,
          _bleDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('last_rssi')) {
      context.handle(
        _lastRssiMeta,
        lastRssi.isAcceptableOrUnknown(data['last_rssi']!, _lastRssiMeta),
      );
    }
    if (data.containsKey('last_seen')) {
      context.handle(
        _lastSeenMeta,
        lastSeen.isAcceptableOrUnknown(data['last_seen']!, _lastSeenMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Device map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Device(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      ),
      firmwareVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}firmware_version'],
      ),
      bleDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ble_device_id'],
      ),
      lastRssi: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_rssi'],
      ),
      lastSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }
}

class Device extends DataClass implements Insertable<Device> {
  final String id;
  final String name;
  final String? model;
  final String? firmwareVersion;
  final String? bleDeviceId;
  final int? lastRssi;
  final DateTime? lastSeen;
  final DateTime createdAt;
  final String mode;
  const Device({
    required this.id,
    required this.name,
    this.model,
    this.firmwareVersion,
    this.bleDeviceId,
    this.lastRssi,
    this.lastSeen,
    required this.createdAt,
    required this.mode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || model != null) {
      map['model'] = Variable<String>(model);
    }
    if (!nullToAbsent || firmwareVersion != null) {
      map['firmware_version'] = Variable<String>(firmwareVersion);
    }
    if (!nullToAbsent || bleDeviceId != null) {
      map['ble_device_id'] = Variable<String>(bleDeviceId);
    }
    if (!nullToAbsent || lastRssi != null) {
      map['last_rssi'] = Variable<int>(lastRssi);
    }
    if (!nullToAbsent || lastSeen != null) {
      map['last_seen'] = Variable<DateTime>(lastSeen);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['mode'] = Variable<String>(mode);
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      name: Value(name),
      model: model == null && nullToAbsent
          ? const Value.absent()
          : Value(model),
      firmwareVersion: firmwareVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(firmwareVersion),
      bleDeviceId: bleDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(bleDeviceId),
      lastRssi: lastRssi == null && nullToAbsent
          ? const Value.absent()
          : Value(lastRssi),
      lastSeen: lastSeen == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeen),
      createdAt: Value(createdAt),
      mode: Value(mode),
    );
  }

  factory Device.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Device(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      model: serializer.fromJson<String?>(json['model']),
      firmwareVersion: serializer.fromJson<String?>(json['firmwareVersion']),
      bleDeviceId: serializer.fromJson<String?>(json['bleDeviceId']),
      lastRssi: serializer.fromJson<int?>(json['lastRssi']),
      lastSeen: serializer.fromJson<DateTime?>(json['lastSeen']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      mode: serializer.fromJson<String>(json['mode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'model': serializer.toJson<String?>(model),
      'firmwareVersion': serializer.toJson<String?>(firmwareVersion),
      'bleDeviceId': serializer.toJson<String?>(bleDeviceId),
      'lastRssi': serializer.toJson<int?>(lastRssi),
      'lastSeen': serializer.toJson<DateTime?>(lastSeen),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'mode': serializer.toJson<String>(mode),
    };
  }

  Device copyWith({
    String? id,
    String? name,
    Value<String?> model = const Value.absent(),
    Value<String?> firmwareVersion = const Value.absent(),
    Value<String?> bleDeviceId = const Value.absent(),
    Value<int?> lastRssi = const Value.absent(),
    Value<DateTime?> lastSeen = const Value.absent(),
    DateTime? createdAt,
    String? mode,
  }) => Device(
    id: id ?? this.id,
    name: name ?? this.name,
    model: model.present ? model.value : this.model,
    firmwareVersion: firmwareVersion.present
        ? firmwareVersion.value
        : this.firmwareVersion,
    bleDeviceId: bleDeviceId.present ? bleDeviceId.value : this.bleDeviceId,
    lastRssi: lastRssi.present ? lastRssi.value : this.lastRssi,
    lastSeen: lastSeen.present ? lastSeen.value : this.lastSeen,
    createdAt: createdAt ?? this.createdAt,
    mode: mode ?? this.mode,
  );
  Device copyWithCompanion(DevicesCompanion data) {
    return Device(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      model: data.model.present ? data.model.value : this.model,
      firmwareVersion: data.firmwareVersion.present
          ? data.firmwareVersion.value
          : this.firmwareVersion,
      bleDeviceId: data.bleDeviceId.present
          ? data.bleDeviceId.value
          : this.bleDeviceId,
      lastRssi: data.lastRssi.present ? data.lastRssi.value : this.lastRssi,
      lastSeen: data.lastSeen.present ? data.lastSeen.value : this.lastSeen,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      mode: data.mode.present ? data.mode.value : this.mode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Device(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('model: $model, ')
          ..write('firmwareVersion: $firmwareVersion, ')
          ..write('bleDeviceId: $bleDeviceId, ')
          ..write('lastRssi: $lastRssi, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('createdAt: $createdAt, ')
          ..write('mode: $mode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    model,
    firmwareVersion,
    bleDeviceId,
    lastRssi,
    lastSeen,
    createdAt,
    mode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Device &&
          other.id == this.id &&
          other.name == this.name &&
          other.model == this.model &&
          other.firmwareVersion == this.firmwareVersion &&
          other.bleDeviceId == this.bleDeviceId &&
          other.lastRssi == this.lastRssi &&
          other.lastSeen == this.lastSeen &&
          other.createdAt == this.createdAt &&
          other.mode == this.mode);
}

class DevicesCompanion extends UpdateCompanion<Device> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> model;
  final Value<String?> firmwareVersion;
  final Value<String?> bleDeviceId;
  final Value<int?> lastRssi;
  final Value<DateTime?> lastSeen;
  final Value<DateTime> createdAt;
  final Value<String> mode;
  final Value<int> rowid;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.model = const Value.absent(),
    this.firmwareVersion = const Value.absent(),
    this.bleDeviceId = const Value.absent(),
    this.lastRssi = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.mode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesCompanion.insert({
    required String id,
    required String name,
    this.model = const Value.absent(),
    this.firmwareVersion = const Value.absent(),
    this.bleDeviceId = const Value.absent(),
    this.lastRssi = const Value.absent(),
    this.lastSeen = const Value.absent(),
    required DateTime createdAt,
    required String mode,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       mode = Value(mode);
  static Insertable<Device> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? model,
    Expression<String>? firmwareVersion,
    Expression<String>? bleDeviceId,
    Expression<int>? lastRssi,
    Expression<DateTime>? lastSeen,
    Expression<DateTime>? createdAt,
    Expression<String>? mode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (model != null) 'model': model,
      if (firmwareVersion != null) 'firmware_version': firmwareVersion,
      if (bleDeviceId != null) 'ble_device_id': bleDeviceId,
      if (lastRssi != null) 'last_rssi': lastRssi,
      if (lastSeen != null) 'last_seen': lastSeen,
      if (createdAt != null) 'created_at': createdAt,
      if (mode != null) 'mode': mode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? model,
    Value<String?>? firmwareVersion,
    Value<String?>? bleDeviceId,
    Value<int?>? lastRssi,
    Value<DateTime?>? lastSeen,
    Value<DateTime>? createdAt,
    Value<String>? mode,
    Value<int>? rowid,
  }) {
    return DevicesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      model: model ?? this.model,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      bleDeviceId: bleDeviceId ?? this.bleDeviceId,
      lastRssi: lastRssi ?? this.lastRssi,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      mode: mode ?? this.mode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (firmwareVersion.present) {
      map['firmware_version'] = Variable<String>(firmwareVersion.value);
    }
    if (bleDeviceId.present) {
      map['ble_device_id'] = Variable<String>(bleDeviceId.value);
    }
    if (lastRssi.present) {
      map['last_rssi'] = Variable<int>(lastRssi.value);
    }
    if (lastSeen.present) {
      map['last_seen'] = Variable<DateTime>(lastSeen.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('model: $model, ')
          ..write('firmwareVersion: $firmwareVersion, ')
          ..write('bleDeviceId: $bleDeviceId, ')
          ..write('lastRssi: $lastRssi, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('createdAt: $createdAt, ')
          ..write('mode: $mode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PresetsTable extends Presets with TableInfo<$PresetsTable, Preset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PresetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _voltageMeta = const VerificationMeta(
    'voltage',
  );
  @override
  late final GeneratedColumn<double> voltage = GeneratedColumn<double>(
    'voltage',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentMeta = const VerificationMeta(
    'current',
  );
  @override
  late final GeneratedColumn<double> current = GeneratedColumn<double>(
    'current',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    name,
    voltage,
    current,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'presets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Preset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('voltage')) {
      context.handle(
        _voltageMeta,
        voltage.isAcceptableOrUnknown(data['voltage']!, _voltageMeta),
      );
    } else if (isInserting) {
      context.missing(_voltageMeta);
    }
    if (data.containsKey('current')) {
      context.handle(
        _currentMeta,
        current.isAcceptableOrUnknown(data['current']!, _currentMeta),
      );
    } else if (isInserting) {
      context.missing(_currentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Preset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Preset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      voltage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}voltage'],
      )!,
      current: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PresetsTable createAlias(String alias) {
    return $PresetsTable(attachedDatabase, alias);
  }
}

class Preset extends DataClass implements Insertable<Preset> {
  final int id;
  final String? deviceId;
  final String name;
  final double voltage;
  final double current;
  final DateTime createdAt;
  const Preset({
    required this.id,
    this.deviceId,
    required this.name,
    required this.voltage,
    required this.current,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['name'] = Variable<String>(name);
    map['voltage'] = Variable<double>(voltage);
    map['current'] = Variable<double>(current);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PresetsCompanion toCompanion(bool nullToAbsent) {
    return PresetsCompanion(
      id: Value(id),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      name: Value(name),
      voltage: Value(voltage),
      current: Value(current),
      createdAt: Value(createdAt),
    );
  }

  factory Preset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Preset(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      name: serializer.fromJson<String>(json['name']),
      voltage: serializer.fromJson<double>(json['voltage']),
      current: serializer.fromJson<double>(json['current']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String?>(deviceId),
      'name': serializer.toJson<String>(name),
      'voltage': serializer.toJson<double>(voltage),
      'current': serializer.toJson<double>(current),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Preset copyWith({
    int? id,
    Value<String?> deviceId = const Value.absent(),
    String? name,
    double? voltage,
    double? current,
    DateTime? createdAt,
  }) => Preset(
    id: id ?? this.id,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    name: name ?? this.name,
    voltage: voltage ?? this.voltage,
    current: current ?? this.current,
    createdAt: createdAt ?? this.createdAt,
  );
  Preset copyWithCompanion(PresetsCompanion data) {
    return Preset(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      name: data.name.present ? data.name.value : this.name,
      voltage: data.voltage.present ? data.voltage.value : this.voltage,
      current: data.current.present ? data.current.value : this.current,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Preset(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('voltage: $voltage, ')
          ..write('current: $current, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, deviceId, name, voltage, current, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Preset &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.name == this.name &&
          other.voltage == this.voltage &&
          other.current == this.current &&
          other.createdAt == this.createdAt);
}

class PresetsCompanion extends UpdateCompanion<Preset> {
  final Value<int> id;
  final Value<String?> deviceId;
  final Value<String> name;
  final Value<double> voltage;
  final Value<double> current;
  final Value<DateTime> createdAt;
  const PresetsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.name = const Value.absent(),
    this.voltage = const Value.absent(),
    this.current = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PresetsCompanion.insert({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    required String name,
    required double voltage,
    required double current,
    required DateTime createdAt,
  }) : name = Value(name),
       voltage = Value(voltage),
       current = Value(current),
       createdAt = Value(createdAt);
  static Insertable<Preset> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<String>? name,
    Expression<double>? voltage,
    Expression<double>? current,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (name != null) 'name': name,
      if (voltage != null) 'voltage': voltage,
      if (current != null) 'current': current,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PresetsCompanion copyWith({
    Value<int>? id,
    Value<String?>? deviceId,
    Value<String>? name,
    Value<double>? voltage,
    Value<double>? current,
    Value<DateTime>? createdAt,
  }) {
    return PresetsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      voltage: voltage ?? this.voltage,
      current: current ?? this.current,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (voltage.present) {
      map['voltage'] = Variable<double>(voltage.value);
    }
    if (current.present) {
      map['current'] = Variable<double>(current.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PresetsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('voltage: $voltage, ')
          ..write('current: $current, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MeasurementSamplesTable extends MeasurementSamples
    with TableInfo<$MeasurementSamplesTable, MeasurementSample> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementSamplesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _voltageMeta = const VerificationMeta(
    'voltage',
  );
  @override
  late final GeneratedColumn<double> voltage = GeneratedColumn<double>(
    'voltage',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentMeta = const VerificationMeta(
    'current',
  );
  @override
  late final GeneratedColumn<double> current = GeneratedColumn<double>(
    'current',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _powerMeta = const VerificationMeta('power');
  @override
  late final GeneratedColumn<double> power = GeneratedColumn<double>(
    'power',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _temperatureMeta = const VerificationMeta(
    'temperature',
  );
  @override
  late final GeneratedColumn<double> temperature = GeneratedColumn<double>(
    'temperature',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inputVoltageMeta = const VerificationMeta(
    'inputVoltage',
  );
  @override
  late final GeneratedColumn<double> inputVoltage = GeneratedColumn<double>(
    'input_voltage',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ahMeta = const VerificationMeta('ah');
  @override
  late final GeneratedColumn<int> ah = GeneratedColumn<int>(
    'ah',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _whMeta = const VerificationMeta('wh');
  @override
  late final GeneratedColumn<int> wh = GeneratedColumn<int>(
    'wh',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _outputStateMeta = const VerificationMeta(
    'outputState',
  );
  @override
  late final GeneratedColumn<String> outputState = GeneratedColumn<String>(
    'output_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    timestamp,
    voltage,
    current,
    power,
    temperature,
    inputVoltage,
    ah,
    wh,
    outputState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurement_samples';
  @override
  VerificationContext validateIntegrity(
    Insertable<MeasurementSample> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('voltage')) {
      context.handle(
        _voltageMeta,
        voltage.isAcceptableOrUnknown(data['voltage']!, _voltageMeta),
      );
    }
    if (data.containsKey('current')) {
      context.handle(
        _currentMeta,
        current.isAcceptableOrUnknown(data['current']!, _currentMeta),
      );
    }
    if (data.containsKey('power')) {
      context.handle(
        _powerMeta,
        power.isAcceptableOrUnknown(data['power']!, _powerMeta),
      );
    }
    if (data.containsKey('temperature')) {
      context.handle(
        _temperatureMeta,
        temperature.isAcceptableOrUnknown(
          data['temperature']!,
          _temperatureMeta,
        ),
      );
    }
    if (data.containsKey('input_voltage')) {
      context.handle(
        _inputVoltageMeta,
        inputVoltage.isAcceptableOrUnknown(
          data['input_voltage']!,
          _inputVoltageMeta,
        ),
      );
    }
    if (data.containsKey('ah')) {
      context.handle(_ahMeta, ah.isAcceptableOrUnknown(data['ah']!, _ahMeta));
    }
    if (data.containsKey('wh')) {
      context.handle(_whMeta, wh.isAcceptableOrUnknown(data['wh']!, _whMeta));
    }
    if (data.containsKey('output_state')) {
      context.handle(
        _outputStateMeta,
        outputState.isAcceptableOrUnknown(
          data['output_state']!,
          _outputStateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_outputStateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MeasurementSample map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeasurementSample(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      voltage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}voltage'],
      ),
      current: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current'],
      ),
      power: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}power'],
      ),
      temperature: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temperature'],
      ),
      inputVoltage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}input_voltage'],
      ),
      ah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ah'],
      ),
      wh: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wh'],
      ),
      outputState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}output_state'],
      )!,
    );
  }

  @override
  $MeasurementSamplesTable createAlias(String alias) {
    return $MeasurementSamplesTable(attachedDatabase, alias);
  }
}

class MeasurementSample extends DataClass
    implements Insertable<MeasurementSample> {
  final int id;
  final String deviceId;
  final DateTime timestamp;
  final double? voltage;
  final double? current;
  final double? power;
  final double? temperature;
  final double? inputVoltage;
  final int? ah;
  final int? wh;
  final String outputState;
  const MeasurementSample({
    required this.id,
    required this.deviceId,
    required this.timestamp,
    this.voltage,
    this.current,
    this.power,
    this.temperature,
    this.inputVoltage,
    this.ah,
    this.wh,
    required this.outputState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || voltage != null) {
      map['voltage'] = Variable<double>(voltage);
    }
    if (!nullToAbsent || current != null) {
      map['current'] = Variable<double>(current);
    }
    if (!nullToAbsent || power != null) {
      map['power'] = Variable<double>(power);
    }
    if (!nullToAbsent || temperature != null) {
      map['temperature'] = Variable<double>(temperature);
    }
    if (!nullToAbsent || inputVoltage != null) {
      map['input_voltage'] = Variable<double>(inputVoltage);
    }
    if (!nullToAbsent || ah != null) {
      map['ah'] = Variable<int>(ah);
    }
    if (!nullToAbsent || wh != null) {
      map['wh'] = Variable<int>(wh);
    }
    map['output_state'] = Variable<String>(outputState);
    return map;
  }

  MeasurementSamplesCompanion toCompanion(bool nullToAbsent) {
    return MeasurementSamplesCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      timestamp: Value(timestamp),
      voltage: voltage == null && nullToAbsent
          ? const Value.absent()
          : Value(voltage),
      current: current == null && nullToAbsent
          ? const Value.absent()
          : Value(current),
      power: power == null && nullToAbsent
          ? const Value.absent()
          : Value(power),
      temperature: temperature == null && nullToAbsent
          ? const Value.absent()
          : Value(temperature),
      inputVoltage: inputVoltage == null && nullToAbsent
          ? const Value.absent()
          : Value(inputVoltage),
      ah: ah == null && nullToAbsent ? const Value.absent() : Value(ah),
      wh: wh == null && nullToAbsent ? const Value.absent() : Value(wh),
      outputState: Value(outputState),
    );
  }

  factory MeasurementSample.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeasurementSample(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      voltage: serializer.fromJson<double?>(json['voltage']),
      current: serializer.fromJson<double?>(json['current']),
      power: serializer.fromJson<double?>(json['power']),
      temperature: serializer.fromJson<double?>(json['temperature']),
      inputVoltage: serializer.fromJson<double?>(json['inputVoltage']),
      ah: serializer.fromJson<int?>(json['ah']),
      wh: serializer.fromJson<int?>(json['wh']),
      outputState: serializer.fromJson<String>(json['outputState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'voltage': serializer.toJson<double?>(voltage),
      'current': serializer.toJson<double?>(current),
      'power': serializer.toJson<double?>(power),
      'temperature': serializer.toJson<double?>(temperature),
      'inputVoltage': serializer.toJson<double?>(inputVoltage),
      'ah': serializer.toJson<int?>(ah),
      'wh': serializer.toJson<int?>(wh),
      'outputState': serializer.toJson<String>(outputState),
    };
  }

  MeasurementSample copyWith({
    int? id,
    String? deviceId,
    DateTime? timestamp,
    Value<double?> voltage = const Value.absent(),
    Value<double?> current = const Value.absent(),
    Value<double?> power = const Value.absent(),
    Value<double?> temperature = const Value.absent(),
    Value<double?> inputVoltage = const Value.absent(),
    Value<int?> ah = const Value.absent(),
    Value<int?> wh = const Value.absent(),
    String? outputState,
  }) => MeasurementSample(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    timestamp: timestamp ?? this.timestamp,
    voltage: voltage.present ? voltage.value : this.voltage,
    current: current.present ? current.value : this.current,
    power: power.present ? power.value : this.power,
    temperature: temperature.present ? temperature.value : this.temperature,
    inputVoltage: inputVoltage.present ? inputVoltage.value : this.inputVoltage,
    ah: ah.present ? ah.value : this.ah,
    wh: wh.present ? wh.value : this.wh,
    outputState: outputState ?? this.outputState,
  );
  MeasurementSample copyWithCompanion(MeasurementSamplesCompanion data) {
    return MeasurementSample(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      voltage: data.voltage.present ? data.voltage.value : this.voltage,
      current: data.current.present ? data.current.value : this.current,
      power: data.power.present ? data.power.value : this.power,
      temperature: data.temperature.present
          ? data.temperature.value
          : this.temperature,
      inputVoltage: data.inputVoltage.present
          ? data.inputVoltage.value
          : this.inputVoltage,
      ah: data.ah.present ? data.ah.value : this.ah,
      wh: data.wh.present ? data.wh.value : this.wh,
      outputState: data.outputState.present
          ? data.outputState.value
          : this.outputState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementSample(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('timestamp: $timestamp, ')
          ..write('voltage: $voltage, ')
          ..write('current: $current, ')
          ..write('power: $power, ')
          ..write('temperature: $temperature, ')
          ..write('inputVoltage: $inputVoltage, ')
          ..write('ah: $ah, ')
          ..write('wh: $wh, ')
          ..write('outputState: $outputState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    timestamp,
    voltage,
    current,
    power,
    temperature,
    inputVoltage,
    ah,
    wh,
    outputState,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeasurementSample &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.timestamp == this.timestamp &&
          other.voltage == this.voltage &&
          other.current == this.current &&
          other.power == this.power &&
          other.temperature == this.temperature &&
          other.inputVoltage == this.inputVoltage &&
          other.ah == this.ah &&
          other.wh == this.wh &&
          other.outputState == this.outputState);
}

class MeasurementSamplesCompanion extends UpdateCompanion<MeasurementSample> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<DateTime> timestamp;
  final Value<double?> voltage;
  final Value<double?> current;
  final Value<double?> power;
  final Value<double?> temperature;
  final Value<double?> inputVoltage;
  final Value<int?> ah;
  final Value<int?> wh;
  final Value<String> outputState;
  const MeasurementSamplesCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.voltage = const Value.absent(),
    this.current = const Value.absent(),
    this.power = const Value.absent(),
    this.temperature = const Value.absent(),
    this.inputVoltage = const Value.absent(),
    this.ah = const Value.absent(),
    this.wh = const Value.absent(),
    this.outputState = const Value.absent(),
  });
  MeasurementSamplesCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    required DateTime timestamp,
    this.voltage = const Value.absent(),
    this.current = const Value.absent(),
    this.power = const Value.absent(),
    this.temperature = const Value.absent(),
    this.inputVoltage = const Value.absent(),
    this.ah = const Value.absent(),
    this.wh = const Value.absent(),
    required String outputState,
  }) : deviceId = Value(deviceId),
       timestamp = Value(timestamp),
       outputState = Value(outputState);
  static Insertable<MeasurementSample> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<DateTime>? timestamp,
    Expression<double>? voltage,
    Expression<double>? current,
    Expression<double>? power,
    Expression<double>? temperature,
    Expression<double>? inputVoltage,
    Expression<int>? ah,
    Expression<int>? wh,
    Expression<String>? outputState,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (timestamp != null) 'timestamp': timestamp,
      if (voltage != null) 'voltage': voltage,
      if (current != null) 'current': current,
      if (power != null) 'power': power,
      if (temperature != null) 'temperature': temperature,
      if (inputVoltage != null) 'input_voltage': inputVoltage,
      if (ah != null) 'ah': ah,
      if (wh != null) 'wh': wh,
      if (outputState != null) 'output_state': outputState,
    });
  }

  MeasurementSamplesCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceId,
    Value<DateTime>? timestamp,
    Value<double?>? voltage,
    Value<double?>? current,
    Value<double?>? power,
    Value<double?>? temperature,
    Value<double?>? inputVoltage,
    Value<int?>? ah,
    Value<int?>? wh,
    Value<String>? outputState,
  }) {
    return MeasurementSamplesCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      timestamp: timestamp ?? this.timestamp,
      voltage: voltage ?? this.voltage,
      current: current ?? this.current,
      power: power ?? this.power,
      temperature: temperature ?? this.temperature,
      inputVoltage: inputVoltage ?? this.inputVoltage,
      ah: ah ?? this.ah,
      wh: wh ?? this.wh,
      outputState: outputState ?? this.outputState,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (voltage.present) {
      map['voltage'] = Variable<double>(voltage.value);
    }
    if (current.present) {
      map['current'] = Variable<double>(current.value);
    }
    if (power.present) {
      map['power'] = Variable<double>(power.value);
    }
    if (temperature.present) {
      map['temperature'] = Variable<double>(temperature.value);
    }
    if (inputVoltage.present) {
      map['input_voltage'] = Variable<double>(inputVoltage.value);
    }
    if (ah.present) {
      map['ah'] = Variable<int>(ah.value);
    }
    if (wh.present) {
      map['wh'] = Variable<int>(wh.value);
    }
    if (outputState.present) {
      map['output_state'] = Variable<String>(outputState.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementSamplesCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('timestamp: $timestamp, ')
          ..write('voltage: $voltage, ')
          ..write('current: $current, ')
          ..write('power: $power, ')
          ..write('temperature: $temperature, ')
          ..write('inputVoltage: $inputVoltage, ')
          ..write('ah: $ah, ')
          ..write('wh: $wh, ')
          ..write('outputState: $outputState')
          ..write(')'))
        .toString();
  }
}

class $OutputSessionsTable extends OutputSessions
    with TableInfo<$OutputSessionsTable, OutputSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutputSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _averageVoltageMeta = const VerificationMeta(
    'averageVoltage',
  );
  @override
  late final GeneratedColumn<double> averageVoltage = GeneratedColumn<double>(
    'average_voltage',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _averageCurrentMeta = const VerificationMeta(
    'averageCurrent',
  );
  @override
  late final GeneratedColumn<double> averageCurrent = GeneratedColumn<double>(
    'average_current',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxPowerMeta = const VerificationMeta(
    'maxPower',
  );
  @override
  late final GeneratedColumn<double> maxPower = GeneratedColumn<double>(
    'max_power',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalAhMeta = const VerificationMeta(
    'totalAh',
  );
  @override
  late final GeneratedColumn<int> totalAh = GeneratedColumn<int>(
    'total_ah',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalWhMeta = const VerificationMeta(
    'totalWh',
  );
  @override
  late final GeneratedColumn<int> totalWh = GeneratedColumn<int>(
    'total_wh',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    startTime,
    endTime,
    durationSeconds,
    averageVoltage,
    averageCurrent,
    maxPower,
    totalAh,
    totalWh,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'output_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutputSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('average_voltage')) {
      context.handle(
        _averageVoltageMeta,
        averageVoltage.isAcceptableOrUnknown(
          data['average_voltage']!,
          _averageVoltageMeta,
        ),
      );
    }
    if (data.containsKey('average_current')) {
      context.handle(
        _averageCurrentMeta,
        averageCurrent.isAcceptableOrUnknown(
          data['average_current']!,
          _averageCurrentMeta,
        ),
      );
    }
    if (data.containsKey('max_power')) {
      context.handle(
        _maxPowerMeta,
        maxPower.isAcceptableOrUnknown(data['max_power']!, _maxPowerMeta),
      );
    }
    if (data.containsKey('total_ah')) {
      context.handle(
        _totalAhMeta,
        totalAh.isAcceptableOrUnknown(data['total_ah']!, _totalAhMeta),
      );
    }
    if (data.containsKey('total_wh')) {
      context.handle(
        _totalWhMeta,
        totalWh.isAcceptableOrUnknown(data['total_wh']!, _totalWhMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutputSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutputSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      averageVoltage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_voltage'],
      ),
      averageCurrent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_current'],
      ),
      maxPower: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_power'],
      ),
      totalAh: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_ah'],
      ),
      totalWh: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_wh'],
      ),
    );
  }

  @override
  $OutputSessionsTable createAlias(String alias) {
    return $OutputSessionsTable(attachedDatabase, alias);
  }
}

class OutputSession extends DataClass implements Insertable<OutputSession> {
  final int id;
  final String deviceId;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds;
  final double? averageVoltage;
  final double? averageCurrent;
  final double? maxPower;
  final int? totalAh;
  final int? totalWh;
  const OutputSession({
    required this.id,
    required this.deviceId,
    required this.startTime,
    this.endTime,
    required this.durationSeconds,
    this.averageVoltage,
    this.averageCurrent,
    this.maxPower,
    this.totalAh,
    this.totalWh,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    map['duration_seconds'] = Variable<int>(durationSeconds);
    if (!nullToAbsent || averageVoltage != null) {
      map['average_voltage'] = Variable<double>(averageVoltage);
    }
    if (!nullToAbsent || averageCurrent != null) {
      map['average_current'] = Variable<double>(averageCurrent);
    }
    if (!nullToAbsent || maxPower != null) {
      map['max_power'] = Variable<double>(maxPower);
    }
    if (!nullToAbsent || totalAh != null) {
      map['total_ah'] = Variable<int>(totalAh);
    }
    if (!nullToAbsent || totalWh != null) {
      map['total_wh'] = Variable<int>(totalWh);
    }
    return map;
  }

  OutputSessionsCompanion toCompanion(bool nullToAbsent) {
    return OutputSessionsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      durationSeconds: Value(durationSeconds),
      averageVoltage: averageVoltage == null && nullToAbsent
          ? const Value.absent()
          : Value(averageVoltage),
      averageCurrent: averageCurrent == null && nullToAbsent
          ? const Value.absent()
          : Value(averageCurrent),
      maxPower: maxPower == null && nullToAbsent
          ? const Value.absent()
          : Value(maxPower),
      totalAh: totalAh == null && nullToAbsent
          ? const Value.absent()
          : Value(totalAh),
      totalWh: totalWh == null && nullToAbsent
          ? const Value.absent()
          : Value(totalWh),
    );
  }

  factory OutputSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutputSession(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      averageVoltage: serializer.fromJson<double?>(json['averageVoltage']),
      averageCurrent: serializer.fromJson<double?>(json['averageCurrent']),
      maxPower: serializer.fromJson<double?>(json['maxPower']),
      totalAh: serializer.fromJson<int?>(json['totalAh']),
      totalWh: serializer.fromJson<int?>(json['totalWh']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'averageVoltage': serializer.toJson<double?>(averageVoltage),
      'averageCurrent': serializer.toJson<double?>(averageCurrent),
      'maxPower': serializer.toJson<double?>(maxPower),
      'totalAh': serializer.toJson<int?>(totalAh),
      'totalWh': serializer.toJson<int?>(totalWh),
    };
  }

  OutputSession copyWith({
    int? id,
    String? deviceId,
    DateTime? startTime,
    Value<DateTime?> endTime = const Value.absent(),
    int? durationSeconds,
    Value<double?> averageVoltage = const Value.absent(),
    Value<double?> averageCurrent = const Value.absent(),
    Value<double?> maxPower = const Value.absent(),
    Value<int?> totalAh = const Value.absent(),
    Value<int?> totalWh = const Value.absent(),
  }) => OutputSession(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    startTime: startTime ?? this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    averageVoltage: averageVoltage.present
        ? averageVoltage.value
        : this.averageVoltage,
    averageCurrent: averageCurrent.present
        ? averageCurrent.value
        : this.averageCurrent,
    maxPower: maxPower.present ? maxPower.value : this.maxPower,
    totalAh: totalAh.present ? totalAh.value : this.totalAh,
    totalWh: totalWh.present ? totalWh.value : this.totalWh,
  );
  OutputSession copyWithCompanion(OutputSessionsCompanion data) {
    return OutputSession(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      averageVoltage: data.averageVoltage.present
          ? data.averageVoltage.value
          : this.averageVoltage,
      averageCurrent: data.averageCurrent.present
          ? data.averageCurrent.value
          : this.averageCurrent,
      maxPower: data.maxPower.present ? data.maxPower.value : this.maxPower,
      totalAh: data.totalAh.present ? data.totalAh.value : this.totalAh,
      totalWh: data.totalWh.present ? data.totalWh.value : this.totalWh,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutputSession(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('averageVoltage: $averageVoltage, ')
          ..write('averageCurrent: $averageCurrent, ')
          ..write('maxPower: $maxPower, ')
          ..write('totalAh: $totalAh, ')
          ..write('totalWh: $totalWh')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    startTime,
    endTime,
    durationSeconds,
    averageVoltage,
    averageCurrent,
    maxPower,
    totalAh,
    totalWh,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutputSession &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.durationSeconds == this.durationSeconds &&
          other.averageVoltage == this.averageVoltage &&
          other.averageCurrent == this.averageCurrent &&
          other.maxPower == this.maxPower &&
          other.totalAh == this.totalAh &&
          other.totalWh == this.totalWh);
}

class OutputSessionsCompanion extends UpdateCompanion<OutputSession> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<DateTime> startTime;
  final Value<DateTime?> endTime;
  final Value<int> durationSeconds;
  final Value<double?> averageVoltage;
  final Value<double?> averageCurrent;
  final Value<double?> maxPower;
  final Value<int?> totalAh;
  final Value<int?> totalWh;
  const OutputSessionsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.averageVoltage = const Value.absent(),
    this.averageCurrent = const Value.absent(),
    this.maxPower = const Value.absent(),
    this.totalAh = const Value.absent(),
    this.totalWh = const Value.absent(),
  });
  OutputSessionsCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    required DateTime startTime,
    this.endTime = const Value.absent(),
    required int durationSeconds,
    this.averageVoltage = const Value.absent(),
    this.averageCurrent = const Value.absent(),
    this.maxPower = const Value.absent(),
    this.totalAh = const Value.absent(),
    this.totalWh = const Value.absent(),
  }) : deviceId = Value(deviceId),
       startTime = Value(startTime),
       durationSeconds = Value(durationSeconds);
  static Insertable<OutputSession> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? durationSeconds,
    Expression<double>? averageVoltage,
    Expression<double>? averageCurrent,
    Expression<double>? maxPower,
    Expression<int>? totalAh,
    Expression<int>? totalWh,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (averageVoltage != null) 'average_voltage': averageVoltage,
      if (averageCurrent != null) 'average_current': averageCurrent,
      if (maxPower != null) 'max_power': maxPower,
      if (totalAh != null) 'total_ah': totalAh,
      if (totalWh != null) 'total_wh': totalWh,
    });
  }

  OutputSessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceId,
    Value<DateTime>? startTime,
    Value<DateTime?>? endTime,
    Value<int>? durationSeconds,
    Value<double?>? averageVoltage,
    Value<double?>? averageCurrent,
    Value<double?>? maxPower,
    Value<int?>? totalAh,
    Value<int?>? totalWh,
  }) {
    return OutputSessionsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      averageVoltage: averageVoltage ?? this.averageVoltage,
      averageCurrent: averageCurrent ?? this.averageCurrent,
      maxPower: maxPower ?? this.maxPower,
      totalAh: totalAh ?? this.totalAh,
      totalWh: totalWh ?? this.totalWh,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (averageVoltage.present) {
      map['average_voltage'] = Variable<double>(averageVoltage.value);
    }
    if (averageCurrent.present) {
      map['average_current'] = Variable<double>(averageCurrent.value);
    }
    if (maxPower.present) {
      map['max_power'] = Variable<double>(maxPower.value);
    }
    if (totalAh.present) {
      map['total_ah'] = Variable<int>(totalAh.value);
    }
    if (totalWh.present) {
      map['total_wh'] = Variable<int>(totalWh.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutputSessionsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('averageVoltage: $averageVoltage, ')
          ..write('averageCurrent: $averageCurrent, ')
          ..write('maxPower: $maxPower, ')
          ..write('totalAh: $totalAh, ')
          ..write('totalWh: $totalWh')
          ..write(')'))
        .toString();
  }
}

class $DeviceGroupsTable extends DeviceGroups
    with TableInfo<$DeviceGroupsTable, DeviceGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIndexMeta = const VerificationMeta(
    'groupIndex',
  );
  @override
  late final GeneratedColumn<int> groupIndex = GeneratedColumn<int>(
    'group_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valuesJsonMeta = const VerificationMeta(
    'valuesJson',
  );
  @override
  late final GeneratedColumn<String> valuesJson = GeneratedColumn<String>(
    'values_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    groupIndex,
    name,
    valuesJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('group_index')) {
      context.handle(
        _groupIndexMeta,
        groupIndex.isAcceptableOrUnknown(data['group_index']!, _groupIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIndexMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('values_json')) {
      context.handle(
        _valuesJsonMeta,
        valuesJson.isAcceptableOrUnknown(data['values_json']!, _valuesJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_valuesJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeviceGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceGroup(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      groupIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_index'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      valuesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}values_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DeviceGroupsTable createAlias(String alias) {
    return $DeviceGroupsTable(attachedDatabase, alias);
  }
}

class DeviceGroup extends DataClass implements Insertable<DeviceGroup> {
  final int id;
  final String deviceId;
  final int groupIndex;
  final String? name;
  final String valuesJson;
  final DateTime updatedAt;
  const DeviceGroup({
    required this.id,
    required this.deviceId,
    required this.groupIndex,
    this.name,
    required this.valuesJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['group_index'] = Variable<int>(groupIndex);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['values_json'] = Variable<String>(valuesJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DeviceGroupsCompanion toCompanion(bool nullToAbsent) {
    return DeviceGroupsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      groupIndex: Value(groupIndex),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      valuesJson: Value(valuesJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory DeviceGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceGroup(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      groupIndex: serializer.fromJson<int>(json['groupIndex']),
      name: serializer.fromJson<String?>(json['name']),
      valuesJson: serializer.fromJson<String>(json['valuesJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'groupIndex': serializer.toJson<int>(groupIndex),
      'name': serializer.toJson<String?>(name),
      'valuesJson': serializer.toJson<String>(valuesJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DeviceGroup copyWith({
    int? id,
    String? deviceId,
    int? groupIndex,
    Value<String?> name = const Value.absent(),
    String? valuesJson,
    DateTime? updatedAt,
  }) => DeviceGroup(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    groupIndex: groupIndex ?? this.groupIndex,
    name: name.present ? name.value : this.name,
    valuesJson: valuesJson ?? this.valuesJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DeviceGroup copyWithCompanion(DeviceGroupsCompanion data) {
    return DeviceGroup(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      groupIndex: data.groupIndex.present
          ? data.groupIndex.value
          : this.groupIndex,
      name: data.name.present ? data.name.value : this.name,
      valuesJson: data.valuesJson.present
          ? data.valuesJson.value
          : this.valuesJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceGroup(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('groupIndex: $groupIndex, ')
          ..write('name: $name, ')
          ..write('valuesJson: $valuesJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, deviceId, groupIndex, name, valuesJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceGroup &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.groupIndex == this.groupIndex &&
          other.name == this.name &&
          other.valuesJson == this.valuesJson &&
          other.updatedAt == this.updatedAt);
}

class DeviceGroupsCompanion extends UpdateCompanion<DeviceGroup> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<int> groupIndex;
  final Value<String?> name;
  final Value<String> valuesJson;
  final Value<DateTime> updatedAt;
  const DeviceGroupsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.groupIndex = const Value.absent(),
    this.name = const Value.absent(),
    this.valuesJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DeviceGroupsCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    required int groupIndex,
    this.name = const Value.absent(),
    required String valuesJson,
    required DateTime updatedAt,
  }) : deviceId = Value(deviceId),
       groupIndex = Value(groupIndex),
       valuesJson = Value(valuesJson),
       updatedAt = Value(updatedAt);
  static Insertable<DeviceGroup> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<int>? groupIndex,
    Expression<String>? name,
    Expression<String>? valuesJson,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (groupIndex != null) 'group_index': groupIndex,
      if (name != null) 'name': name,
      if (valuesJson != null) 'values_json': valuesJson,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DeviceGroupsCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceId,
    Value<int>? groupIndex,
    Value<String?>? name,
    Value<String>? valuesJson,
    Value<DateTime>? updatedAt,
  }) {
    return DeviceGroupsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      groupIndex: groupIndex ?? this.groupIndex,
      name: name ?? this.name,
      valuesJson: valuesJson ?? this.valuesJson,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (groupIndex.present) {
      map['group_index'] = Variable<int>(groupIndex.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (valuesJson.present) {
      map['values_json'] = Variable<String>(valuesJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceGroupsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('groupIndex: $groupIndex, ')
          ..write('name: $name, ')
          ..write('valuesJson: $valuesJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CommunicationLogsTable extends CommunicationLogs
    with TableInfo<$CommunicationLogsTable, CommunicationLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommunicationLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawHexMeta = const VerificationMeta('rawHex');
  @override
  late final GeneratedColumn<String> rawHex = GeneratedColumn<String>(
    'raw_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parsedMessageMeta = const VerificationMeta(
    'parsedMessage',
  );
  @override
  late final GeneratedColumn<String> parsedMessage = GeneratedColumn<String>(
    'parsed_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _successMeta = const VerificationMeta(
    'success',
  );
  @override
  late final GeneratedColumn<bool> success = GeneratedColumn<bool>(
    'success',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("success" IN (0, 1))',
    ),
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    timestamp,
    direction,
    rawHex,
    parsedMessage,
    success,
    error,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'communication_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<CommunicationLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('raw_hex')) {
      context.handle(
        _rawHexMeta,
        rawHex.isAcceptableOrUnknown(data['raw_hex']!, _rawHexMeta),
      );
    } else if (isInserting) {
      context.missing(_rawHexMeta);
    }
    if (data.containsKey('parsed_message')) {
      context.handle(
        _parsedMessageMeta,
        parsedMessage.isAcceptableOrUnknown(
          data['parsed_message']!,
          _parsedMessageMeta,
        ),
      );
    }
    if (data.containsKey('success')) {
      context.handle(
        _successMeta,
        success.isAcceptableOrUnknown(data['success']!, _successMeta),
      );
    } else if (isInserting) {
      context.missing(_successMeta);
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CommunicationLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CommunicationLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      rawHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_hex'],
      )!,
      parsedMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parsed_message'],
      ),
      success: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}success'],
      )!,
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
    );
  }

  @override
  $CommunicationLogsTable createAlias(String alias) {
    return $CommunicationLogsTable(attachedDatabase, alias);
  }
}

class CommunicationLog extends DataClass
    implements Insertable<CommunicationLog> {
  final int id;
  final String deviceId;
  final DateTime timestamp;
  final String direction;
  final String rawHex;
  final String? parsedMessage;
  final bool success;
  final String? error;
  const CommunicationLog({
    required this.id,
    required this.deviceId,
    required this.timestamp,
    required this.direction,
    required this.rawHex,
    this.parsedMessage,
    required this.success,
    this.error,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['direction'] = Variable<String>(direction);
    map['raw_hex'] = Variable<String>(rawHex);
    if (!nullToAbsent || parsedMessage != null) {
      map['parsed_message'] = Variable<String>(parsedMessage);
    }
    map['success'] = Variable<bool>(success);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    return map;
  }

  CommunicationLogsCompanion toCompanion(bool nullToAbsent) {
    return CommunicationLogsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      timestamp: Value(timestamp),
      direction: Value(direction),
      rawHex: Value(rawHex),
      parsedMessage: parsedMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(parsedMessage),
      success: Value(success),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
    );
  }

  factory CommunicationLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CommunicationLog(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      direction: serializer.fromJson<String>(json['direction']),
      rawHex: serializer.fromJson<String>(json['rawHex']),
      parsedMessage: serializer.fromJson<String?>(json['parsedMessage']),
      success: serializer.fromJson<bool>(json['success']),
      error: serializer.fromJson<String?>(json['error']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'direction': serializer.toJson<String>(direction),
      'rawHex': serializer.toJson<String>(rawHex),
      'parsedMessage': serializer.toJson<String?>(parsedMessage),
      'success': serializer.toJson<bool>(success),
      'error': serializer.toJson<String?>(error),
    };
  }

  CommunicationLog copyWith({
    int? id,
    String? deviceId,
    DateTime? timestamp,
    String? direction,
    String? rawHex,
    Value<String?> parsedMessage = const Value.absent(),
    bool? success,
    Value<String?> error = const Value.absent(),
  }) => CommunicationLog(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    timestamp: timestamp ?? this.timestamp,
    direction: direction ?? this.direction,
    rawHex: rawHex ?? this.rawHex,
    parsedMessage: parsedMessage.present
        ? parsedMessage.value
        : this.parsedMessage,
    success: success ?? this.success,
    error: error.present ? error.value : this.error,
  );
  CommunicationLog copyWithCompanion(CommunicationLogsCompanion data) {
    return CommunicationLog(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      direction: data.direction.present ? data.direction.value : this.direction,
      rawHex: data.rawHex.present ? data.rawHex.value : this.rawHex,
      parsedMessage: data.parsedMessage.present
          ? data.parsedMessage.value
          : this.parsedMessage,
      success: data.success.present ? data.success.value : this.success,
      error: data.error.present ? data.error.value : this.error,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CommunicationLog(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('timestamp: $timestamp, ')
          ..write('direction: $direction, ')
          ..write('rawHex: $rawHex, ')
          ..write('parsedMessage: $parsedMessage, ')
          ..write('success: $success, ')
          ..write('error: $error')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    timestamp,
    direction,
    rawHex,
    parsedMessage,
    success,
    error,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommunicationLog &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.timestamp == this.timestamp &&
          other.direction == this.direction &&
          other.rawHex == this.rawHex &&
          other.parsedMessage == this.parsedMessage &&
          other.success == this.success &&
          other.error == this.error);
}

class CommunicationLogsCompanion extends UpdateCompanion<CommunicationLog> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<DateTime> timestamp;
  final Value<String> direction;
  final Value<String> rawHex;
  final Value<String?> parsedMessage;
  final Value<bool> success;
  final Value<String?> error;
  const CommunicationLogsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.direction = const Value.absent(),
    this.rawHex = const Value.absent(),
    this.parsedMessage = const Value.absent(),
    this.success = const Value.absent(),
    this.error = const Value.absent(),
  });
  CommunicationLogsCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    required DateTime timestamp,
    required String direction,
    required String rawHex,
    this.parsedMessage = const Value.absent(),
    required bool success,
    this.error = const Value.absent(),
  }) : deviceId = Value(deviceId),
       timestamp = Value(timestamp),
       direction = Value(direction),
       rawHex = Value(rawHex),
       success = Value(success);
  static Insertable<CommunicationLog> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<DateTime>? timestamp,
    Expression<String>? direction,
    Expression<String>? rawHex,
    Expression<String>? parsedMessage,
    Expression<bool>? success,
    Expression<String>? error,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (timestamp != null) 'timestamp': timestamp,
      if (direction != null) 'direction': direction,
      if (rawHex != null) 'raw_hex': rawHex,
      if (parsedMessage != null) 'parsed_message': parsedMessage,
      if (success != null) 'success': success,
      if (error != null) 'error': error,
    });
  }

  CommunicationLogsCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceId,
    Value<DateTime>? timestamp,
    Value<String>? direction,
    Value<String>? rawHex,
    Value<String?>? parsedMessage,
    Value<bool>? success,
    Value<String?>? error,
  }) {
    return CommunicationLogsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      timestamp: timestamp ?? this.timestamp,
      direction: direction ?? this.direction,
      rawHex: rawHex ?? this.rawHex,
      parsedMessage: parsedMessage ?? this.parsedMessage,
      success: success ?? this.success,
      error: error ?? this.error,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (rawHex.present) {
      map['raw_hex'] = Variable<String>(rawHex.value);
    }
    if (parsedMessage.present) {
      map['parsed_message'] = Variable<String>(parsedMessage.value);
    }
    if (success.present) {
      map['success'] = Variable<bool>(success.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommunicationLogsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('timestamp: $timestamp, ')
          ..write('direction: $direction, ')
          ..write('rawHex: $rawHex, ')
          ..write('parsedMessage: $parsedMessage, ')
          ..write('success: $success, ')
          ..write('error: $error')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$Sk120Database extends GeneratedDatabase {
  _$Sk120Database(QueryExecutor e) : super(e);
  $Sk120DatabaseManager get managers => $Sk120DatabaseManager(this);
  late final $DevicesTable devices = $DevicesTable(this);
  late final $PresetsTable presets = $PresetsTable(this);
  late final $MeasurementSamplesTable measurementSamples =
      $MeasurementSamplesTable(this);
  late final $OutputSessionsTable outputSessions = $OutputSessionsTable(this);
  late final $DeviceGroupsTable deviceGroups = $DeviceGroupsTable(this);
  late final $CommunicationLogsTable communicationLogs =
      $CommunicationLogsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    devices,
    presets,
    measurementSamples,
    outputSessions,
    deviceGroups,
    communicationLogs,
    appSettings,
  ];
}

typedef $$DevicesTableCreateCompanionBuilder =
    DevicesCompanion Function({
      required String id,
      required String name,
      Value<String?> model,
      Value<String?> firmwareVersion,
      Value<String?> bleDeviceId,
      Value<int?> lastRssi,
      Value<DateTime?> lastSeen,
      required DateTime createdAt,
      required String mode,
      Value<int> rowid,
    });
typedef $$DevicesTableUpdateCompanionBuilder =
    DevicesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> model,
      Value<String?> firmwareVersion,
      Value<String?> bleDeviceId,
      Value<int?> lastRssi,
      Value<DateTime?> lastSeen,
      Value<DateTime> createdAt,
      Value<String> mode,
      Value<int> rowid,
    });

class $$DevicesTableFilterComposer
    extends Composer<_$Sk120Database, $DevicesTable> {
  $$DevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firmwareVersion => $composableBuilder(
    column: $table.firmwareVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bleDeviceId => $composableBuilder(
    column: $table.bleDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastRssi => $composableBuilder(
    column: $table.lastRssi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DevicesTableOrderingComposer
    extends Composer<_$Sk120Database, $DevicesTable> {
  $$DevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firmwareVersion => $composableBuilder(
    column: $table.firmwareVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bleDeviceId => $composableBuilder(
    column: $table.bleDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastRssi => $composableBuilder(
    column: $table.lastRssi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevicesTableAnnotationComposer
    extends Composer<_$Sk120Database, $DevicesTable> {
  $$DevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get firmwareVersion => $composableBuilder(
    column: $table.firmwareVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bleDeviceId => $composableBuilder(
    column: $table.bleDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastRssi =>
      $composableBuilder(column: $table.lastRssi, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeen =>
      $composableBuilder(column: $table.lastSeen, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);
}

class $$DevicesTableTableManager
    extends
        RootTableManager<
          _$Sk120Database,
          $DevicesTable,
          Device,
          $$DevicesTableFilterComposer,
          $$DevicesTableOrderingComposer,
          $$DevicesTableAnnotationComposer,
          $$DevicesTableCreateCompanionBuilder,
          $$DevicesTableUpdateCompanionBuilder,
          (Device, BaseReferences<_$Sk120Database, $DevicesTable, Device>),
          Device,
          PrefetchHooks Function()
        > {
  $$DevicesTableTableManager(_$Sk120Database db, $DevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<String?> firmwareVersion = const Value.absent(),
                Value<String?> bleDeviceId = const Value.absent(),
                Value<int?> lastRssi = const Value.absent(),
                Value<DateTime?> lastSeen = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion(
                id: id,
                name: name,
                model: model,
                firmwareVersion: firmwareVersion,
                bleDeviceId: bleDeviceId,
                lastRssi: lastRssi,
                lastSeen: lastSeen,
                createdAt: createdAt,
                mode: mode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> model = const Value.absent(),
                Value<String?> firmwareVersion = const Value.absent(),
                Value<String?> bleDeviceId = const Value.absent(),
                Value<int?> lastRssi = const Value.absent(),
                Value<DateTime?> lastSeen = const Value.absent(),
                required DateTime createdAt,
                required String mode,
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion.insert(
                id: id,
                name: name,
                model: model,
                firmwareVersion: firmwareVersion,
                bleDeviceId: bleDeviceId,
                lastRssi: lastRssi,
                lastSeen: lastSeen,
                createdAt: createdAt,
                mode: mode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$Sk120Database,
      $DevicesTable,
      Device,
      $$DevicesTableFilterComposer,
      $$DevicesTableOrderingComposer,
      $$DevicesTableAnnotationComposer,
      $$DevicesTableCreateCompanionBuilder,
      $$DevicesTableUpdateCompanionBuilder,
      (Device, BaseReferences<_$Sk120Database, $DevicesTable, Device>),
      Device,
      PrefetchHooks Function()
    >;
typedef $$PresetsTableCreateCompanionBuilder =
    PresetsCompanion Function({
      Value<int> id,
      Value<String?> deviceId,
      required String name,
      required double voltage,
      required double current,
      required DateTime createdAt,
    });
typedef $$PresetsTableUpdateCompanionBuilder =
    PresetsCompanion Function({
      Value<int> id,
      Value<String?> deviceId,
      Value<String> name,
      Value<double> voltage,
      Value<double> current,
      Value<DateTime> createdAt,
    });

class $$PresetsTableFilterComposer
    extends Composer<_$Sk120Database, $PresetsTable> {
  $$PresetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get voltage => $composableBuilder(
    column: $table.voltage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get current => $composableBuilder(
    column: $table.current,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PresetsTableOrderingComposer
    extends Composer<_$Sk120Database, $PresetsTable> {
  $$PresetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get voltage => $composableBuilder(
    column: $table.voltage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get current => $composableBuilder(
    column: $table.current,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PresetsTableAnnotationComposer
    extends Composer<_$Sk120Database, $PresetsTable> {
  $$PresetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get voltage =>
      $composableBuilder(column: $table.voltage, builder: (column) => column);

  GeneratedColumn<double> get current =>
      $composableBuilder(column: $table.current, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PresetsTableTableManager
    extends
        RootTableManager<
          _$Sk120Database,
          $PresetsTable,
          Preset,
          $$PresetsTableFilterComposer,
          $$PresetsTableOrderingComposer,
          $$PresetsTableAnnotationComposer,
          $$PresetsTableCreateCompanionBuilder,
          $$PresetsTableUpdateCompanionBuilder,
          (Preset, BaseReferences<_$Sk120Database, $PresetsTable, Preset>),
          Preset,
          PrefetchHooks Function()
        > {
  $$PresetsTableTableManager(_$Sk120Database db, $PresetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PresetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PresetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PresetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> voltage = const Value.absent(),
                Value<double> current = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PresetsCompanion(
                id: id,
                deviceId: deviceId,
                name: name,
                voltage: voltage,
                current: current,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                required String name,
                required double voltage,
                required double current,
                required DateTime createdAt,
              }) => PresetsCompanion.insert(
                id: id,
                deviceId: deviceId,
                name: name,
                voltage: voltage,
                current: current,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PresetsTableProcessedTableManager =
    ProcessedTableManager<
      _$Sk120Database,
      $PresetsTable,
      Preset,
      $$PresetsTableFilterComposer,
      $$PresetsTableOrderingComposer,
      $$PresetsTableAnnotationComposer,
      $$PresetsTableCreateCompanionBuilder,
      $$PresetsTableUpdateCompanionBuilder,
      (Preset, BaseReferences<_$Sk120Database, $PresetsTable, Preset>),
      Preset,
      PrefetchHooks Function()
    >;
typedef $$MeasurementSamplesTableCreateCompanionBuilder =
    MeasurementSamplesCompanion Function({
      Value<int> id,
      required String deviceId,
      required DateTime timestamp,
      Value<double?> voltage,
      Value<double?> current,
      Value<double?> power,
      Value<double?> temperature,
      Value<double?> inputVoltage,
      Value<int?> ah,
      Value<int?> wh,
      required String outputState,
    });
typedef $$MeasurementSamplesTableUpdateCompanionBuilder =
    MeasurementSamplesCompanion Function({
      Value<int> id,
      Value<String> deviceId,
      Value<DateTime> timestamp,
      Value<double?> voltage,
      Value<double?> current,
      Value<double?> power,
      Value<double?> temperature,
      Value<double?> inputVoltage,
      Value<int?> ah,
      Value<int?> wh,
      Value<String> outputState,
    });

class $$MeasurementSamplesTableFilterComposer
    extends Composer<_$Sk120Database, $MeasurementSamplesTable> {
  $$MeasurementSamplesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get voltage => $composableBuilder(
    column: $table.voltage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get current => $composableBuilder(
    column: $table.current,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get power => $composableBuilder(
    column: $table.power,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get inputVoltage => $composableBuilder(
    column: $table.inputVoltage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ah => $composableBuilder(
    column: $table.ah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wh => $composableBuilder(
    column: $table.wh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outputState => $composableBuilder(
    column: $table.outputState,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MeasurementSamplesTableOrderingComposer
    extends Composer<_$Sk120Database, $MeasurementSamplesTable> {
  $$MeasurementSamplesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get voltage => $composableBuilder(
    column: $table.voltage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get current => $composableBuilder(
    column: $table.current,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get power => $composableBuilder(
    column: $table.power,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get inputVoltage => $composableBuilder(
    column: $table.inputVoltage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ah => $composableBuilder(
    column: $table.ah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wh => $composableBuilder(
    column: $table.wh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outputState => $composableBuilder(
    column: $table.outputState,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MeasurementSamplesTableAnnotationComposer
    extends Composer<_$Sk120Database, $MeasurementSamplesTable> {
  $$MeasurementSamplesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<double> get voltage =>
      $composableBuilder(column: $table.voltage, builder: (column) => column);

  GeneratedColumn<double> get current =>
      $composableBuilder(column: $table.current, builder: (column) => column);

  GeneratedColumn<double> get power =>
      $composableBuilder(column: $table.power, builder: (column) => column);

  GeneratedColumn<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => column,
  );

  GeneratedColumn<double> get inputVoltage => $composableBuilder(
    column: $table.inputVoltage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ah =>
      $composableBuilder(column: $table.ah, builder: (column) => column);

  GeneratedColumn<int> get wh =>
      $composableBuilder(column: $table.wh, builder: (column) => column);

  GeneratedColumn<String> get outputState => $composableBuilder(
    column: $table.outputState,
    builder: (column) => column,
  );
}

class $$MeasurementSamplesTableTableManager
    extends
        RootTableManager<
          _$Sk120Database,
          $MeasurementSamplesTable,
          MeasurementSample,
          $$MeasurementSamplesTableFilterComposer,
          $$MeasurementSamplesTableOrderingComposer,
          $$MeasurementSamplesTableAnnotationComposer,
          $$MeasurementSamplesTableCreateCompanionBuilder,
          $$MeasurementSamplesTableUpdateCompanionBuilder,
          (
            MeasurementSample,
            BaseReferences<
              _$Sk120Database,
              $MeasurementSamplesTable,
              MeasurementSample
            >,
          ),
          MeasurementSample,
          PrefetchHooks Function()
        > {
  $$MeasurementSamplesTableTableManager(
    _$Sk120Database db,
    $MeasurementSamplesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeasurementSamplesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeasurementSamplesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeasurementSamplesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<double?> voltage = const Value.absent(),
                Value<double?> current = const Value.absent(),
                Value<double?> power = const Value.absent(),
                Value<double?> temperature = const Value.absent(),
                Value<double?> inputVoltage = const Value.absent(),
                Value<int?> ah = const Value.absent(),
                Value<int?> wh = const Value.absent(),
                Value<String> outputState = const Value.absent(),
              }) => MeasurementSamplesCompanion(
                id: id,
                deviceId: deviceId,
                timestamp: timestamp,
                voltage: voltage,
                current: current,
                power: power,
                temperature: temperature,
                inputVoltage: inputVoltage,
                ah: ah,
                wh: wh,
                outputState: outputState,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deviceId,
                required DateTime timestamp,
                Value<double?> voltage = const Value.absent(),
                Value<double?> current = const Value.absent(),
                Value<double?> power = const Value.absent(),
                Value<double?> temperature = const Value.absent(),
                Value<double?> inputVoltage = const Value.absent(),
                Value<int?> ah = const Value.absent(),
                Value<int?> wh = const Value.absent(),
                required String outputState,
              }) => MeasurementSamplesCompanion.insert(
                id: id,
                deviceId: deviceId,
                timestamp: timestamp,
                voltage: voltage,
                current: current,
                power: power,
                temperature: temperature,
                inputVoltage: inputVoltage,
                ah: ah,
                wh: wh,
                outputState: outputState,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MeasurementSamplesTableProcessedTableManager =
    ProcessedTableManager<
      _$Sk120Database,
      $MeasurementSamplesTable,
      MeasurementSample,
      $$MeasurementSamplesTableFilterComposer,
      $$MeasurementSamplesTableOrderingComposer,
      $$MeasurementSamplesTableAnnotationComposer,
      $$MeasurementSamplesTableCreateCompanionBuilder,
      $$MeasurementSamplesTableUpdateCompanionBuilder,
      (
        MeasurementSample,
        BaseReferences<
          _$Sk120Database,
          $MeasurementSamplesTable,
          MeasurementSample
        >,
      ),
      MeasurementSample,
      PrefetchHooks Function()
    >;
typedef $$OutputSessionsTableCreateCompanionBuilder =
    OutputSessionsCompanion Function({
      Value<int> id,
      required String deviceId,
      required DateTime startTime,
      Value<DateTime?> endTime,
      required int durationSeconds,
      Value<double?> averageVoltage,
      Value<double?> averageCurrent,
      Value<double?> maxPower,
      Value<int?> totalAh,
      Value<int?> totalWh,
    });
typedef $$OutputSessionsTableUpdateCompanionBuilder =
    OutputSessionsCompanion Function({
      Value<int> id,
      Value<String> deviceId,
      Value<DateTime> startTime,
      Value<DateTime?> endTime,
      Value<int> durationSeconds,
      Value<double?> averageVoltage,
      Value<double?> averageCurrent,
      Value<double?> maxPower,
      Value<int?> totalAh,
      Value<int?> totalWh,
    });

class $$OutputSessionsTableFilterComposer
    extends Composer<_$Sk120Database, $OutputSessionsTable> {
  $$OutputSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageVoltage => $composableBuilder(
    column: $table.averageVoltage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageCurrent => $composableBuilder(
    column: $table.averageCurrent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxPower => $composableBuilder(
    column: $table.maxPower,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalAh => $composableBuilder(
    column: $table.totalAh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalWh => $composableBuilder(
    column: $table.totalWh,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutputSessionsTableOrderingComposer
    extends Composer<_$Sk120Database, $OutputSessionsTable> {
  $$OutputSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageVoltage => $composableBuilder(
    column: $table.averageVoltage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageCurrent => $composableBuilder(
    column: $table.averageCurrent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxPower => $composableBuilder(
    column: $table.maxPower,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalAh => $composableBuilder(
    column: $table.totalAh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalWh => $composableBuilder(
    column: $table.totalWh,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutputSessionsTableAnnotationComposer
    extends Composer<_$Sk120Database, $OutputSessionsTable> {
  $$OutputSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get averageVoltage => $composableBuilder(
    column: $table.averageVoltage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get averageCurrent => $composableBuilder(
    column: $table.averageCurrent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxPower =>
      $composableBuilder(column: $table.maxPower, builder: (column) => column);

  GeneratedColumn<int> get totalAh =>
      $composableBuilder(column: $table.totalAh, builder: (column) => column);

  GeneratedColumn<int> get totalWh =>
      $composableBuilder(column: $table.totalWh, builder: (column) => column);
}

class $$OutputSessionsTableTableManager
    extends
        RootTableManager<
          _$Sk120Database,
          $OutputSessionsTable,
          OutputSession,
          $$OutputSessionsTableFilterComposer,
          $$OutputSessionsTableOrderingComposer,
          $$OutputSessionsTableAnnotationComposer,
          $$OutputSessionsTableCreateCompanionBuilder,
          $$OutputSessionsTableUpdateCompanionBuilder,
          (
            OutputSession,
            BaseReferences<
              _$Sk120Database,
              $OutputSessionsTable,
              OutputSession
            >,
          ),
          OutputSession,
          PrefetchHooks Function()
        > {
  $$OutputSessionsTableTableManager(
    _$Sk120Database db,
    $OutputSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutputSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutputSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutputSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<double?> averageVoltage = const Value.absent(),
                Value<double?> averageCurrent = const Value.absent(),
                Value<double?> maxPower = const Value.absent(),
                Value<int?> totalAh = const Value.absent(),
                Value<int?> totalWh = const Value.absent(),
              }) => OutputSessionsCompanion(
                id: id,
                deviceId: deviceId,
                startTime: startTime,
                endTime: endTime,
                durationSeconds: durationSeconds,
                averageVoltage: averageVoltage,
                averageCurrent: averageCurrent,
                maxPower: maxPower,
                totalAh: totalAh,
                totalWh: totalWh,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deviceId,
                required DateTime startTime,
                Value<DateTime?> endTime = const Value.absent(),
                required int durationSeconds,
                Value<double?> averageVoltage = const Value.absent(),
                Value<double?> averageCurrent = const Value.absent(),
                Value<double?> maxPower = const Value.absent(),
                Value<int?> totalAh = const Value.absent(),
                Value<int?> totalWh = const Value.absent(),
              }) => OutputSessionsCompanion.insert(
                id: id,
                deviceId: deviceId,
                startTime: startTime,
                endTime: endTime,
                durationSeconds: durationSeconds,
                averageVoltage: averageVoltage,
                averageCurrent: averageCurrent,
                maxPower: maxPower,
                totalAh: totalAh,
                totalWh: totalWh,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutputSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$Sk120Database,
      $OutputSessionsTable,
      OutputSession,
      $$OutputSessionsTableFilterComposer,
      $$OutputSessionsTableOrderingComposer,
      $$OutputSessionsTableAnnotationComposer,
      $$OutputSessionsTableCreateCompanionBuilder,
      $$OutputSessionsTableUpdateCompanionBuilder,
      (
        OutputSession,
        BaseReferences<_$Sk120Database, $OutputSessionsTable, OutputSession>,
      ),
      OutputSession,
      PrefetchHooks Function()
    >;
typedef $$DeviceGroupsTableCreateCompanionBuilder =
    DeviceGroupsCompanion Function({
      Value<int> id,
      required String deviceId,
      required int groupIndex,
      Value<String?> name,
      required String valuesJson,
      required DateTime updatedAt,
    });
typedef $$DeviceGroupsTableUpdateCompanionBuilder =
    DeviceGroupsCompanion Function({
      Value<int> id,
      Value<String> deviceId,
      Value<int> groupIndex,
      Value<String?> name,
      Value<String> valuesJson,
      Value<DateTime> updatedAt,
    });

class $$DeviceGroupsTableFilterComposer
    extends Composer<_$Sk120Database, $DeviceGroupsTable> {
  $$DeviceGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get groupIndex => $composableBuilder(
    column: $table.groupIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valuesJson => $composableBuilder(
    column: $table.valuesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DeviceGroupsTableOrderingComposer
    extends Composer<_$Sk120Database, $DeviceGroupsTable> {
  $$DeviceGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get groupIndex => $composableBuilder(
    column: $table.groupIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valuesJson => $composableBuilder(
    column: $table.valuesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DeviceGroupsTableAnnotationComposer
    extends Composer<_$Sk120Database, $DeviceGroupsTable> {
  $$DeviceGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get groupIndex => $composableBuilder(
    column: $table.groupIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get valuesJson => $composableBuilder(
    column: $table.valuesJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DeviceGroupsTableTableManager
    extends
        RootTableManager<
          _$Sk120Database,
          $DeviceGroupsTable,
          DeviceGroup,
          $$DeviceGroupsTableFilterComposer,
          $$DeviceGroupsTableOrderingComposer,
          $$DeviceGroupsTableAnnotationComposer,
          $$DeviceGroupsTableCreateCompanionBuilder,
          $$DeviceGroupsTableUpdateCompanionBuilder,
          (
            DeviceGroup,
            BaseReferences<_$Sk120Database, $DeviceGroupsTable, DeviceGroup>,
          ),
          DeviceGroup,
          PrefetchHooks Function()
        > {
  $$DeviceGroupsTableTableManager(_$Sk120Database db, $DeviceGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeviceGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeviceGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeviceGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> groupIndex = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String> valuesJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DeviceGroupsCompanion(
                id: id,
                deviceId: deviceId,
                groupIndex: groupIndex,
                name: name,
                valuesJson: valuesJson,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deviceId,
                required int groupIndex,
                Value<String?> name = const Value.absent(),
                required String valuesJson,
                required DateTime updatedAt,
              }) => DeviceGroupsCompanion.insert(
                id: id,
                deviceId: deviceId,
                groupIndex: groupIndex,
                name: name,
                valuesJson: valuesJson,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DeviceGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$Sk120Database,
      $DeviceGroupsTable,
      DeviceGroup,
      $$DeviceGroupsTableFilterComposer,
      $$DeviceGroupsTableOrderingComposer,
      $$DeviceGroupsTableAnnotationComposer,
      $$DeviceGroupsTableCreateCompanionBuilder,
      $$DeviceGroupsTableUpdateCompanionBuilder,
      (
        DeviceGroup,
        BaseReferences<_$Sk120Database, $DeviceGroupsTable, DeviceGroup>,
      ),
      DeviceGroup,
      PrefetchHooks Function()
    >;
typedef $$CommunicationLogsTableCreateCompanionBuilder =
    CommunicationLogsCompanion Function({
      Value<int> id,
      required String deviceId,
      required DateTime timestamp,
      required String direction,
      required String rawHex,
      Value<String?> parsedMessage,
      required bool success,
      Value<String?> error,
    });
typedef $$CommunicationLogsTableUpdateCompanionBuilder =
    CommunicationLogsCompanion Function({
      Value<int> id,
      Value<String> deviceId,
      Value<DateTime> timestamp,
      Value<String> direction,
      Value<String> rawHex,
      Value<String?> parsedMessage,
      Value<bool> success,
      Value<String?> error,
    });

class $$CommunicationLogsTableFilterComposer
    extends Composer<_$Sk120Database, $CommunicationLogsTable> {
  $$CommunicationLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawHex => $composableBuilder(
    column: $table.rawHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parsedMessage => $composableBuilder(
    column: $table.parsedMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get success => $composableBuilder(
    column: $table.success,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CommunicationLogsTableOrderingComposer
    extends Composer<_$Sk120Database, $CommunicationLogsTable> {
  $$CommunicationLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawHex => $composableBuilder(
    column: $table.rawHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parsedMessage => $composableBuilder(
    column: $table.parsedMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get success => $composableBuilder(
    column: $table.success,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CommunicationLogsTableAnnotationComposer
    extends Composer<_$Sk120Database, $CommunicationLogsTable> {
  $$CommunicationLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get rawHex =>
      $composableBuilder(column: $table.rawHex, builder: (column) => column);

  GeneratedColumn<String> get parsedMessage => $composableBuilder(
    column: $table.parsedMessage,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get success =>
      $composableBuilder(column: $table.success, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);
}

class $$CommunicationLogsTableTableManager
    extends
        RootTableManager<
          _$Sk120Database,
          $CommunicationLogsTable,
          CommunicationLog,
          $$CommunicationLogsTableFilterComposer,
          $$CommunicationLogsTableOrderingComposer,
          $$CommunicationLogsTableAnnotationComposer,
          $$CommunicationLogsTableCreateCompanionBuilder,
          $$CommunicationLogsTableUpdateCompanionBuilder,
          (
            CommunicationLog,
            BaseReferences<
              _$Sk120Database,
              $CommunicationLogsTable,
              CommunicationLog
            >,
          ),
          CommunicationLog,
          PrefetchHooks Function()
        > {
  $$CommunicationLogsTableTableManager(
    _$Sk120Database db,
    $CommunicationLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommunicationLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CommunicationLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CommunicationLogsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<String> rawHex = const Value.absent(),
                Value<String?> parsedMessage = const Value.absent(),
                Value<bool> success = const Value.absent(),
                Value<String?> error = const Value.absent(),
              }) => CommunicationLogsCompanion(
                id: id,
                deviceId: deviceId,
                timestamp: timestamp,
                direction: direction,
                rawHex: rawHex,
                parsedMessage: parsedMessage,
                success: success,
                error: error,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deviceId,
                required DateTime timestamp,
                required String direction,
                required String rawHex,
                Value<String?> parsedMessage = const Value.absent(),
                required bool success,
                Value<String?> error = const Value.absent(),
              }) => CommunicationLogsCompanion.insert(
                id: id,
                deviceId: deviceId,
                timestamp: timestamp,
                direction: direction,
                rawHex: rawHex,
                parsedMessage: parsedMessage,
                success: success,
                error: error,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CommunicationLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$Sk120Database,
      $CommunicationLogsTable,
      CommunicationLog,
      $$CommunicationLogsTableFilterComposer,
      $$CommunicationLogsTableOrderingComposer,
      $$CommunicationLogsTableAnnotationComposer,
      $$CommunicationLogsTableCreateCompanionBuilder,
      $$CommunicationLogsTableUpdateCompanionBuilder,
      (
        CommunicationLog,
        BaseReferences<
          _$Sk120Database,
          $CommunicationLogsTable,
          CommunicationLog
        >,
      ),
      CommunicationLog,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$Sk120Database, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$Sk120Database, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$Sk120Database, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$Sk120Database,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$Sk120Database, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$Sk120Database db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$Sk120Database,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$Sk120Database, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $Sk120DatabaseManager {
  final _$Sk120Database _db;
  $Sk120DatabaseManager(this._db);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
  $$PresetsTableTableManager get presets =>
      $$PresetsTableTableManager(_db, _db.presets);
  $$MeasurementSamplesTableTableManager get measurementSamples =>
      $$MeasurementSamplesTableTableManager(_db, _db.measurementSamples);
  $$OutputSessionsTableTableManager get outputSessions =>
      $$OutputSessionsTableTableManager(_db, _db.outputSessions);
  $$DeviceGroupsTableTableManager get deviceGroups =>
      $$DeviceGroupsTableTableManager(_db, _db.deviceGroups);
  $$CommunicationLogsTableTableManager get communicationLogs =>
      $$CommunicationLogsTableTableManager(_db, _db.communicationLogs);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
