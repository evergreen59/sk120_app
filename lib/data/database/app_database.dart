import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Devices extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get model => text().nullable()();
  TextColumn get firmwareVersion => text().nullable()();
  TextColumn get bleDeviceId => text().nullable()();
  IntColumn get lastRssi => integer().nullable()();
  DateTimeColumn get lastSeen => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get mode => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Presets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text().nullable()();
  TextColumn get name => text()();
  RealColumn get voltage => real()();
  RealColumn get current => real()();
  DateTimeColumn get createdAt => dateTime()();
}

class MeasurementSamples extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text()();
  DateTimeColumn get timestamp => dateTime()();
  RealColumn get voltage => real().nullable()();
  RealColumn get current => real().nullable()();
  RealColumn get power => real().nullable()();
  RealColumn get temperature => real().nullable()();
  RealColumn get inputVoltage => real().nullable()();
  IntColumn get ah => integer().nullable()();
  IntColumn get wh => integer().nullable()();
  TextColumn get outputState => text()();
}

class OutputSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  IntColumn get durationSeconds => integer()();
  RealColumn get averageVoltage => real().nullable()();
  RealColumn get averageCurrent => real().nullable()();
  RealColumn get maxPower => real().nullable()();
  IntColumn get totalAh => integer().nullable()();
  IntColumn get totalWh => integer().nullable()();
}

class DeviceGroups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text()();
  IntColumn get groupIndex => integer()();
  TextColumn get name => text().nullable()();
  TextColumn get valuesJson => text()();
  DateTimeColumn get updatedAt => dateTime()();
}

class CommunicationLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get direction => text()();
  TextColumn get rawHex => text()();
  TextColumn get parsedMessage => text().nullable()();
  BoolColumn get success => boolean()();
  TextColumn get error => text().nullable()();
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    Devices,
    Presets,
    MeasurementSamples,
    OutputSessions,
    DeviceGroups,
    CommunicationLogs,
    AppSettings,
  ],
)
class Sk120Database extends _$Sk120Database {
  Sk120Database({QueryExecutor? executor})
    : super(executor ?? driftDatabase(name: 'xy_sk120_control'));

  Sk120Database.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration =>
      MigrationStrategy(onCreate: (Migrator migrator) => migrator.createAll());
}
