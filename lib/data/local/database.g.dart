// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

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
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
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
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appVersionMeta = const VerificationMeta(
    'appVersion',
  );
  @override
  late final GeneratedColumn<String> appVersion = GeneratedColumn<String>(
    'app_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCurrentDeviceMeta = const VerificationMeta(
    'isCurrentDevice',
  );
  @override
  late final GeneratedColumn<bool> isCurrentDevice = GeneratedColumn<bool>(
    'is_current_device',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_current_device" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _registeredAtMeta = const VerificationMeta(
    'registeredAt',
  );
  @override
  late final GeneratedColumn<DateTime> registeredAt = GeneratedColumn<DateTime>(
    'registered_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    platform,
    appVersion,
    isCurrentDevice,
    registeredAt,
    lastSeenAt,
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
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
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
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    } else if (isInserting) {
      context.missing(_platformMeta);
    }
    if (data.containsKey('app_version')) {
      context.handle(
        _appVersionMeta,
        appVersion.isAcceptableOrUnknown(data['app_version']!, _appVersionMeta),
      );
    }
    if (data.containsKey('is_current_device')) {
      context.handle(
        _isCurrentDeviceMeta,
        isCurrentDevice.isAcceptableOrUnknown(
          data['is_current_device']!,
          _isCurrentDeviceMeta,
        ),
      );
    }
    if (data.containsKey('registered_at')) {
      context.handle(
        _registeredAtMeta,
        registeredAt.isAcceptableOrUnknown(
          data['registered_at']!,
          _registeredAtMeta,
        ),
      );
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
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
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      )!,
      appVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_version'],
      ),
      isCurrentDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_current_device'],
      )!,
      registeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}registered_at'],
      )!,
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
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
  final String? userId;
  final String name;
  final String platform;
  final String? appVersion;
  final bool isCurrentDevice;
  final DateTime registeredAt;
  final DateTime lastSeenAt;
  const Device({
    required this.id,
    this.userId,
    required this.name,
    required this.platform,
    this.appVersion,
    required this.isCurrentDevice,
    required this.registeredAt,
    required this.lastSeenAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['name'] = Variable<String>(name);
    map['platform'] = Variable<String>(platform);
    if (!nullToAbsent || appVersion != null) {
      map['app_version'] = Variable<String>(appVersion);
    }
    map['is_current_device'] = Variable<bool>(isCurrentDevice);
    map['registered_at'] = Variable<DateTime>(registeredAt);
    map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      name: Value(name),
      platform: Value(platform),
      appVersion: appVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(appVersion),
      isCurrentDevice: Value(isCurrentDevice),
      registeredAt: Value(registeredAt),
      lastSeenAt: Value(lastSeenAt),
    );
  }

  factory Device.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Device(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      platform: serializer.fromJson<String>(json['platform']),
      appVersion: serializer.fromJson<String?>(json['appVersion']),
      isCurrentDevice: serializer.fromJson<bool>(json['isCurrentDevice']),
      registeredAt: serializer.fromJson<DateTime>(json['registeredAt']),
      lastSeenAt: serializer.fromJson<DateTime>(json['lastSeenAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'name': serializer.toJson<String>(name),
      'platform': serializer.toJson<String>(platform),
      'appVersion': serializer.toJson<String?>(appVersion),
      'isCurrentDevice': serializer.toJson<bool>(isCurrentDevice),
      'registeredAt': serializer.toJson<DateTime>(registeredAt),
      'lastSeenAt': serializer.toJson<DateTime>(lastSeenAt),
    };
  }

  Device copyWith({
    String? id,
    Value<String?> userId = const Value.absent(),
    String? name,
    String? platform,
    Value<String?> appVersion = const Value.absent(),
    bool? isCurrentDevice,
    DateTime? registeredAt,
    DateTime? lastSeenAt,
  }) => Device(
    id: id ?? this.id,
    userId: userId.present ? userId.value : this.userId,
    name: name ?? this.name,
    platform: platform ?? this.platform,
    appVersion: appVersion.present ? appVersion.value : this.appVersion,
    isCurrentDevice: isCurrentDevice ?? this.isCurrentDevice,
    registeredAt: registeredAt ?? this.registeredAt,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
  );
  Device copyWithCompanion(DevicesCompanion data) {
    return Device(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      platform: data.platform.present ? data.platform.value : this.platform,
      appVersion: data.appVersion.present
          ? data.appVersion.value
          : this.appVersion,
      isCurrentDevice: data.isCurrentDevice.present
          ? data.isCurrentDevice.value
          : this.isCurrentDevice,
      registeredAt: data.registeredAt.present
          ? data.registeredAt.value
          : this.registeredAt,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Device(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('platform: $platform, ')
          ..write('appVersion: $appVersion, ')
          ..write('isCurrentDevice: $isCurrentDevice, ')
          ..write('registeredAt: $registeredAt, ')
          ..write('lastSeenAt: $lastSeenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    platform,
    appVersion,
    isCurrentDevice,
    registeredAt,
    lastSeenAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Device &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.platform == this.platform &&
          other.appVersion == this.appVersion &&
          other.isCurrentDevice == this.isCurrentDevice &&
          other.registeredAt == this.registeredAt &&
          other.lastSeenAt == this.lastSeenAt);
}

class DevicesCompanion extends UpdateCompanion<Device> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<String> name;
  final Value<String> platform;
  final Value<String?> appVersion;
  final Value<bool> isCurrentDevice;
  final Value<DateTime> registeredAt;
  final Value<DateTime> lastSeenAt;
  final Value<int> rowid;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.platform = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.isCurrentDevice = const Value.absent(),
    this.registeredAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required String name,
    required String platform,
    this.appVersion = const Value.absent(),
    this.isCurrentDevice = const Value.absent(),
    this.registeredAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       platform = Value(platform);
  static Insertable<Device> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? platform,
    Expression<String>? appVersion,
    Expression<bool>? isCurrentDevice,
    Expression<DateTime>? registeredAt,
    Expression<DateTime>? lastSeenAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (platform != null) 'platform': platform,
      if (appVersion != null) 'app_version': appVersion,
      if (isCurrentDevice != null) 'is_current_device': isCurrentDevice,
      if (registeredAt != null) 'registered_at': registeredAt,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<String>? name,
    Value<String>? platform,
    Value<String?>? appVersion,
    Value<bool>? isCurrentDevice,
    Value<DateTime>? registeredAt,
    Value<DateTime>? lastSeenAt,
    Value<int>? rowid,
  }) {
    return DevicesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      platform: platform ?? this.platform,
      appVersion: appVersion ?? this.appVersion,
      isCurrentDevice: isCurrentDevice ?? this.isCurrentDevice,
      registeredAt: registeredAt ?? this.registeredAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (appVersion.present) {
      map['app_version'] = Variable<String>(appVersion.value);
    }
    if (isCurrentDevice.present) {
      map['is_current_device'] = Variable<bool>(isCurrentDevice.value);
    }
    if (registeredAt.present) {
      map['registered_at'] = Variable<DateTime>(registeredAt.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
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
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('platform: $platform, ')
          ..write('appVersion: $appVersion, ')
          ..write('isCurrentDevice: $isCurrentDevice, ')
          ..write('registeredAt: $registeredAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocationPointsTable extends LocationPoints
    with TableInfo<$LocationPointsTable, LocationPoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationPointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localRevMeta = const VerificationMeta(
    'localRev',
  );
  @override
  late final GeneratedColumn<int> localRev = GeneratedColumn<int>(
    'local_rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _serverRevMeta = const VerificationMeta(
    'serverRev',
  );
  @override
  late final GeneratedColumn<int> serverRev = GeneratedColumn<int>(
    'server_rev',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncState, String> syncState =
      GeneratedColumn<String>(
        'sync_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('localOnly'),
      ).withConverter<SyncState>($LocationPointsTable.$convertersyncState);
  @override
  late final GeneratedColumnWithTypeConverter<RecordSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RecordSource>($LocationPointsTable.$convertersource);
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _altitudeMeta = const VerificationMeta(
    'altitude',
  );
  @override
  late final GeneratedColumn<double> altitude = GeneratedColumn<double>(
    'altitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _horizontalAccuracyMeta =
      const VerificationMeta('horizontalAccuracy');
  @override
  late final GeneratedColumn<double> horizontalAccuracy =
      GeneratedColumn<double>(
        'horizontal_accuracy',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _verticalAccuracyMeta = const VerificationMeta(
    'verticalAccuracy',
  );
  @override
  late final GeneratedColumn<double> verticalAccuracy = GeneratedColumn<double>(
    'vertical_accuracy',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<double> speed = GeneratedColumn<double>(
    'speed',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _headingMeta = const VerificationMeta(
    'heading',
  );
  @override
  late final GeneratedColumn<double> heading = GeneratedColumn<double>(
    'heading',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batteryLevelMeta = const VerificationMeta(
    'batteryLevel',
  );
  @override
  late final GeneratedColumn<int> batteryLevel = GeneratedColumn<int>(
    'battery_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Connectivity, String>
  connectivity = GeneratedColumn<String>(
    'connectivity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unknown'),
  ).withConverter<Connectivity>($LocationPointsTable.$converterconnectivity);
  @override
  late final GeneratedColumnWithTypeConverter<MonitoringMode, String>
  monitoringMode =
      GeneratedColumn<String>(
        'monitoring_mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MonitoringMode>(
        $LocationPointsTable.$convertermonitoringMode,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    deviceId,
    createdAt,
    updatedAt,
    deletedAt,
    localRev,
    serverRev,
    syncState,
    source,
    latitude,
    longitude,
    altitude,
    horizontalAccuracy,
    verticalAccuracy,
    speed,
    heading,
    recordedAt,
    batteryLevel,
    connectivity,
    monitoringMode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'location_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocationPoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('local_rev')) {
      context.handle(
        _localRevMeta,
        localRev.isAcceptableOrUnknown(data['local_rev']!, _localRevMeta),
      );
    }
    if (data.containsKey('server_rev')) {
      context.handle(
        _serverRevMeta,
        serverRev.isAcceptableOrUnknown(data['server_rev']!, _serverRevMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('altitude')) {
      context.handle(
        _altitudeMeta,
        altitude.isAcceptableOrUnknown(data['altitude']!, _altitudeMeta),
      );
    }
    if (data.containsKey('horizontal_accuracy')) {
      context.handle(
        _horizontalAccuracyMeta,
        horizontalAccuracy.isAcceptableOrUnknown(
          data['horizontal_accuracy']!,
          _horizontalAccuracyMeta,
        ),
      );
    }
    if (data.containsKey('vertical_accuracy')) {
      context.handle(
        _verticalAccuracyMeta,
        verticalAccuracy.isAcceptableOrUnknown(
          data['vertical_accuracy']!,
          _verticalAccuracyMeta,
        ),
      );
    }
    if (data.containsKey('speed')) {
      context.handle(
        _speedMeta,
        speed.isAcceptableOrUnknown(data['speed']!, _speedMeta),
      );
    }
    if (data.containsKey('heading')) {
      context.handle(
        _headingMeta,
        heading.isAcceptableOrUnknown(data['heading']!, _headingMeta),
      );
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('battery_level')) {
      context.handle(
        _batteryLevelMeta,
        batteryLevel.isAcceptableOrUnknown(
          data['battery_level']!,
          _batteryLevelMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocationPoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocationPoint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      localRev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_rev'],
      )!,
      serverRev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_rev'],
      ),
      syncState: $LocationPointsTable.$convertersyncState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_state'],
        )!,
      ),
      source: $LocationPointsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      altitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}altitude'],
      ),
      horizontalAccuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}horizontal_accuracy'],
      ),
      verticalAccuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vertical_accuracy'],
      ),
      speed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed'],
      ),
      heading: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}heading'],
      ),
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      batteryLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}battery_level'],
      ),
      connectivity: $LocationPointsTable.$converterconnectivity.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}connectivity'],
        )!,
      ),
      monitoringMode: $LocationPointsTable.$convertermonitoringMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}monitoring_mode'],
        )!,
      ),
    );
  }

  @override
  $LocationPointsTable createAlias(String alias) {
    return $LocationPointsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncState, String, String> $convertersyncState =
      const EnumNameConverter<SyncState>(SyncState.values);
  static JsonTypeConverter2<RecordSource, String, String> $convertersource =
      const EnumNameConverter<RecordSource>(RecordSource.values);
  static JsonTypeConverter2<Connectivity, String, String>
  $converterconnectivity = const EnumNameConverter<Connectivity>(
    Connectivity.values,
  );
  static JsonTypeConverter2<MonitoringMode, String, String>
  $convertermonitoringMode = const EnumNameConverter<MonitoringMode>(
    MonitoringMode.values,
  );
}

class LocationPoint extends DataClass implements Insertable<LocationPoint> {
  final String id;
  final String? userId;
  final String? deviceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int localRev;
  final int? serverRev;
  final SyncState syncState;
  final RecordSource source;
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? horizontalAccuracy;
  final double? verticalAccuracy;
  final double? speed;
  final double? heading;
  final DateTime recordedAt;
  final int? batteryLevel;
  final Connectivity connectivity;
  final MonitoringMode monitoringMode;
  const LocationPoint({
    required this.id,
    this.userId,
    this.deviceId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.localRev,
    this.serverRev,
    required this.syncState,
    required this.source,
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.horizontalAccuracy,
    this.verticalAccuracy,
    this.speed,
    this.heading,
    required this.recordedAt,
    this.batteryLevel,
    required this.connectivity,
    required this.monitoringMode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['local_rev'] = Variable<int>(localRev);
    if (!nullToAbsent || serverRev != null) {
      map['server_rev'] = Variable<int>(serverRev);
    }
    {
      map['sync_state'] = Variable<String>(
        $LocationPointsTable.$convertersyncState.toSql(syncState),
      );
    }
    {
      map['source'] = Variable<String>(
        $LocationPointsTable.$convertersource.toSql(source),
      );
    }
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || altitude != null) {
      map['altitude'] = Variable<double>(altitude);
    }
    if (!nullToAbsent || horizontalAccuracy != null) {
      map['horizontal_accuracy'] = Variable<double>(horizontalAccuracy);
    }
    if (!nullToAbsent || verticalAccuracy != null) {
      map['vertical_accuracy'] = Variable<double>(verticalAccuracy);
    }
    if (!nullToAbsent || speed != null) {
      map['speed'] = Variable<double>(speed);
    }
    if (!nullToAbsent || heading != null) {
      map['heading'] = Variable<double>(heading);
    }
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    if (!nullToAbsent || batteryLevel != null) {
      map['battery_level'] = Variable<int>(batteryLevel);
    }
    {
      map['connectivity'] = Variable<String>(
        $LocationPointsTable.$converterconnectivity.toSql(connectivity),
      );
    }
    {
      map['monitoring_mode'] = Variable<String>(
        $LocationPointsTable.$convertermonitoringMode.toSql(monitoringMode),
      );
    }
    return map;
  }

  LocationPointsCompanion toCompanion(bool nullToAbsent) {
    return LocationPointsCompanion(
      id: Value(id),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localRev: Value(localRev),
      serverRev: serverRev == null && nullToAbsent
          ? const Value.absent()
          : Value(serverRev),
      syncState: Value(syncState),
      source: Value(source),
      latitude: Value(latitude),
      longitude: Value(longitude),
      altitude: altitude == null && nullToAbsent
          ? const Value.absent()
          : Value(altitude),
      horizontalAccuracy: horizontalAccuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(horizontalAccuracy),
      verticalAccuracy: verticalAccuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(verticalAccuracy),
      speed: speed == null && nullToAbsent
          ? const Value.absent()
          : Value(speed),
      heading: heading == null && nullToAbsent
          ? const Value.absent()
          : Value(heading),
      recordedAt: Value(recordedAt),
      batteryLevel: batteryLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(batteryLevel),
      connectivity: Value(connectivity),
      monitoringMode: Value(monitoringMode),
    );
  }

  factory LocationPoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocationPoint(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      localRev: serializer.fromJson<int>(json['localRev']),
      serverRev: serializer.fromJson<int?>(json['serverRev']),
      syncState: $LocationPointsTable.$convertersyncState.fromJson(
        serializer.fromJson<String>(json['syncState']),
      ),
      source: $LocationPointsTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      altitude: serializer.fromJson<double?>(json['altitude']),
      horizontalAccuracy: serializer.fromJson<double?>(
        json['horizontalAccuracy'],
      ),
      verticalAccuracy: serializer.fromJson<double?>(json['verticalAccuracy']),
      speed: serializer.fromJson<double?>(json['speed']),
      heading: serializer.fromJson<double?>(json['heading']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      batteryLevel: serializer.fromJson<int?>(json['batteryLevel']),
      connectivity: $LocationPointsTable.$converterconnectivity.fromJson(
        serializer.fromJson<String>(json['connectivity']),
      ),
      monitoringMode: $LocationPointsTable.$convertermonitoringMode.fromJson(
        serializer.fromJson<String>(json['monitoringMode']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'deviceId': serializer.toJson<String?>(deviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'localRev': serializer.toJson<int>(localRev),
      'serverRev': serializer.toJson<int?>(serverRev),
      'syncState': serializer.toJson<String>(
        $LocationPointsTable.$convertersyncState.toJson(syncState),
      ),
      'source': serializer.toJson<String>(
        $LocationPointsTable.$convertersource.toJson(source),
      ),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'altitude': serializer.toJson<double?>(altitude),
      'horizontalAccuracy': serializer.toJson<double?>(horizontalAccuracy),
      'verticalAccuracy': serializer.toJson<double?>(verticalAccuracy),
      'speed': serializer.toJson<double?>(speed),
      'heading': serializer.toJson<double?>(heading),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'batteryLevel': serializer.toJson<int?>(batteryLevel),
      'connectivity': serializer.toJson<String>(
        $LocationPointsTable.$converterconnectivity.toJson(connectivity),
      ),
      'monitoringMode': serializer.toJson<String>(
        $LocationPointsTable.$convertermonitoringMode.toJson(monitoringMode),
      ),
    };
  }

  LocationPoint copyWith({
    String? id,
    Value<String?> userId = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? localRev,
    Value<int?> serverRev = const Value.absent(),
    SyncState? syncState,
    RecordSource? source,
    double? latitude,
    double? longitude,
    Value<double?> altitude = const Value.absent(),
    Value<double?> horizontalAccuracy = const Value.absent(),
    Value<double?> verticalAccuracy = const Value.absent(),
    Value<double?> speed = const Value.absent(),
    Value<double?> heading = const Value.absent(),
    DateTime? recordedAt,
    Value<int?> batteryLevel = const Value.absent(),
    Connectivity? connectivity,
    MonitoringMode? monitoringMode,
  }) => LocationPoint(
    id: id ?? this.id,
    userId: userId.present ? userId.value : this.userId,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localRev: localRev ?? this.localRev,
    serverRev: serverRev.present ? serverRev.value : this.serverRev,
    syncState: syncState ?? this.syncState,
    source: source ?? this.source,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    altitude: altitude.present ? altitude.value : this.altitude,
    horizontalAccuracy: horizontalAccuracy.present
        ? horizontalAccuracy.value
        : this.horizontalAccuracy,
    verticalAccuracy: verticalAccuracy.present
        ? verticalAccuracy.value
        : this.verticalAccuracy,
    speed: speed.present ? speed.value : this.speed,
    heading: heading.present ? heading.value : this.heading,
    recordedAt: recordedAt ?? this.recordedAt,
    batteryLevel: batteryLevel.present ? batteryLevel.value : this.batteryLevel,
    connectivity: connectivity ?? this.connectivity,
    monitoringMode: monitoringMode ?? this.monitoringMode,
  );
  LocationPoint copyWithCompanion(LocationPointsCompanion data) {
    return LocationPoint(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localRev: data.localRev.present ? data.localRev.value : this.localRev,
      serverRev: data.serverRev.present ? data.serverRev.value : this.serverRev,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      source: data.source.present ? data.source.value : this.source,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      altitude: data.altitude.present ? data.altitude.value : this.altitude,
      horizontalAccuracy: data.horizontalAccuracy.present
          ? data.horizontalAccuracy.value
          : this.horizontalAccuracy,
      verticalAccuracy: data.verticalAccuracy.present
          ? data.verticalAccuracy.value
          : this.verticalAccuracy,
      speed: data.speed.present ? data.speed.value : this.speed,
      heading: data.heading.present ? data.heading.value : this.heading,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      batteryLevel: data.batteryLevel.present
          ? data.batteryLevel.value
          : this.batteryLevel,
      connectivity: data.connectivity.present
          ? data.connectivity.value
          : this.connectivity,
      monitoringMode: data.monitoringMode.present
          ? data.monitoringMode.value
          : this.monitoringMode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocationPoint(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
          ..write('serverRev: $serverRev, ')
          ..write('syncState: $syncState, ')
          ..write('source: $source, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitude: $altitude, ')
          ..write('horizontalAccuracy: $horizontalAccuracy, ')
          ..write('verticalAccuracy: $verticalAccuracy, ')
          ..write('speed: $speed, ')
          ..write('heading: $heading, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('batteryLevel: $batteryLevel, ')
          ..write('connectivity: $connectivity, ')
          ..write('monitoringMode: $monitoringMode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    userId,
    deviceId,
    createdAt,
    updatedAt,
    deletedAt,
    localRev,
    serverRev,
    syncState,
    source,
    latitude,
    longitude,
    altitude,
    horizontalAccuracy,
    verticalAccuracy,
    speed,
    heading,
    recordedAt,
    batteryLevel,
    connectivity,
    monitoringMode,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocationPoint &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localRev == this.localRev &&
          other.serverRev == this.serverRev &&
          other.syncState == this.syncState &&
          other.source == this.source &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.altitude == this.altitude &&
          other.horizontalAccuracy == this.horizontalAccuracy &&
          other.verticalAccuracy == this.verticalAccuracy &&
          other.speed == this.speed &&
          other.heading == this.heading &&
          other.recordedAt == this.recordedAt &&
          other.batteryLevel == this.batteryLevel &&
          other.connectivity == this.connectivity &&
          other.monitoringMode == this.monitoringMode);
}

class LocationPointsCompanion extends UpdateCompanion<LocationPoint> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<String?> deviceId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> localRev;
  final Value<int?> serverRev;
  final Value<SyncState> syncState;
  final Value<RecordSource> source;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double?> altitude;
  final Value<double?> horizontalAccuracy;
  final Value<double?> verticalAccuracy;
  final Value<double?> speed;
  final Value<double?> heading;
  final Value<DateTime> recordedAt;
  final Value<int?> batteryLevel;
  final Value<Connectivity> connectivity;
  final Value<MonitoringMode> monitoringMode;
  final Value<int> rowid;
  const LocationPointsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.serverRev = const Value.absent(),
    this.syncState = const Value.absent(),
    this.source = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.altitude = const Value.absent(),
    this.horizontalAccuracy = const Value.absent(),
    this.verticalAccuracy = const Value.absent(),
    this.speed = const Value.absent(),
    this.heading = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.batteryLevel = const Value.absent(),
    this.connectivity = const Value.absent(),
    this.monitoringMode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocationPointsCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.serverRev = const Value.absent(),
    this.syncState = const Value.absent(),
    required RecordSource source,
    required double latitude,
    required double longitude,
    this.altitude = const Value.absent(),
    this.horizontalAccuracy = const Value.absent(),
    this.verticalAccuracy = const Value.absent(),
    this.speed = const Value.absent(),
    this.heading = const Value.absent(),
    required DateTime recordedAt,
    this.batteryLevel = const Value.absent(),
    this.connectivity = const Value.absent(),
    required MonitoringMode monitoringMode,
    this.rowid = const Value.absent(),
  }) : source = Value(source),
       latitude = Value(latitude),
       longitude = Value(longitude),
       recordedAt = Value(recordedAt),
       monitoringMode = Value(monitoringMode);
  static Insertable<LocationPoint> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? deviceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? localRev,
    Expression<int>? serverRev,
    Expression<String>? syncState,
    Expression<String>? source,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? altitude,
    Expression<double>? horizontalAccuracy,
    Expression<double>? verticalAccuracy,
    Expression<double>? speed,
    Expression<double>? heading,
    Expression<DateTime>? recordedAt,
    Expression<int>? batteryLevel,
    Expression<String>? connectivity,
    Expression<String>? monitoringMode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localRev != null) 'local_rev': localRev,
      if (serverRev != null) 'server_rev': serverRev,
      if (syncState != null) 'sync_state': syncState,
      if (source != null) 'source': source,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (altitude != null) 'altitude': altitude,
      if (horizontalAccuracy != null) 'horizontal_accuracy': horizontalAccuracy,
      if (verticalAccuracy != null) 'vertical_accuracy': verticalAccuracy,
      if (speed != null) 'speed': speed,
      if (heading != null) 'heading': heading,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (batteryLevel != null) 'battery_level': batteryLevel,
      if (connectivity != null) 'connectivity': connectivity,
      if (monitoringMode != null) 'monitoring_mode': monitoringMode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocationPointsCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<String?>? deviceId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? localRev,
    Value<int?>? serverRev,
    Value<SyncState>? syncState,
    Value<RecordSource>? source,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double?>? altitude,
    Value<double?>? horizontalAccuracy,
    Value<double?>? verticalAccuracy,
    Value<double?>? speed,
    Value<double?>? heading,
    Value<DateTime>? recordedAt,
    Value<int?>? batteryLevel,
    Value<Connectivity>? connectivity,
    Value<MonitoringMode>? monitoringMode,
    Value<int>? rowid,
  }) {
    return LocationPointsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localRev: localRev ?? this.localRev,
      serverRev: serverRev ?? this.serverRev,
      syncState: syncState ?? this.syncState,
      source: source ?? this.source,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      horizontalAccuracy: horizontalAccuracy ?? this.horizontalAccuracy,
      verticalAccuracy: verticalAccuracy ?? this.verticalAccuracy,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      recordedAt: recordedAt ?? this.recordedAt,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      connectivity: connectivity ?? this.connectivity,
      monitoringMode: monitoringMode ?? this.monitoringMode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (localRev.present) {
      map['local_rev'] = Variable<int>(localRev.value);
    }
    if (serverRev.present) {
      map['server_rev'] = Variable<int>(serverRev.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(
        $LocationPointsTable.$convertersyncState.toSql(syncState.value),
      );
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $LocationPointsTable.$convertersource.toSql(source.value),
      );
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (altitude.present) {
      map['altitude'] = Variable<double>(altitude.value);
    }
    if (horizontalAccuracy.present) {
      map['horizontal_accuracy'] = Variable<double>(horizontalAccuracy.value);
    }
    if (verticalAccuracy.present) {
      map['vertical_accuracy'] = Variable<double>(verticalAccuracy.value);
    }
    if (speed.present) {
      map['speed'] = Variable<double>(speed.value);
    }
    if (heading.present) {
      map['heading'] = Variable<double>(heading.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (batteryLevel.present) {
      map['battery_level'] = Variable<int>(batteryLevel.value);
    }
    if (connectivity.present) {
      map['connectivity'] = Variable<String>(
        $LocationPointsTable.$converterconnectivity.toSql(connectivity.value),
      );
    }
    if (monitoringMode.present) {
      map['monitoring_mode'] = Variable<String>(
        $LocationPointsTable.$convertermonitoringMode.toSql(
          monitoringMode.value,
        ),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationPointsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
          ..write('serverRev: $serverRev, ')
          ..write('syncState: $syncState, ')
          ..write('source: $source, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitude: $altitude, ')
          ..write('horizontalAccuracy: $horizontalAccuracy, ')
          ..write('verticalAccuracy: $verticalAccuracy, ')
          ..write('speed: $speed, ')
          ..write('heading: $heading, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('batteryLevel: $batteryLevel, ')
          ..write('connectivity: $connectivity, ')
          ..write('monitoringMode: $monitoringMode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HealthSamplesTable extends HealthSamples
    with TableInfo<$HealthSamplesTable, HealthSample> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HealthSamplesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localRevMeta = const VerificationMeta(
    'localRev',
  );
  @override
  late final GeneratedColumn<int> localRev = GeneratedColumn<int>(
    'local_rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _serverRevMeta = const VerificationMeta(
    'serverRev',
  );
  @override
  late final GeneratedColumn<int> serverRev = GeneratedColumn<int>(
    'server_rev',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncState, String> syncState =
      GeneratedColumn<String>(
        'sync_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('localOnly'),
      ).withConverter<SyncState>($HealthSamplesTable.$convertersyncState);
  @override
  late final GeneratedColumnWithTypeConverter<RecordSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RecordSource>($HealthSamplesTable.$convertersource);
  @override
  late final GeneratedColumnWithTypeConverter<HealthMetricType, String>
  metricType = GeneratedColumn<String>(
    'metric_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<HealthMetricType>($HealthSamplesTable.$convertermetricType);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    deviceId,
    createdAt,
    updatedAt,
    deletedAt,
    localRev,
    serverRev,
    syncState,
    source,
    metricType,
    value,
    unit,
    recordedAt,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'health_samples';
  @override
  VerificationContext validateIntegrity(
    Insertable<HealthSample> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('local_rev')) {
      context.handle(
        _localRevMeta,
        localRev.isAcceptableOrUnknown(data['local_rev']!, _localRevMeta),
      );
    }
    if (data.containsKey('server_rev')) {
      context.handle(
        _serverRevMeta,
        serverRev.isAcceptableOrUnknown(data['server_rev']!, _serverRevMeta),
      );
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HealthSample map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HealthSample(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      localRev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_rev'],
      )!,
      serverRev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_rev'],
      ),
      syncState: $HealthSamplesTable.$convertersyncState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_state'],
        )!,
      ),
      source: $HealthSamplesTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      metricType: $HealthSamplesTable.$convertermetricType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}metric_type'],
        )!,
      ),
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
    );
  }

  @override
  $HealthSamplesTable createAlias(String alias) {
    return $HealthSamplesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncState, String, String> $convertersyncState =
      const EnumNameConverter<SyncState>(SyncState.values);
  static JsonTypeConverter2<RecordSource, String, String> $convertersource =
      const EnumNameConverter<RecordSource>(RecordSource.values);
  static JsonTypeConverter2<HealthMetricType, String, String>
  $convertermetricType = const EnumNameConverter<HealthMetricType>(
    HealthMetricType.values,
  );
}

class HealthSample extends DataClass implements Insertable<HealthSample> {
  final String id;
  final String? userId;
  final String? deviceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int localRev;
  final int? serverRev;
  final SyncState syncState;
  final RecordSource source;
  final HealthMetricType metricType;
  final double value;
  final String unit;
  final DateTime recordedAt;
  final String note;
  const HealthSample({
    required this.id,
    this.userId,
    this.deviceId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.localRev,
    this.serverRev,
    required this.syncState,
    required this.source,
    required this.metricType,
    required this.value,
    required this.unit,
    required this.recordedAt,
    required this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['local_rev'] = Variable<int>(localRev);
    if (!nullToAbsent || serverRev != null) {
      map['server_rev'] = Variable<int>(serverRev);
    }
    {
      map['sync_state'] = Variable<String>(
        $HealthSamplesTable.$convertersyncState.toSql(syncState),
      );
    }
    {
      map['source'] = Variable<String>(
        $HealthSamplesTable.$convertersource.toSql(source),
      );
    }
    {
      map['metric_type'] = Variable<String>(
        $HealthSamplesTable.$convertermetricType.toSql(metricType),
      );
    }
    map['value'] = Variable<double>(value);
    map['unit'] = Variable<String>(unit);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['note'] = Variable<String>(note);
    return map;
  }

  HealthSamplesCompanion toCompanion(bool nullToAbsent) {
    return HealthSamplesCompanion(
      id: Value(id),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localRev: Value(localRev),
      serverRev: serverRev == null && nullToAbsent
          ? const Value.absent()
          : Value(serverRev),
      syncState: Value(syncState),
      source: Value(source),
      metricType: Value(metricType),
      value: Value(value),
      unit: Value(unit),
      recordedAt: Value(recordedAt),
      note: Value(note),
    );
  }

  factory HealthSample.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HealthSample(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      localRev: serializer.fromJson<int>(json['localRev']),
      serverRev: serializer.fromJson<int?>(json['serverRev']),
      syncState: $HealthSamplesTable.$convertersyncState.fromJson(
        serializer.fromJson<String>(json['syncState']),
      ),
      source: $HealthSamplesTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      metricType: $HealthSamplesTable.$convertermetricType.fromJson(
        serializer.fromJson<String>(json['metricType']),
      ),
      value: serializer.fromJson<double>(json['value']),
      unit: serializer.fromJson<String>(json['unit']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'deviceId': serializer.toJson<String?>(deviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'localRev': serializer.toJson<int>(localRev),
      'serverRev': serializer.toJson<int?>(serverRev),
      'syncState': serializer.toJson<String>(
        $HealthSamplesTable.$convertersyncState.toJson(syncState),
      ),
      'source': serializer.toJson<String>(
        $HealthSamplesTable.$convertersource.toJson(source),
      ),
      'metricType': serializer.toJson<String>(
        $HealthSamplesTable.$convertermetricType.toJson(metricType),
      ),
      'value': serializer.toJson<double>(value),
      'unit': serializer.toJson<String>(unit),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'note': serializer.toJson<String>(note),
    };
  }

  HealthSample copyWith({
    String? id,
    Value<String?> userId = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? localRev,
    Value<int?> serverRev = const Value.absent(),
    SyncState? syncState,
    RecordSource? source,
    HealthMetricType? metricType,
    double? value,
    String? unit,
    DateTime? recordedAt,
    String? note,
  }) => HealthSample(
    id: id ?? this.id,
    userId: userId.present ? userId.value : this.userId,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localRev: localRev ?? this.localRev,
    serverRev: serverRev.present ? serverRev.value : this.serverRev,
    syncState: syncState ?? this.syncState,
    source: source ?? this.source,
    metricType: metricType ?? this.metricType,
    value: value ?? this.value,
    unit: unit ?? this.unit,
    recordedAt: recordedAt ?? this.recordedAt,
    note: note ?? this.note,
  );
  HealthSample copyWithCompanion(HealthSamplesCompanion data) {
    return HealthSample(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localRev: data.localRev.present ? data.localRev.value : this.localRev,
      serverRev: data.serverRev.present ? data.serverRev.value : this.serverRev,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      source: data.source.present ? data.source.value : this.source,
      metricType: data.metricType.present
          ? data.metricType.value
          : this.metricType,
      value: data.value.present ? data.value.value : this.value,
      unit: data.unit.present ? data.unit.value : this.unit,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HealthSample(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
          ..write('serverRev: $serverRev, ')
          ..write('syncState: $syncState, ')
          ..write('source: $source, ')
          ..write('metricType: $metricType, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    deviceId,
    createdAt,
    updatedAt,
    deletedAt,
    localRev,
    serverRev,
    syncState,
    source,
    metricType,
    value,
    unit,
    recordedAt,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HealthSample &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localRev == this.localRev &&
          other.serverRev == this.serverRev &&
          other.syncState == this.syncState &&
          other.source == this.source &&
          other.metricType == this.metricType &&
          other.value == this.value &&
          other.unit == this.unit &&
          other.recordedAt == this.recordedAt &&
          other.note == this.note);
}

class HealthSamplesCompanion extends UpdateCompanion<HealthSample> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<String?> deviceId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> localRev;
  final Value<int?> serverRev;
  final Value<SyncState> syncState;
  final Value<RecordSource> source;
  final Value<HealthMetricType> metricType;
  final Value<double> value;
  final Value<String> unit;
  final Value<DateTime> recordedAt;
  final Value<String> note;
  final Value<int> rowid;
  const HealthSamplesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.serverRev = const Value.absent(),
    this.syncState = const Value.absent(),
    this.source = const Value.absent(),
    this.metricType = const Value.absent(),
    this.value = const Value.absent(),
    this.unit = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HealthSamplesCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.serverRev = const Value.absent(),
    this.syncState = const Value.absent(),
    required RecordSource source,
    required HealthMetricType metricType,
    required double value,
    this.unit = const Value.absent(),
    required DateTime recordedAt,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : source = Value(source),
       metricType = Value(metricType),
       value = Value(value),
       recordedAt = Value(recordedAt);
  static Insertable<HealthSample> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? deviceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? localRev,
    Expression<int>? serverRev,
    Expression<String>? syncState,
    Expression<String>? source,
    Expression<String>? metricType,
    Expression<double>? value,
    Expression<String>? unit,
    Expression<DateTime>? recordedAt,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localRev != null) 'local_rev': localRev,
      if (serverRev != null) 'server_rev': serverRev,
      if (syncState != null) 'sync_state': syncState,
      if (source != null) 'source': source,
      if (metricType != null) 'metric_type': metricType,
      if (value != null) 'value': value,
      if (unit != null) 'unit': unit,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HealthSamplesCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<String?>? deviceId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? localRev,
    Value<int?>? serverRev,
    Value<SyncState>? syncState,
    Value<RecordSource>? source,
    Value<HealthMetricType>? metricType,
    Value<double>? value,
    Value<String>? unit,
    Value<DateTime>? recordedAt,
    Value<String>? note,
    Value<int>? rowid,
  }) {
    return HealthSamplesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localRev: localRev ?? this.localRev,
      serverRev: serverRev ?? this.serverRev,
      syncState: syncState ?? this.syncState,
      source: source ?? this.source,
      metricType: metricType ?? this.metricType,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      recordedAt: recordedAt ?? this.recordedAt,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (localRev.present) {
      map['local_rev'] = Variable<int>(localRev.value);
    }
    if (serverRev.present) {
      map['server_rev'] = Variable<int>(serverRev.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(
        $HealthSamplesTable.$convertersyncState.toSql(syncState.value),
      );
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $HealthSamplesTable.$convertersource.toSql(source.value),
      );
    }
    if (metricType.present) {
      map['metric_type'] = Variable<String>(
        $HealthSamplesTable.$convertermetricType.toSql(metricType.value),
      );
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HealthSamplesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
          ..write('serverRev: $serverRev, ')
          ..write('syncState: $syncState, ')
          ..write('source: $source, ')
          ..write('metricType: $metricType, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivitySamplesTable extends ActivitySamples
    with TableInfo<$ActivitySamplesTable, ActivitySample> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivitySamplesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localRevMeta = const VerificationMeta(
    'localRev',
  );
  @override
  late final GeneratedColumn<int> localRev = GeneratedColumn<int>(
    'local_rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _serverRevMeta = const VerificationMeta(
    'serverRev',
  );
  @override
  late final GeneratedColumn<int> serverRev = GeneratedColumn<int>(
    'server_rev',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncState, String> syncState =
      GeneratedColumn<String>(
        'sync_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('localOnly'),
      ).withConverter<SyncState>($ActivitySamplesTable.$convertersyncState);
  @override
  late final GeneratedColumnWithTypeConverter<RecordSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RecordSource>($ActivitySamplesTable.$convertersource);
  @override
  late final GeneratedColumnWithTypeConverter<ActivityType, String>
  activityType = GeneratedColumn<String>(
    'activity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ActivityType>($ActivitySamplesTable.$converteractivityType);
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<double> distanceMeters = GeneratedColumn<double>(
    'distance_meters',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<int> steps = GeneratedColumn<int>(
    'steps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    deviceId,
    createdAt,
    updatedAt,
    deletedAt,
    localRev,
    serverRev,
    syncState,
    source,
    activityType,
    startedAt,
    endedAt,
    confidence,
    distanceMeters,
    steps,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_samples';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivitySample> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('local_rev')) {
      context.handle(
        _localRevMeta,
        localRev.isAcceptableOrUnknown(data['local_rev']!, _localRevMeta),
      );
    }
    if (data.containsKey('server_rev')) {
      context.handle(
        _serverRevMeta,
        serverRev.isAcceptableOrUnknown(data['server_rev']!, _serverRevMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    }
    if (data.containsKey('steps')) {
      context.handle(
        _stepsMeta,
        steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivitySample map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivitySample(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      localRev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_rev'],
      )!,
      serverRev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_rev'],
      ),
      syncState: $ActivitySamplesTable.$convertersyncState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_state'],
        )!,
      ),
      source: $ActivitySamplesTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      activityType: $ActivitySamplesTable.$converteractivityType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}activity_type'],
        )!,
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_meters'],
      ),
      steps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}steps'],
      ),
    );
  }

  @override
  $ActivitySamplesTable createAlias(String alias) {
    return $ActivitySamplesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncState, String, String> $convertersyncState =
      const EnumNameConverter<SyncState>(SyncState.values);
  static JsonTypeConverter2<RecordSource, String, String> $convertersource =
      const EnumNameConverter<RecordSource>(RecordSource.values);
  static JsonTypeConverter2<ActivityType, String, String>
  $converteractivityType = const EnumNameConverter<ActivityType>(
    ActivityType.values,
  );
}

class ActivitySample extends DataClass implements Insertable<ActivitySample> {
  final String id;
  final String? userId;
  final String? deviceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int localRev;
  final int? serverRev;
  final SyncState syncState;
  final RecordSource source;
  final ActivityType activityType;
  final DateTime startedAt;
  final DateTime? endedAt;
  final double? confidence;
  final double? distanceMeters;
  final int? steps;
  const ActivitySample({
    required this.id,
    this.userId,
    this.deviceId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.localRev,
    this.serverRev,
    required this.syncState,
    required this.source,
    required this.activityType,
    required this.startedAt,
    this.endedAt,
    this.confidence,
    this.distanceMeters,
    this.steps,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['local_rev'] = Variable<int>(localRev);
    if (!nullToAbsent || serverRev != null) {
      map['server_rev'] = Variable<int>(serverRev);
    }
    {
      map['sync_state'] = Variable<String>(
        $ActivitySamplesTable.$convertersyncState.toSql(syncState),
      );
    }
    {
      map['source'] = Variable<String>(
        $ActivitySamplesTable.$convertersource.toSql(source),
      );
    }
    {
      map['activity_type'] = Variable<String>(
        $ActivitySamplesTable.$converteractivityType.toSql(activityType),
      );
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    if (!nullToAbsent || distanceMeters != null) {
      map['distance_meters'] = Variable<double>(distanceMeters);
    }
    if (!nullToAbsent || steps != null) {
      map['steps'] = Variable<int>(steps);
    }
    return map;
  }

  ActivitySamplesCompanion toCompanion(bool nullToAbsent) {
    return ActivitySamplesCompanion(
      id: Value(id),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localRev: Value(localRev),
      serverRev: serverRev == null && nullToAbsent
          ? const Value.absent()
          : Value(serverRev),
      syncState: Value(syncState),
      source: Value(source),
      activityType: Value(activityType),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      distanceMeters: distanceMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceMeters),
      steps: steps == null && nullToAbsent
          ? const Value.absent()
          : Value(steps),
    );
  }

  factory ActivitySample.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivitySample(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      localRev: serializer.fromJson<int>(json['localRev']),
      serverRev: serializer.fromJson<int?>(json['serverRev']),
      syncState: $ActivitySamplesTable.$convertersyncState.fromJson(
        serializer.fromJson<String>(json['syncState']),
      ),
      source: $ActivitySamplesTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      activityType: $ActivitySamplesTable.$converteractivityType.fromJson(
        serializer.fromJson<String>(json['activityType']),
      ),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      distanceMeters: serializer.fromJson<double?>(json['distanceMeters']),
      steps: serializer.fromJson<int?>(json['steps']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'deviceId': serializer.toJson<String?>(deviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'localRev': serializer.toJson<int>(localRev),
      'serverRev': serializer.toJson<int?>(serverRev),
      'syncState': serializer.toJson<String>(
        $ActivitySamplesTable.$convertersyncState.toJson(syncState),
      ),
      'source': serializer.toJson<String>(
        $ActivitySamplesTable.$convertersource.toJson(source),
      ),
      'activityType': serializer.toJson<String>(
        $ActivitySamplesTable.$converteractivityType.toJson(activityType),
      ),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'confidence': serializer.toJson<double?>(confidence),
      'distanceMeters': serializer.toJson<double?>(distanceMeters),
      'steps': serializer.toJson<int?>(steps),
    };
  }

  ActivitySample copyWith({
    String? id,
    Value<String?> userId = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? localRev,
    Value<int?> serverRev = const Value.absent(),
    SyncState? syncState,
    RecordSource? source,
    ActivityType? activityType,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    Value<double?> confidence = const Value.absent(),
    Value<double?> distanceMeters = const Value.absent(),
    Value<int?> steps = const Value.absent(),
  }) => ActivitySample(
    id: id ?? this.id,
    userId: userId.present ? userId.value : this.userId,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localRev: localRev ?? this.localRev,
    serverRev: serverRev.present ? serverRev.value : this.serverRev,
    syncState: syncState ?? this.syncState,
    source: source ?? this.source,
    activityType: activityType ?? this.activityType,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    confidence: confidence.present ? confidence.value : this.confidence,
    distanceMeters: distanceMeters.present
        ? distanceMeters.value
        : this.distanceMeters,
    steps: steps.present ? steps.value : this.steps,
  );
  ActivitySample copyWithCompanion(ActivitySamplesCompanion data) {
    return ActivitySample(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localRev: data.localRev.present ? data.localRev.value : this.localRev,
      serverRev: data.serverRev.present ? data.serverRev.value : this.serverRev,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      source: data.source.present ? data.source.value : this.source,
      activityType: data.activityType.present
          ? data.activityType.value
          : this.activityType,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      steps: data.steps.present ? data.steps.value : this.steps,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivitySample(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
          ..write('serverRev: $serverRev, ')
          ..write('syncState: $syncState, ')
          ..write('source: $source, ')
          ..write('activityType: $activityType, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('confidence: $confidence, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('steps: $steps')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    deviceId,
    createdAt,
    updatedAt,
    deletedAt,
    localRev,
    serverRev,
    syncState,
    source,
    activityType,
    startedAt,
    endedAt,
    confidence,
    distanceMeters,
    steps,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivitySample &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localRev == this.localRev &&
          other.serverRev == this.serverRev &&
          other.syncState == this.syncState &&
          other.source == this.source &&
          other.activityType == this.activityType &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.confidence == this.confidence &&
          other.distanceMeters == this.distanceMeters &&
          other.steps == this.steps);
}

class ActivitySamplesCompanion extends UpdateCompanion<ActivitySample> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<String?> deviceId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> localRev;
  final Value<int?> serverRev;
  final Value<SyncState> syncState;
  final Value<RecordSource> source;
  final Value<ActivityType> activityType;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<double?> confidence;
  final Value<double?> distanceMeters;
  final Value<int?> steps;
  final Value<int> rowid;
  const ActivitySamplesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.serverRev = const Value.absent(),
    this.syncState = const Value.absent(),
    this.source = const Value.absent(),
    this.activityType = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.confidence = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.steps = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivitySamplesCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.serverRev = const Value.absent(),
    this.syncState = const Value.absent(),
    required RecordSource source,
    required ActivityType activityType,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.confidence = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.steps = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : source = Value(source),
       activityType = Value(activityType),
       startedAt = Value(startedAt);
  static Insertable<ActivitySample> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? deviceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? localRev,
    Expression<int>? serverRev,
    Expression<String>? syncState,
    Expression<String>? source,
    Expression<String>? activityType,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<double>? confidence,
    Expression<double>? distanceMeters,
    Expression<int>? steps,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localRev != null) 'local_rev': localRev,
      if (serverRev != null) 'server_rev': serverRev,
      if (syncState != null) 'sync_state': syncState,
      if (source != null) 'source': source,
      if (activityType != null) 'activity_type': activityType,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (confidence != null) 'confidence': confidence,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (steps != null) 'steps': steps,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivitySamplesCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<String?>? deviceId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? localRev,
    Value<int?>? serverRev,
    Value<SyncState>? syncState,
    Value<RecordSource>? source,
    Value<ActivityType>? activityType,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<double?>? confidence,
    Value<double?>? distanceMeters,
    Value<int?>? steps,
    Value<int>? rowid,
  }) {
    return ActivitySamplesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localRev: localRev ?? this.localRev,
      serverRev: serverRev ?? this.serverRev,
      syncState: syncState ?? this.syncState,
      source: source ?? this.source,
      activityType: activityType ?? this.activityType,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      confidence: confidence ?? this.confidence,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      steps: steps ?? this.steps,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (localRev.present) {
      map['local_rev'] = Variable<int>(localRev.value);
    }
    if (serverRev.present) {
      map['server_rev'] = Variable<int>(serverRev.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(
        $ActivitySamplesTable.$convertersyncState.toSql(syncState.value),
      );
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $ActivitySamplesTable.$convertersource.toSql(source.value),
      );
    }
    if (activityType.present) {
      map['activity_type'] = Variable<String>(
        $ActivitySamplesTable.$converteractivityType.toSql(activityType.value),
      );
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<double>(distanceMeters.value);
    }
    if (steps.present) {
      map['steps'] = Variable<int>(steps.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivitySamplesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
          ..write('serverRev: $serverRev, ')
          ..write('syncState: $syncState, ')
          ..write('source: $source, ')
          ..write('activityType: $activityType, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('confidence: $confidence, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('steps: $steps, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, Goal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localRevMeta = const VerificationMeta(
    'localRev',
  );
  @override
  late final GeneratedColumn<int> localRev = GeneratedColumn<int>(
    'local_rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _serverRevMeta = const VerificationMeta(
    'serverRev',
  );
  @override
  late final GeneratedColumn<int> serverRev = GeneratedColumn<int>(
    'server_rev',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncState, String> syncState =
      GeneratedColumn<String>(
        'sync_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('localOnly'),
      ).withConverter<SyncState>($GoalsTable.$convertersyncState);
  @override
  late final GeneratedColumnWithTypeConverter<RecordSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RecordSource>($GoalsTable.$convertersource);
  @override
  late final GeneratedColumnWithTypeConverter<HealthMetricType, String>
  metricType = GeneratedColumn<String>(
    'metric_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<HealthMetricType>($GoalsTable.$convertermetricType);
  static const VerificationMeta _targetValueMeta = const VerificationMeta(
    'targetValue',
  );
  @override
  late final GeneratedColumn<double> targetValue = GeneratedColumn<double>(
    'target_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<GoalPeriod, String> period =
      GeneratedColumn<String>(
        'period',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('daily'),
      ).withConverter<GoalPeriod>($GoalsTable.$converterperiod);
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    deviceId,
    createdAt,
    updatedAt,
    deletedAt,
    localRev,
    serverRev,
    syncState,
    source,
    metricType,
    targetValue,
    period,
    startDate,
    endDate,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Goal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('local_rev')) {
      context.handle(
        _localRevMeta,
        localRev.isAcceptableOrUnknown(data['local_rev']!, _localRevMeta),
      );
    }
    if (data.containsKey('server_rev')) {
      context.handle(
        _serverRevMeta,
        serverRev.isAcceptableOrUnknown(data['server_rev']!, _serverRevMeta),
      );
    }
    if (data.containsKey('target_value')) {
      context.handle(
        _targetValueMeta,
        targetValue.isAcceptableOrUnknown(
          data['target_value']!,
          _targetValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetValueMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Goal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Goal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      localRev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_rev'],
      )!,
      serverRev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_rev'],
      ),
      syncState: $GoalsTable.$convertersyncState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_state'],
        )!,
      ),
      source: $GoalsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      metricType: $GoalsTable.$convertermetricType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}metric_type'],
        )!,
      ),
      targetValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_value'],
      )!,
      period: $GoalsTable.$converterperiod.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}period'],
        )!,
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncState, String, String> $convertersyncState =
      const EnumNameConverter<SyncState>(SyncState.values);
  static JsonTypeConverter2<RecordSource, String, String> $convertersource =
      const EnumNameConverter<RecordSource>(RecordSource.values);
  static JsonTypeConverter2<HealthMetricType, String, String>
  $convertermetricType = const EnumNameConverter<HealthMetricType>(
    HealthMetricType.values,
  );
  static JsonTypeConverter2<GoalPeriod, String, String> $converterperiod =
      const EnumNameConverter<GoalPeriod>(GoalPeriod.values);
}

class Goal extends DataClass implements Insertable<Goal> {
  final String id;
  final String? userId;
  final String? deviceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int localRev;
  final int? serverRev;
  final SyncState syncState;
  final RecordSource source;
  final HealthMetricType metricType;
  final double targetValue;
  final GoalPeriod period;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  const Goal({
    required this.id,
    this.userId,
    this.deviceId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.localRev,
    this.serverRev,
    required this.syncState,
    required this.source,
    required this.metricType,
    required this.targetValue,
    required this.period,
    required this.startDate,
    this.endDate,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['local_rev'] = Variable<int>(localRev);
    if (!nullToAbsent || serverRev != null) {
      map['server_rev'] = Variable<int>(serverRev);
    }
    {
      map['sync_state'] = Variable<String>(
        $GoalsTable.$convertersyncState.toSql(syncState),
      );
    }
    {
      map['source'] = Variable<String>(
        $GoalsTable.$convertersource.toSql(source),
      );
    }
    {
      map['metric_type'] = Variable<String>(
        $GoalsTable.$convertermetricType.toSql(metricType),
      );
    }
    map['target_value'] = Variable<double>(targetValue);
    {
      map['period'] = Variable<String>(
        $GoalsTable.$converterperiod.toSql(period),
      );
    }
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localRev: Value(localRev),
      serverRev: serverRev == null && nullToAbsent
          ? const Value.absent()
          : Value(serverRev),
      syncState: Value(syncState),
      source: Value(source),
      metricType: Value(metricType),
      targetValue: Value(targetValue),
      period: Value(period),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      isActive: Value(isActive),
    );
  }

  factory Goal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Goal(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      localRev: serializer.fromJson<int>(json['localRev']),
      serverRev: serializer.fromJson<int?>(json['serverRev']),
      syncState: $GoalsTable.$convertersyncState.fromJson(
        serializer.fromJson<String>(json['syncState']),
      ),
      source: $GoalsTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      metricType: $GoalsTable.$convertermetricType.fromJson(
        serializer.fromJson<String>(json['metricType']),
      ),
      targetValue: serializer.fromJson<double>(json['targetValue']),
      period: $GoalsTable.$converterperiod.fromJson(
        serializer.fromJson<String>(json['period']),
      ),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'deviceId': serializer.toJson<String?>(deviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'localRev': serializer.toJson<int>(localRev),
      'serverRev': serializer.toJson<int?>(serverRev),
      'syncState': serializer.toJson<String>(
        $GoalsTable.$convertersyncState.toJson(syncState),
      ),
      'source': serializer.toJson<String>(
        $GoalsTable.$convertersource.toJson(source),
      ),
      'metricType': serializer.toJson<String>(
        $GoalsTable.$convertermetricType.toJson(metricType),
      ),
      'targetValue': serializer.toJson<double>(targetValue),
      'period': serializer.toJson<String>(
        $GoalsTable.$converterperiod.toJson(period),
      ),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  Goal copyWith({
    String? id,
    Value<String?> userId = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? localRev,
    Value<int?> serverRev = const Value.absent(),
    SyncState? syncState,
    RecordSource? source,
    HealthMetricType? metricType,
    double? targetValue,
    GoalPeriod? period,
    DateTime? startDate,
    Value<DateTime?> endDate = const Value.absent(),
    bool? isActive,
  }) => Goal(
    id: id ?? this.id,
    userId: userId.present ? userId.value : this.userId,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localRev: localRev ?? this.localRev,
    serverRev: serverRev.present ? serverRev.value : this.serverRev,
    syncState: syncState ?? this.syncState,
    source: source ?? this.source,
    metricType: metricType ?? this.metricType,
    targetValue: targetValue ?? this.targetValue,
    period: period ?? this.period,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    isActive: isActive ?? this.isActive,
  );
  Goal copyWithCompanion(GoalsCompanion data) {
    return Goal(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localRev: data.localRev.present ? data.localRev.value : this.localRev,
      serverRev: data.serverRev.present ? data.serverRev.value : this.serverRev,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      source: data.source.present ? data.source.value : this.source,
      metricType: data.metricType.present
          ? data.metricType.value
          : this.metricType,
      targetValue: data.targetValue.present
          ? data.targetValue.value
          : this.targetValue,
      period: data.period.present ? data.period.value : this.period,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Goal(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
          ..write('serverRev: $serverRev, ')
          ..write('syncState: $syncState, ')
          ..write('source: $source, ')
          ..write('metricType: $metricType, ')
          ..write('targetValue: $targetValue, ')
          ..write('period: $period, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    deviceId,
    createdAt,
    updatedAt,
    deletedAt,
    localRev,
    serverRev,
    syncState,
    source,
    metricType,
    targetValue,
    period,
    startDate,
    endDate,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Goal &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localRev == this.localRev &&
          other.serverRev == this.serverRev &&
          other.syncState == this.syncState &&
          other.source == this.source &&
          other.metricType == this.metricType &&
          other.targetValue == this.targetValue &&
          other.period == this.period &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.isActive == this.isActive);
}

class GoalsCompanion extends UpdateCompanion<Goal> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<String?> deviceId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> localRev;
  final Value<int?> serverRev;
  final Value<SyncState> syncState;
  final Value<RecordSource> source;
  final Value<HealthMetricType> metricType;
  final Value<double> targetValue;
  final Value<GoalPeriod> period;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<bool> isActive;
  final Value<int> rowid;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.serverRev = const Value.absent(),
    this.syncState = const Value.absent(),
    this.source = const Value.absent(),
    this.metricType = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.period = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalsCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.serverRev = const Value.absent(),
    this.syncState = const Value.absent(),
    required RecordSource source,
    required HealthMetricType metricType,
    required double targetValue,
    this.period = const Value.absent(),
    required DateTime startDate,
    this.endDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : source = Value(source),
       metricType = Value(metricType),
       targetValue = Value(targetValue),
       startDate = Value(startDate);
  static Insertable<Goal> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? deviceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? localRev,
    Expression<int>? serverRev,
    Expression<String>? syncState,
    Expression<String>? source,
    Expression<String>? metricType,
    Expression<double>? targetValue,
    Expression<String>? period,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localRev != null) 'local_rev': localRev,
      if (serverRev != null) 'server_rev': serverRev,
      if (syncState != null) 'sync_state': syncState,
      if (source != null) 'source': source,
      if (metricType != null) 'metric_type': metricType,
      if (targetValue != null) 'target_value': targetValue,
      if (period != null) 'period': period,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalsCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<String?>? deviceId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? localRev,
    Value<int?>? serverRev,
    Value<SyncState>? syncState,
    Value<RecordSource>? source,
    Value<HealthMetricType>? metricType,
    Value<double>? targetValue,
    Value<GoalPeriod>? period,
    Value<DateTime>? startDate,
    Value<DateTime?>? endDate,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return GoalsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localRev: localRev ?? this.localRev,
      serverRev: serverRev ?? this.serverRev,
      syncState: syncState ?? this.syncState,
      source: source ?? this.source,
      metricType: metricType ?? this.metricType,
      targetValue: targetValue ?? this.targetValue,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (localRev.present) {
      map['local_rev'] = Variable<int>(localRev.value);
    }
    if (serverRev.present) {
      map['server_rev'] = Variable<int>(serverRev.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(
        $GoalsTable.$convertersyncState.toSql(syncState.value),
      );
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $GoalsTable.$convertersource.toSql(source.value),
      );
    }
    if (metricType.present) {
      map['metric_type'] = Variable<String>(
        $GoalsTable.$convertermetricType.toSql(metricType.value),
      );
    }
    if (targetValue.present) {
      map['target_value'] = Variable<double>(targetValue.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(
        $GoalsTable.$converterperiod.toSql(period.value),
      );
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
          ..write('serverRev: $serverRev, ')
          ..write('syncState: $syncState, ')
          ..write('source: $source, ')
          ..write('metricType: $metricType, ')
          ..write('targetValue: $targetValue, ')
          ..write('period: $period, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlacesTable extends Places with TableInfo<$PlacesTable, Place> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localRevMeta = const VerificationMeta(
    'localRev',
  );
  @override
  late final GeneratedColumn<int> localRev = GeneratedColumn<int>(
    'local_rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _serverRevMeta = const VerificationMeta(
    'serverRev',
  );
  @override
  late final GeneratedColumn<int> serverRev = GeneratedColumn<int>(
    'server_rev',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncState, String> syncState =
      GeneratedColumn<String>(
        'sync_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('localOnly'),
      ).withConverter<SyncState>($PlacesTable.$convertersyncState);
  @override
  late final GeneratedColumnWithTypeConverter<RecordSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RecordSource>($PlacesTable.$convertersource);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PlaceCategory, String> category =
      GeneratedColumn<String>(
        'category',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('custom'),
      ).withConverter<PlaceCategory>($PlacesTable.$convertercategory);
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _radiusMetersMeta = const VerificationMeta(
    'radiusMeters',
  );
  @override
  late final GeneratedColumn<double> radiusMeters = GeneratedColumn<double>(
    'radius_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _currentlyInsideMeta = const VerificationMeta(
    'currentlyInside',
  );
  @override
  late final GeneratedColumn<bool> currentlyInside = GeneratedColumn<bool>(
    'currently_inside',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("currently_inside" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastEnteredAtMeta = const VerificationMeta(
    'lastEnteredAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastEnteredAt =
      GeneratedColumn<DateTime>(
        'last_entered_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastExitedAtMeta = const VerificationMeta(
    'lastExitedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastExitedAt = GeneratedColumn<DateTime>(
    'last_exited_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateAsOfMeta = const VerificationMeta(
    'stateAsOf',
  );
  @override
  late final GeneratedColumn<DateTime> stateAsOf = GeneratedColumn<DateTime>(
    'state_as_of',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    deviceId,
    createdAt,
    updatedAt,
    deletedAt,
    localRev,
    serverRev,
    syncState,
    source,
    name,
    category,
    latitude,
    longitude,
    radiusMeters,
    address,
    currentlyInside,
    lastEnteredAt,
    lastExitedAt,
    stateAsOf,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'places';
  @override
  VerificationContext validateIntegrity(
    Insertable<Place> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('local_rev')) {
      context.handle(
        _localRevMeta,
        localRev.isAcceptableOrUnknown(data['local_rev']!, _localRevMeta),
      );
    }
    if (data.containsKey('server_rev')) {
      context.handle(
        _serverRevMeta,
        serverRev.isAcceptableOrUnknown(data['server_rev']!, _serverRevMeta),
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
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('radius_meters')) {
      context.handle(
        _radiusMetersMeta,
        radiusMeters.isAcceptableOrUnknown(
          data['radius_meters']!,
          _radiusMetersMeta,
        ),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('currently_inside')) {
      context.handle(
        _currentlyInsideMeta,
        currentlyInside.isAcceptableOrUnknown(
          data['currently_inside']!,
          _currentlyInsideMeta,
        ),
      );
    }
    if (data.containsKey('last_entered_at')) {
      context.handle(
        _lastEnteredAtMeta,
        lastEnteredAt.isAcceptableOrUnknown(
          data['last_entered_at']!,
          _lastEnteredAtMeta,
        ),
      );
    }
    if (data.containsKey('last_exited_at')) {
      context.handle(
        _lastExitedAtMeta,
        lastExitedAt.isAcceptableOrUnknown(
          data['last_exited_at']!,
          _lastExitedAtMeta,
        ),
      );
    }
    if (data.containsKey('state_as_of')) {
      context.handle(
        _stateAsOfMeta,
        stateAsOf.isAcceptableOrUnknown(data['state_as_of']!, _stateAsOfMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Place map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Place(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      localRev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_rev'],
      )!,
      serverRev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_rev'],
      ),
      syncState: $PlacesTable.$convertersyncState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_state'],
        )!,
      ),
      source: $PlacesTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: $PlacesTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      radiusMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}radius_meters'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      currentlyInside: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}currently_inside'],
      )!,
      lastEnteredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_entered_at'],
      ),
      lastExitedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_exited_at'],
      ),
      stateAsOf: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}state_as_of'],
      ),
    );
  }

  @override
  $PlacesTable createAlias(String alias) {
    return $PlacesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncState, String, String> $convertersyncState =
      const EnumNameConverter<SyncState>(SyncState.values);
  static JsonTypeConverter2<RecordSource, String, String> $convertersource =
      const EnumNameConverter<RecordSource>(RecordSource.values);
  static JsonTypeConverter2<PlaceCategory, String, String> $convertercategory =
      const EnumNameConverter<PlaceCategory>(PlaceCategory.values);
}

class Place extends DataClass implements Insertable<Place> {
  final String id;
  final String? userId;
  final String? deviceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int localRev;
  final int? serverRev;
  final SyncState syncState;
  final RecordSource source;
  final String name;
  final PlaceCategory category;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final String address;
  final bool currentlyInside;
  final DateTime? lastEnteredAt;
  final DateTime? lastExitedAt;
  final DateTime? stateAsOf;
  const Place({
    required this.id,
    this.userId,
    this.deviceId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.localRev,
    this.serverRev,
    required this.syncState,
    required this.source,
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.address,
    required this.currentlyInside,
    this.lastEnteredAt,
    this.lastExitedAt,
    this.stateAsOf,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['local_rev'] = Variable<int>(localRev);
    if (!nullToAbsent || serverRev != null) {
      map['server_rev'] = Variable<int>(serverRev);
    }
    {
      map['sync_state'] = Variable<String>(
        $PlacesTable.$convertersyncState.toSql(syncState),
      );
    }
    {
      map['source'] = Variable<String>(
        $PlacesTable.$convertersource.toSql(source),
      );
    }
    map['name'] = Variable<String>(name);
    {
      map['category'] = Variable<String>(
        $PlacesTable.$convertercategory.toSql(category),
      );
    }
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['radius_meters'] = Variable<double>(radiusMeters);
    map['address'] = Variable<String>(address);
    map['currently_inside'] = Variable<bool>(currentlyInside);
    if (!nullToAbsent || lastEnteredAt != null) {
      map['last_entered_at'] = Variable<DateTime>(lastEnteredAt);
    }
    if (!nullToAbsent || lastExitedAt != null) {
      map['last_exited_at'] = Variable<DateTime>(lastExitedAt);
    }
    if (!nullToAbsent || stateAsOf != null) {
      map['state_as_of'] = Variable<DateTime>(stateAsOf);
    }
    return map;
  }

  PlacesCompanion toCompanion(bool nullToAbsent) {
    return PlacesCompanion(
      id: Value(id),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localRev: Value(localRev),
      serverRev: serverRev == null && nullToAbsent
          ? const Value.absent()
          : Value(serverRev),
      syncState: Value(syncState),
      source: Value(source),
      name: Value(name),
      category: Value(category),
      latitude: Value(latitude),
      longitude: Value(longitude),
      radiusMeters: Value(radiusMeters),
      address: Value(address),
      currentlyInside: Value(currentlyInside),
      lastEnteredAt: lastEnteredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastEnteredAt),
      lastExitedAt: lastExitedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastExitedAt),
      stateAsOf: stateAsOf == null && nullToAbsent
          ? const Value.absent()
          : Value(stateAsOf),
    );
  }

  factory Place.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Place(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      localRev: serializer.fromJson<int>(json['localRev']),
      serverRev: serializer.fromJson<int?>(json['serverRev']),
      syncState: $PlacesTable.$convertersyncState.fromJson(
        serializer.fromJson<String>(json['syncState']),
      ),
      source: $PlacesTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      name: serializer.fromJson<String>(json['name']),
      category: $PlacesTable.$convertercategory.fromJson(
        serializer.fromJson<String>(json['category']),
      ),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      radiusMeters: serializer.fromJson<double>(json['radiusMeters']),
      address: serializer.fromJson<String>(json['address']),
      currentlyInside: serializer.fromJson<bool>(json['currentlyInside']),
      lastEnteredAt: serializer.fromJson<DateTime?>(json['lastEnteredAt']),
      lastExitedAt: serializer.fromJson<DateTime?>(json['lastExitedAt']),
      stateAsOf: serializer.fromJson<DateTime?>(json['stateAsOf']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'deviceId': serializer.toJson<String?>(deviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'localRev': serializer.toJson<int>(localRev),
      'serverRev': serializer.toJson<int?>(serverRev),
      'syncState': serializer.toJson<String>(
        $PlacesTable.$convertersyncState.toJson(syncState),
      ),
      'source': serializer.toJson<String>(
        $PlacesTable.$convertersource.toJson(source),
      ),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(
        $PlacesTable.$convertercategory.toJson(category),
      ),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'radiusMeters': serializer.toJson<double>(radiusMeters),
      'address': serializer.toJson<String>(address),
      'currentlyInside': serializer.toJson<bool>(currentlyInside),
      'lastEnteredAt': serializer.toJson<DateTime?>(lastEnteredAt),
      'lastExitedAt': serializer.toJson<DateTime?>(lastExitedAt),
      'stateAsOf': serializer.toJson<DateTime?>(stateAsOf),
    };
  }

  Place copyWith({
    String? id,
    Value<String?> userId = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? localRev,
    Value<int?> serverRev = const Value.absent(),
    SyncState? syncState,
    RecordSource? source,
    String? name,
    PlaceCategory? category,
    double? latitude,
    double? longitude,
    double? radiusMeters,
    String? address,
    bool? currentlyInside,
    Value<DateTime?> lastEnteredAt = const Value.absent(),
    Value<DateTime?> lastExitedAt = const Value.absent(),
    Value<DateTime?> stateAsOf = const Value.absent(),
  }) => Place(
    id: id ?? this.id,
    userId: userId.present ? userId.value : this.userId,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localRev: localRev ?? this.localRev,
    serverRev: serverRev.present ? serverRev.value : this.serverRev,
    syncState: syncState ?? this.syncState,
    source: source ?? this.source,
    name: name ?? this.name,
    category: category ?? this.category,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    radiusMeters: radiusMeters ?? this.radiusMeters,
    address: address ?? this.address,
    currentlyInside: currentlyInside ?? this.currentlyInside,
    lastEnteredAt: lastEnteredAt.present
        ? lastEnteredAt.value
        : this.lastEnteredAt,
    lastExitedAt: lastExitedAt.present ? lastExitedAt.value : this.lastExitedAt,
    stateAsOf: stateAsOf.present ? stateAsOf.value : this.stateAsOf,
  );
  Place copyWithCompanion(PlacesCompanion data) {
    return Place(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localRev: data.localRev.present ? data.localRev.value : this.localRev,
      serverRev: data.serverRev.present ? data.serverRev.value : this.serverRev,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      source: data.source.present ? data.source.value : this.source,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      radiusMeters: data.radiusMeters.present
          ? data.radiusMeters.value
          : this.radiusMeters,
      address: data.address.present ? data.address.value : this.address,
      currentlyInside: data.currentlyInside.present
          ? data.currentlyInside.value
          : this.currentlyInside,
      lastEnteredAt: data.lastEnteredAt.present
          ? data.lastEnteredAt.value
          : this.lastEnteredAt,
      lastExitedAt: data.lastExitedAt.present
          ? data.lastExitedAt.value
          : this.lastExitedAt,
      stateAsOf: data.stateAsOf.present ? data.stateAsOf.value : this.stateAsOf,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Place(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
          ..write('serverRev: $serverRev, ')
          ..write('syncState: $syncState, ')
          ..write('source: $source, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('radiusMeters: $radiusMeters, ')
          ..write('address: $address, ')
          ..write('currentlyInside: $currentlyInside, ')
          ..write('lastEnteredAt: $lastEnteredAt, ')
          ..write('lastExitedAt: $lastExitedAt, ')
          ..write('stateAsOf: $stateAsOf')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    deviceId,
    createdAt,
    updatedAt,
    deletedAt,
    localRev,
    serverRev,
    syncState,
    source,
    name,
    category,
    latitude,
    longitude,
    radiusMeters,
    address,
    currentlyInside,
    lastEnteredAt,
    lastExitedAt,
    stateAsOf,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Place &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localRev == this.localRev &&
          other.serverRev == this.serverRev &&
          other.syncState == this.syncState &&
          other.source == this.source &&
          other.name == this.name &&
          other.category == this.category &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.radiusMeters == this.radiusMeters &&
          other.address == this.address &&
          other.currentlyInside == this.currentlyInside &&
          other.lastEnteredAt == this.lastEnteredAt &&
          other.lastExitedAt == this.lastExitedAt &&
          other.stateAsOf == this.stateAsOf);
}

class PlacesCompanion extends UpdateCompanion<Place> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<String?> deviceId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> localRev;
  final Value<int?> serverRev;
  final Value<SyncState> syncState;
  final Value<RecordSource> source;
  final Value<String> name;
  final Value<PlaceCategory> category;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double> radiusMeters;
  final Value<String> address;
  final Value<bool> currentlyInside;
  final Value<DateTime?> lastEnteredAt;
  final Value<DateTime?> lastExitedAt;
  final Value<DateTime?> stateAsOf;
  final Value<int> rowid;
  const PlacesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.serverRev = const Value.absent(),
    this.syncState = const Value.absent(),
    this.source = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.radiusMeters = const Value.absent(),
    this.address = const Value.absent(),
    this.currentlyInside = const Value.absent(),
    this.lastEnteredAt = const Value.absent(),
    this.lastExitedAt = const Value.absent(),
    this.stateAsOf = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlacesCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.serverRev = const Value.absent(),
    this.syncState = const Value.absent(),
    required RecordSource source,
    required String name,
    this.category = const Value.absent(),
    required double latitude,
    required double longitude,
    this.radiusMeters = const Value.absent(),
    this.address = const Value.absent(),
    this.currentlyInside = const Value.absent(),
    this.lastEnteredAt = const Value.absent(),
    this.lastExitedAt = const Value.absent(),
    this.stateAsOf = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : source = Value(source),
       name = Value(name),
       latitude = Value(latitude),
       longitude = Value(longitude);
  static Insertable<Place> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? deviceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? localRev,
    Expression<int>? serverRev,
    Expression<String>? syncState,
    Expression<String>? source,
    Expression<String>? name,
    Expression<String>? category,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? radiusMeters,
    Expression<String>? address,
    Expression<bool>? currentlyInside,
    Expression<DateTime>? lastEnteredAt,
    Expression<DateTime>? lastExitedAt,
    Expression<DateTime>? stateAsOf,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localRev != null) 'local_rev': localRev,
      if (serverRev != null) 'server_rev': serverRev,
      if (syncState != null) 'sync_state': syncState,
      if (source != null) 'source': source,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (radiusMeters != null) 'radius_meters': radiusMeters,
      if (address != null) 'address': address,
      if (currentlyInside != null) 'currently_inside': currentlyInside,
      if (lastEnteredAt != null) 'last_entered_at': lastEnteredAt,
      if (lastExitedAt != null) 'last_exited_at': lastExitedAt,
      if (stateAsOf != null) 'state_as_of': stateAsOf,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlacesCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<String?>? deviceId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? localRev,
    Value<int?>? serverRev,
    Value<SyncState>? syncState,
    Value<RecordSource>? source,
    Value<String>? name,
    Value<PlaceCategory>? category,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double>? radiusMeters,
    Value<String>? address,
    Value<bool>? currentlyInside,
    Value<DateTime?>? lastEnteredAt,
    Value<DateTime?>? lastExitedAt,
    Value<DateTime?>? stateAsOf,
    Value<int>? rowid,
  }) {
    return PlacesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localRev: localRev ?? this.localRev,
      serverRev: serverRev ?? this.serverRev,
      syncState: syncState ?? this.syncState,
      source: source ?? this.source,
      name: name ?? this.name,
      category: category ?? this.category,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      address: address ?? this.address,
      currentlyInside: currentlyInside ?? this.currentlyInside,
      lastEnteredAt: lastEnteredAt ?? this.lastEnteredAt,
      lastExitedAt: lastExitedAt ?? this.lastExitedAt,
      stateAsOf: stateAsOf ?? this.stateAsOf,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (localRev.present) {
      map['local_rev'] = Variable<int>(localRev.value);
    }
    if (serverRev.present) {
      map['server_rev'] = Variable<int>(serverRev.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(
        $PlacesTable.$convertersyncState.toSql(syncState.value),
      );
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $PlacesTable.$convertersource.toSql(source.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(
        $PlacesTable.$convertercategory.toSql(category.value),
      );
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (radiusMeters.present) {
      map['radius_meters'] = Variable<double>(radiusMeters.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (currentlyInside.present) {
      map['currently_inside'] = Variable<bool>(currentlyInside.value);
    }
    if (lastEnteredAt.present) {
      map['last_entered_at'] = Variable<DateTime>(lastEnteredAt.value);
    }
    if (lastExitedAt.present) {
      map['last_exited_at'] = Variable<DateTime>(lastExitedAt.value);
    }
    if (stateAsOf.present) {
      map['state_as_of'] = Variable<DateTime>(stateAsOf.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlacesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
          ..write('serverRev: $serverRev, ')
          ..write('syncState: $syncState, ')
          ..write('source: $source, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('radiusMeters: $radiusMeters, ')
          ..write('address: $address, ')
          ..write('currentlyInside: $currentlyInside, ')
          ..write('lastEnteredAt: $lastEnteredAt, ')
          ..write('lastExitedAt: $lastExitedAt, ')
          ..write('stateAsOf: $stateAsOf, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TripsTable extends Trips with TableInfo<$TripsTable, Trip> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localRevMeta = const VerificationMeta(
    'localRev',
  );
  @override
  late final GeneratedColumn<int> localRev = GeneratedColumn<int>(
    'local_rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _serverRevMeta = const VerificationMeta(
    'serverRev',
  );
  @override
  late final GeneratedColumn<int> serverRev = GeneratedColumn<int>(
    'server_rev',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncState, String> syncState =
      GeneratedColumn<String>(
        'sync_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('localOnly'),
      ).withConverter<SyncState>($TripsTable.$convertersyncState);
  @override
  late final GeneratedColumnWithTypeConverter<RecordSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RecordSource>($TripsTable.$convertersource);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<double> distanceMeters = GeneratedColumn<double>(
    'distance_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pointCountMeta = const VerificationMeta(
    'pointCount',
  );
  @override
  late final GeneratedColumn<int> pointCount = GeneratedColumn<int>(
    'point_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _startPlaceIdMeta = const VerificationMeta(
    'startPlaceId',
  );
  @override
  late final GeneratedColumn<String> startPlaceId = GeneratedColumn<String>(
    'start_place_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endPlaceIdMeta = const VerificationMeta(
    'endPlaceId',
  );
  @override
  late final GeneratedColumn<String> endPlaceId = GeneratedColumn<String>(
    'end_place_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    deviceId,
    createdAt,
    updatedAt,
    deletedAt,
    localRev,
    serverRev,
    syncState,
    source,
    name,
    startedAt,
    endedAt,
    distanceMeters,
    pointCount,
    startPlaceId,
    endPlaceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trips';
  @override
  VerificationContext validateIntegrity(
    Insertable<Trip> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('local_rev')) {
      context.handle(
        _localRevMeta,
        localRev.isAcceptableOrUnknown(data['local_rev']!, _localRevMeta),
      );
    }
    if (data.containsKey('server_rev')) {
      context.handle(
        _serverRevMeta,
        serverRev.isAcceptableOrUnknown(data['server_rev']!, _serverRevMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    }
    if (data.containsKey('point_count')) {
      context.handle(
        _pointCountMeta,
        pointCount.isAcceptableOrUnknown(data['point_count']!, _pointCountMeta),
      );
    }
    if (data.containsKey('start_place_id')) {
      context.handle(
        _startPlaceIdMeta,
        startPlaceId.isAcceptableOrUnknown(
          data['start_place_id']!,
          _startPlaceIdMeta,
        ),
      );
    }
    if (data.containsKey('end_place_id')) {
      context.handle(
        _endPlaceIdMeta,
        endPlaceId.isAcceptableOrUnknown(
          data['end_place_id']!,
          _endPlaceIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Trip map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Trip(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      localRev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_rev'],
      )!,
      serverRev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_rev'],
      ),
      syncState: $TripsTable.$convertersyncState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_state'],
        )!,
      ),
      source: $TripsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_meters'],
      )!,
      pointCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}point_count'],
      )!,
      startPlaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_place_id'],
      ),
      endPlaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_place_id'],
      ),
    );
  }

  @override
  $TripsTable createAlias(String alias) {
    return $TripsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncState, String, String> $convertersyncState =
      const EnumNameConverter<SyncState>(SyncState.values);
  static JsonTypeConverter2<RecordSource, String, String> $convertersource =
      const EnumNameConverter<RecordSource>(RecordSource.values);
}

class Trip extends DataClass implements Insertable<Trip> {
  final String id;
  final String? userId;
  final String? deviceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int localRev;
  final int? serverRev;
  final SyncState syncState;
  final RecordSource source;
  final String name;
  final DateTime startedAt;
  final DateTime? endedAt;
  final double distanceMeters;
  final int pointCount;
  final String? startPlaceId;
  final String? endPlaceId;
  const Trip({
    required this.id,
    this.userId,
    this.deviceId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.localRev,
    this.serverRev,
    required this.syncState,
    required this.source,
    required this.name,
    required this.startedAt,
    this.endedAt,
    required this.distanceMeters,
    required this.pointCount,
    this.startPlaceId,
    this.endPlaceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['local_rev'] = Variable<int>(localRev);
    if (!nullToAbsent || serverRev != null) {
      map['server_rev'] = Variable<int>(serverRev);
    }
    {
      map['sync_state'] = Variable<String>(
        $TripsTable.$convertersyncState.toSql(syncState),
      );
    }
    {
      map['source'] = Variable<String>(
        $TripsTable.$convertersource.toSql(source),
      );
    }
    map['name'] = Variable<String>(name);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['distance_meters'] = Variable<double>(distanceMeters);
    map['point_count'] = Variable<int>(pointCount);
    if (!nullToAbsent || startPlaceId != null) {
      map['start_place_id'] = Variable<String>(startPlaceId);
    }
    if (!nullToAbsent || endPlaceId != null) {
      map['end_place_id'] = Variable<String>(endPlaceId);
    }
    return map;
  }

  TripsCompanion toCompanion(bool nullToAbsent) {
    return TripsCompanion(
      id: Value(id),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localRev: Value(localRev),
      serverRev: serverRev == null && nullToAbsent
          ? const Value.absent()
          : Value(serverRev),
      syncState: Value(syncState),
      source: Value(source),
      name: Value(name),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      distanceMeters: Value(distanceMeters),
      pointCount: Value(pointCount),
      startPlaceId: startPlaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(startPlaceId),
      endPlaceId: endPlaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(endPlaceId),
    );
  }

  factory Trip.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Trip(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      localRev: serializer.fromJson<int>(json['localRev']),
      serverRev: serializer.fromJson<int?>(json['serverRev']),
      syncState: $TripsTable.$convertersyncState.fromJson(
        serializer.fromJson<String>(json['syncState']),
      ),
      source: $TripsTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      name: serializer.fromJson<String>(json['name']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      distanceMeters: serializer.fromJson<double>(json['distanceMeters']),
      pointCount: serializer.fromJson<int>(json['pointCount']),
      startPlaceId: serializer.fromJson<String?>(json['startPlaceId']),
      endPlaceId: serializer.fromJson<String?>(json['endPlaceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'deviceId': serializer.toJson<String?>(deviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'localRev': serializer.toJson<int>(localRev),
      'serverRev': serializer.toJson<int?>(serverRev),
      'syncState': serializer.toJson<String>(
        $TripsTable.$convertersyncState.toJson(syncState),
      ),
      'source': serializer.toJson<String>(
        $TripsTable.$convertersource.toJson(source),
      ),
      'name': serializer.toJson<String>(name),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'distanceMeters': serializer.toJson<double>(distanceMeters),
      'pointCount': serializer.toJson<int>(pointCount),
      'startPlaceId': serializer.toJson<String?>(startPlaceId),
      'endPlaceId': serializer.toJson<String?>(endPlaceId),
    };
  }

  Trip copyWith({
    String? id,
    Value<String?> userId = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? localRev,
    Value<int?> serverRev = const Value.absent(),
    SyncState? syncState,
    RecordSource? source,
    String? name,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    double? distanceMeters,
    int? pointCount,
    Value<String?> startPlaceId = const Value.absent(),
    Value<String?> endPlaceId = const Value.absent(),
  }) => Trip(
    id: id ?? this.id,
    userId: userId.present ? userId.value : this.userId,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localRev: localRev ?? this.localRev,
    serverRev: serverRev.present ? serverRev.value : this.serverRev,
    syncState: syncState ?? this.syncState,
    source: source ?? this.source,
    name: name ?? this.name,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    distanceMeters: distanceMeters ?? this.distanceMeters,
    pointCount: pointCount ?? this.pointCount,
    startPlaceId: startPlaceId.present ? startPlaceId.value : this.startPlaceId,
    endPlaceId: endPlaceId.present ? endPlaceId.value : this.endPlaceId,
  );
  Trip copyWithCompanion(TripsCompanion data) {
    return Trip(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localRev: data.localRev.present ? data.localRev.value : this.localRev,
      serverRev: data.serverRev.present ? data.serverRev.value : this.serverRev,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      source: data.source.present ? data.source.value : this.source,
      name: data.name.present ? data.name.value : this.name,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      pointCount: data.pointCount.present
          ? data.pointCount.value
          : this.pointCount,
      startPlaceId: data.startPlaceId.present
          ? data.startPlaceId.value
          : this.startPlaceId,
      endPlaceId: data.endPlaceId.present
          ? data.endPlaceId.value
          : this.endPlaceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Trip(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
          ..write('serverRev: $serverRev, ')
          ..write('syncState: $syncState, ')
          ..write('source: $source, ')
          ..write('name: $name, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('pointCount: $pointCount, ')
          ..write('startPlaceId: $startPlaceId, ')
          ..write('endPlaceId: $endPlaceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    deviceId,
    createdAt,
    updatedAt,
    deletedAt,
    localRev,
    serverRev,
    syncState,
    source,
    name,
    startedAt,
    endedAt,
    distanceMeters,
    pointCount,
    startPlaceId,
    endPlaceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Trip &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localRev == this.localRev &&
          other.serverRev == this.serverRev &&
          other.syncState == this.syncState &&
          other.source == this.source &&
          other.name == this.name &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.distanceMeters == this.distanceMeters &&
          other.pointCount == this.pointCount &&
          other.startPlaceId == this.startPlaceId &&
          other.endPlaceId == this.endPlaceId);
}

class TripsCompanion extends UpdateCompanion<Trip> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<String?> deviceId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> localRev;
  final Value<int?> serverRev;
  final Value<SyncState> syncState;
  final Value<RecordSource> source;
  final Value<String> name;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<double> distanceMeters;
  final Value<int> pointCount;
  final Value<String?> startPlaceId;
  final Value<String?> endPlaceId;
  final Value<int> rowid;
  const TripsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.serverRev = const Value.absent(),
    this.syncState = const Value.absent(),
    this.source = const Value.absent(),
    this.name = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.pointCount = const Value.absent(),
    this.startPlaceId = const Value.absent(),
    this.endPlaceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripsCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.serverRev = const Value.absent(),
    this.syncState = const Value.absent(),
    required RecordSource source,
    this.name = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.pointCount = const Value.absent(),
    this.startPlaceId = const Value.absent(),
    this.endPlaceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : source = Value(source),
       startedAt = Value(startedAt);
  static Insertable<Trip> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? deviceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? localRev,
    Expression<int>? serverRev,
    Expression<String>? syncState,
    Expression<String>? source,
    Expression<String>? name,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<double>? distanceMeters,
    Expression<int>? pointCount,
    Expression<String>? startPlaceId,
    Expression<String>? endPlaceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localRev != null) 'local_rev': localRev,
      if (serverRev != null) 'server_rev': serverRev,
      if (syncState != null) 'sync_state': syncState,
      if (source != null) 'source': source,
      if (name != null) 'name': name,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (pointCount != null) 'point_count': pointCount,
      if (startPlaceId != null) 'start_place_id': startPlaceId,
      if (endPlaceId != null) 'end_place_id': endPlaceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripsCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<String?>? deviceId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? localRev,
    Value<int?>? serverRev,
    Value<SyncState>? syncState,
    Value<RecordSource>? source,
    Value<String>? name,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<double>? distanceMeters,
    Value<int>? pointCount,
    Value<String?>? startPlaceId,
    Value<String?>? endPlaceId,
    Value<int>? rowid,
  }) {
    return TripsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localRev: localRev ?? this.localRev,
      serverRev: serverRev ?? this.serverRev,
      syncState: syncState ?? this.syncState,
      source: source ?? this.source,
      name: name ?? this.name,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      pointCount: pointCount ?? this.pointCount,
      startPlaceId: startPlaceId ?? this.startPlaceId,
      endPlaceId: endPlaceId ?? this.endPlaceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (localRev.present) {
      map['local_rev'] = Variable<int>(localRev.value);
    }
    if (serverRev.present) {
      map['server_rev'] = Variable<int>(serverRev.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(
        $TripsTable.$convertersyncState.toSql(syncState.value),
      );
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $TripsTable.$convertersource.toSql(source.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<double>(distanceMeters.value);
    }
    if (pointCount.present) {
      map['point_count'] = Variable<int>(pointCount.value);
    }
    if (startPlaceId.present) {
      map['start_place_id'] = Variable<String>(startPlaceId.value);
    }
    if (endPlaceId.present) {
      map['end_place_id'] = Variable<String>(endPlaceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
          ..write('serverRev: $serverRev, ')
          ..write('syncState: $syncState, ')
          ..write('source: $source, ')
          ..write('name: $name, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('pointCount: $pointCount, ')
          ..write('startPlaceId: $startPlaceId, ')
          ..write('endPlaceId: $endPlaceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSessionsTable extends WorkoutSessions
    with TableInfo<$WorkoutSessionsTable, WorkoutSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localRevMeta = const VerificationMeta(
    'localRev',
  );
  @override
  late final GeneratedColumn<int> localRev = GeneratedColumn<int>(
    'local_rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _serverRevMeta = const VerificationMeta(
    'serverRev',
  );
  @override
  late final GeneratedColumn<int> serverRev = GeneratedColumn<int>(
    'server_rev',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncState, String> syncState =
      GeneratedColumn<String>(
        'sync_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('localOnly'),
      ).withConverter<SyncState>($WorkoutSessionsTable.$convertersyncState);
  @override
  late final GeneratedColumnWithTypeConverter<RecordSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RecordSource>($WorkoutSessionsTable.$convertersource);
  @override
  late final GeneratedColumnWithTypeConverter<ActivityType, String>
  activityType = GeneratedColumn<String>(
    'activity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ActivityType>($WorkoutSessionsTable.$converteractivityType);
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<double> distanceMeters = GeneratedColumn<double>(
    'distance_meters',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
    'calories',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    deviceId,
    createdAt,
    updatedAt,
    deletedAt,
    localRev,
    serverRev,
    syncState,
    source,
    activityType,
    startedAt,
    endedAt,
    distanceMeters,
    calories,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('local_rev')) {
      context.handle(
        _localRevMeta,
        localRev.isAcceptableOrUnknown(data['local_rev']!, _localRevMeta),
      );
    }
    if (data.containsKey('server_rev')) {
      context.handle(
        _serverRevMeta,
        serverRev.isAcceptableOrUnknown(data['server_rev']!, _serverRevMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      localRev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_rev'],
      )!,
      serverRev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_rev'],
      ),
      syncState: $WorkoutSessionsTable.$convertersyncState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_state'],
        )!,
      ),
      source: $WorkoutSessionsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      activityType: $WorkoutSessionsTable.$converteractivityType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}activity_type'],
        )!,
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_meters'],
      ),
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  $WorkoutSessionsTable createAlias(String alias) {
    return $WorkoutSessionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncState, String, String> $convertersyncState =
      const EnumNameConverter<SyncState>(SyncState.values);
  static JsonTypeConverter2<RecordSource, String, String> $convertersource =
      const EnumNameConverter<RecordSource>(RecordSource.values);
  static JsonTypeConverter2<ActivityType, String, String>
  $converteractivityType = const EnumNameConverter<ActivityType>(
    ActivityType.values,
  );
}

class WorkoutSession extends DataClass implements Insertable<WorkoutSession> {
  final String id;
  final String? userId;
  final String? deviceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int localRev;
  final int? serverRev;
  final SyncState syncState;
  final RecordSource source;
  final ActivityType activityType;
  final DateTime startedAt;
  final DateTime? endedAt;
  final double? distanceMeters;
  final double? calories;
  final String notes;
  const WorkoutSession({
    required this.id,
    this.userId,
    this.deviceId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.localRev,
    this.serverRev,
    required this.syncState,
    required this.source,
    required this.activityType,
    required this.startedAt,
    this.endedAt,
    this.distanceMeters,
    this.calories,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['local_rev'] = Variable<int>(localRev);
    if (!nullToAbsent || serverRev != null) {
      map['server_rev'] = Variable<int>(serverRev);
    }
    {
      map['sync_state'] = Variable<String>(
        $WorkoutSessionsTable.$convertersyncState.toSql(syncState),
      );
    }
    {
      map['source'] = Variable<String>(
        $WorkoutSessionsTable.$convertersource.toSql(source),
      );
    }
    {
      map['activity_type'] = Variable<String>(
        $WorkoutSessionsTable.$converteractivityType.toSql(activityType),
      );
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || distanceMeters != null) {
      map['distance_meters'] = Variable<double>(distanceMeters);
    }
    if (!nullToAbsent || calories != null) {
      map['calories'] = Variable<double>(calories);
    }
    map['notes'] = Variable<String>(notes);
    return map;
  }

  WorkoutSessionsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSessionsCompanion(
      id: Value(id),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localRev: Value(localRev),
      serverRev: serverRev == null && nullToAbsent
          ? const Value.absent()
          : Value(serverRev),
      syncState: Value(syncState),
      source: Value(source),
      activityType: Value(activityType),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      distanceMeters: distanceMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceMeters),
      calories: calories == null && nullToAbsent
          ? const Value.absent()
          : Value(calories),
      notes: Value(notes),
    );
  }

  factory WorkoutSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSession(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      localRev: serializer.fromJson<int>(json['localRev']),
      serverRev: serializer.fromJson<int?>(json['serverRev']),
      syncState: $WorkoutSessionsTable.$convertersyncState.fromJson(
        serializer.fromJson<String>(json['syncState']),
      ),
      source: $WorkoutSessionsTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      activityType: $WorkoutSessionsTable.$converteractivityType.fromJson(
        serializer.fromJson<String>(json['activityType']),
      ),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      distanceMeters: serializer.fromJson<double?>(json['distanceMeters']),
      calories: serializer.fromJson<double?>(json['calories']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'deviceId': serializer.toJson<String?>(deviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'localRev': serializer.toJson<int>(localRev),
      'serverRev': serializer.toJson<int?>(serverRev),
      'syncState': serializer.toJson<String>(
        $WorkoutSessionsTable.$convertersyncState.toJson(syncState),
      ),
      'source': serializer.toJson<String>(
        $WorkoutSessionsTable.$convertersource.toJson(source),
      ),
      'activityType': serializer.toJson<String>(
        $WorkoutSessionsTable.$converteractivityType.toJson(activityType),
      ),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'distanceMeters': serializer.toJson<double?>(distanceMeters),
      'calories': serializer.toJson<double?>(calories),
      'notes': serializer.toJson<String>(notes),
    };
  }

  WorkoutSession copyWith({
    String? id,
    Value<String?> userId = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? localRev,
    Value<int?> serverRev = const Value.absent(),
    SyncState? syncState,
    RecordSource? source,
    ActivityType? activityType,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    Value<double?> distanceMeters = const Value.absent(),
    Value<double?> calories = const Value.absent(),
    String? notes,
  }) => WorkoutSession(
    id: id ?? this.id,
    userId: userId.present ? userId.value : this.userId,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localRev: localRev ?? this.localRev,
    serverRev: serverRev.present ? serverRev.value : this.serverRev,
    syncState: syncState ?? this.syncState,
    source: source ?? this.source,
    activityType: activityType ?? this.activityType,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    distanceMeters: distanceMeters.present
        ? distanceMeters.value
        : this.distanceMeters,
    calories: calories.present ? calories.value : this.calories,
    notes: notes ?? this.notes,
  );
  WorkoutSession copyWithCompanion(WorkoutSessionsCompanion data) {
    return WorkoutSession(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localRev: data.localRev.present ? data.localRev.value : this.localRev,
      serverRev: data.serverRev.present ? data.serverRev.value : this.serverRev,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      source: data.source.present ? data.source.value : this.source,
      activityType: data.activityType.present
          ? data.activityType.value
          : this.activityType,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      calories: data.calories.present ? data.calories.value : this.calories,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSession(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
          ..write('serverRev: $serverRev, ')
          ..write('syncState: $syncState, ')
          ..write('source: $source, ')
          ..write('activityType: $activityType, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('calories: $calories, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    deviceId,
    createdAt,
    updatedAt,
    deletedAt,
    localRev,
    serverRev,
    syncState,
    source,
    activityType,
    startedAt,
    endedAt,
    distanceMeters,
    calories,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSession &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localRev == this.localRev &&
          other.serverRev == this.serverRev &&
          other.syncState == this.syncState &&
          other.source == this.source &&
          other.activityType == this.activityType &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.distanceMeters == this.distanceMeters &&
          other.calories == this.calories &&
          other.notes == this.notes);
}

class WorkoutSessionsCompanion extends UpdateCompanion<WorkoutSession> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<String?> deviceId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> localRev;
  final Value<int?> serverRev;
  final Value<SyncState> syncState;
  final Value<RecordSource> source;
  final Value<ActivityType> activityType;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<double?> distanceMeters;
  final Value<double?> calories;
  final Value<String> notes;
  final Value<int> rowid;
  const WorkoutSessionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.serverRev = const Value.absent(),
    this.syncState = const Value.absent(),
    this.source = const Value.absent(),
    this.activityType = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.calories = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutSessionsCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.serverRev = const Value.absent(),
    this.syncState = const Value.absent(),
    required RecordSource source,
    required ActivityType activityType,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.calories = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : source = Value(source),
       activityType = Value(activityType),
       startedAt = Value(startedAt);
  static Insertable<WorkoutSession> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? deviceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? localRev,
    Expression<int>? serverRev,
    Expression<String>? syncState,
    Expression<String>? source,
    Expression<String>? activityType,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<double>? distanceMeters,
    Expression<double>? calories,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localRev != null) 'local_rev': localRev,
      if (serverRev != null) 'server_rev': serverRev,
      if (syncState != null) 'sync_state': syncState,
      if (source != null) 'source': source,
      if (activityType != null) 'activity_type': activityType,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (calories != null) 'calories': calories,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutSessionsCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<String?>? deviceId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? localRev,
    Value<int?>? serverRev,
    Value<SyncState>? syncState,
    Value<RecordSource>? source,
    Value<ActivityType>? activityType,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<double?>? distanceMeters,
    Value<double?>? calories,
    Value<String>? notes,
    Value<int>? rowid,
  }) {
    return WorkoutSessionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localRev: localRev ?? this.localRev,
      serverRev: serverRev ?? this.serverRev,
      syncState: syncState ?? this.syncState,
      source: source ?? this.source,
      activityType: activityType ?? this.activityType,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      calories: calories ?? this.calories,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (localRev.present) {
      map['local_rev'] = Variable<int>(localRev.value);
    }
    if (serverRev.present) {
      map['server_rev'] = Variable<int>(serverRev.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(
        $WorkoutSessionsTable.$convertersyncState.toSql(syncState.value),
      );
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $WorkoutSessionsTable.$convertersource.toSql(source.value),
      );
    }
    if (activityType.present) {
      map['activity_type'] = Variable<String>(
        $WorkoutSessionsTable.$converteractivityType.toSql(activityType.value),
      );
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<double>(distanceMeters.value);
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
          ..write('serverRev: $serverRev, ')
          ..write('syncState: $syncState, ')
          ..write('source: $source, ')
          ..write('activityType: $activityType, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('calories: $calories, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, Note> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localRevMeta = const VerificationMeta(
    'localRev',
  );
  @override
  late final GeneratedColumn<int> localRev = GeneratedColumn<int>(
    'local_rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _serverRevMeta = const VerificationMeta(
    'serverRev',
  );
  @override
  late final GeneratedColumn<int> serverRev = GeneratedColumn<int>(
    'server_rev',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncState, String> syncState =
      GeneratedColumn<String>(
        'sync_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('localOnly'),
      ).withConverter<SyncState>($NotesTable.$convertersyncState);
  @override
  late final GeneratedColumnWithTypeConverter<RecordSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RecordSource>($NotesTable.$convertersource);
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteDateMeta = const VerificationMeta(
    'noteDate',
  );
  @override
  late final GeneratedColumn<DateTime> noteDate = GeneratedColumn<DateTime>(
    'note_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextMeta = const VerificationMeta(
    'context',
  );
  @override
  late final GeneratedColumn<String> context = GeneratedColumn<String>(
    'context',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    deviceId,
    createdAt,
    updatedAt,
    deletedAt,
    localRev,
    serverRev,
    syncState,
    source,
    content,
    noteDate,
    context,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Note> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('local_rev')) {
      context.handle(
        _localRevMeta,
        localRev.isAcceptableOrUnknown(data['local_rev']!, _localRevMeta),
      );
    }
    if (data.containsKey('server_rev')) {
      context.handle(
        _serverRevMeta,
        serverRev.isAcceptableOrUnknown(data['server_rev']!, _serverRevMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('note_date')) {
      context.handle(
        _noteDateMeta,
        noteDate.isAcceptableOrUnknown(data['note_date']!, _noteDateMeta),
      );
    } else if (isInserting) {
      context.missing(_noteDateMeta);
    }
    if (data.containsKey('context')) {
      context.handle(
        _contextMeta,
        this.context.isAcceptableOrUnknown(data['context']!, _contextMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Note map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Note(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      localRev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_rev'],
      )!,
      serverRev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_rev'],
      ),
      syncState: $NotesTable.$convertersyncState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_state'],
        )!,
      ),
      source: $NotesTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      noteDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}note_date'],
      )!,
      context: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context'],
      )!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncState, String, String> $convertersyncState =
      const EnumNameConverter<SyncState>(SyncState.values);
  static JsonTypeConverter2<RecordSource, String, String> $convertersource =
      const EnumNameConverter<RecordSource>(RecordSource.values);
}

class Note extends DataClass implements Insertable<Note> {
  final String id;
  final String? userId;
  final String? deviceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int localRev;
  final int? serverRev;
  final SyncState syncState;
  final RecordSource source;
  final String content;
  final DateTime noteDate;
  final String context;
  const Note({
    required this.id,
    this.userId,
    this.deviceId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.localRev,
    this.serverRev,
    required this.syncState,
    required this.source,
    required this.content,
    required this.noteDate,
    required this.context,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['local_rev'] = Variable<int>(localRev);
    if (!nullToAbsent || serverRev != null) {
      map['server_rev'] = Variable<int>(serverRev);
    }
    {
      map['sync_state'] = Variable<String>(
        $NotesTable.$convertersyncState.toSql(syncState),
      );
    }
    {
      map['source'] = Variable<String>(
        $NotesTable.$convertersource.toSql(source),
      );
    }
    map['content'] = Variable<String>(content);
    map['note_date'] = Variable<DateTime>(noteDate);
    map['context'] = Variable<String>(context);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localRev: Value(localRev),
      serverRev: serverRev == null && nullToAbsent
          ? const Value.absent()
          : Value(serverRev),
      syncState: Value(syncState),
      source: Value(source),
      content: Value(content),
      noteDate: Value(noteDate),
      context: Value(context),
    );
  }

  factory Note.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Note(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      localRev: serializer.fromJson<int>(json['localRev']),
      serverRev: serializer.fromJson<int?>(json['serverRev']),
      syncState: $NotesTable.$convertersyncState.fromJson(
        serializer.fromJson<String>(json['syncState']),
      ),
      source: $NotesTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      content: serializer.fromJson<String>(json['content']),
      noteDate: serializer.fromJson<DateTime>(json['noteDate']),
      context: serializer.fromJson<String>(json['context']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'deviceId': serializer.toJson<String?>(deviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'localRev': serializer.toJson<int>(localRev),
      'serverRev': serializer.toJson<int?>(serverRev),
      'syncState': serializer.toJson<String>(
        $NotesTable.$convertersyncState.toJson(syncState),
      ),
      'source': serializer.toJson<String>(
        $NotesTable.$convertersource.toJson(source),
      ),
      'content': serializer.toJson<String>(content),
      'noteDate': serializer.toJson<DateTime>(noteDate),
      'context': serializer.toJson<String>(context),
    };
  }

  Note copyWith({
    String? id,
    Value<String?> userId = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? localRev,
    Value<int?> serverRev = const Value.absent(),
    SyncState? syncState,
    RecordSource? source,
    String? content,
    DateTime? noteDate,
    String? context,
  }) => Note(
    id: id ?? this.id,
    userId: userId.present ? userId.value : this.userId,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localRev: localRev ?? this.localRev,
    serverRev: serverRev.present ? serverRev.value : this.serverRev,
    syncState: syncState ?? this.syncState,
    source: source ?? this.source,
    content: content ?? this.content,
    noteDate: noteDate ?? this.noteDate,
    context: context ?? this.context,
  );
  Note copyWithCompanion(NotesCompanion data) {
    return Note(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localRev: data.localRev.present ? data.localRev.value : this.localRev,
      serverRev: data.serverRev.present ? data.serverRev.value : this.serverRev,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      source: data.source.present ? data.source.value : this.source,
      content: data.content.present ? data.content.value : this.content,
      noteDate: data.noteDate.present ? data.noteDate.value : this.noteDate,
      context: data.context.present ? data.context.value : this.context,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Note(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
          ..write('serverRev: $serverRev, ')
          ..write('syncState: $syncState, ')
          ..write('source: $source, ')
          ..write('content: $content, ')
          ..write('noteDate: $noteDate, ')
          ..write('context: $context')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    deviceId,
    createdAt,
    updatedAt,
    deletedAt,
    localRev,
    serverRev,
    syncState,
    source,
    content,
    noteDate,
    context,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Note &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localRev == this.localRev &&
          other.serverRev == this.serverRev &&
          other.syncState == this.syncState &&
          other.source == this.source &&
          other.content == this.content &&
          other.noteDate == this.noteDate &&
          other.context == this.context);
}

class NotesCompanion extends UpdateCompanion<Note> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<String?> deviceId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> localRev;
  final Value<int?> serverRev;
  final Value<SyncState> syncState;
  final Value<RecordSource> source;
  final Value<String> content;
  final Value<DateTime> noteDate;
  final Value<String> context;
  final Value<int> rowid;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.serverRev = const Value.absent(),
    this.syncState = const Value.absent(),
    this.source = const Value.absent(),
    this.content = const Value.absent(),
    this.noteDate = const Value.absent(),
    this.context = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRev = const Value.absent(),
    this.serverRev = const Value.absent(),
    this.syncState = const Value.absent(),
    required RecordSource source,
    required String content,
    required DateTime noteDate,
    this.context = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : source = Value(source),
       content = Value(content),
       noteDate = Value(noteDate);
  static Insertable<Note> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? deviceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? localRev,
    Expression<int>? serverRev,
    Expression<String>? syncState,
    Expression<String>? source,
    Expression<String>? content,
    Expression<DateTime>? noteDate,
    Expression<String>? context,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localRev != null) 'local_rev': localRev,
      if (serverRev != null) 'server_rev': serverRev,
      if (syncState != null) 'sync_state': syncState,
      if (source != null) 'source': source,
      if (content != null) 'content': content,
      if (noteDate != null) 'note_date': noteDate,
      if (context != null) 'context': context,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<String?>? deviceId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? localRev,
    Value<int?>? serverRev,
    Value<SyncState>? syncState,
    Value<RecordSource>? source,
    Value<String>? content,
    Value<DateTime>? noteDate,
    Value<String>? context,
    Value<int>? rowid,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localRev: localRev ?? this.localRev,
      serverRev: serverRev ?? this.serverRev,
      syncState: syncState ?? this.syncState,
      source: source ?? this.source,
      content: content ?? this.content,
      noteDate: noteDate ?? this.noteDate,
      context: context ?? this.context,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (localRev.present) {
      map['local_rev'] = Variable<int>(localRev.value);
    }
    if (serverRev.present) {
      map['server_rev'] = Variable<int>(serverRev.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(
        $NotesTable.$convertersyncState.toSql(syncState.value),
      );
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $NotesTable.$convertersource.toSql(source.value),
      );
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (noteDate.present) {
      map['note_date'] = Variable<DateTime>(noteDate.value);
    }
    if (context.present) {
      map['context'] = Variable<String>(context.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRev: $localRev, ')
          ..write('serverRev: $serverRev, ')
          ..write('syncState: $syncState, ')
          ..write('source: $source, ')
          ..write('content: $content, ')
          ..write('noteDate: $noteDate, ')
          ..write('context: $context, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DevicesTable devices = $DevicesTable(this);
  late final $LocationPointsTable locationPoints = $LocationPointsTable(this);
  late final $HealthSamplesTable healthSamples = $HealthSamplesTable(this);
  late final $ActivitySamplesTable activitySamples = $ActivitySamplesTable(
    this,
  );
  late final $GoalsTable goals = $GoalsTable(this);
  late final $PlacesTable places = $PlacesTable(this);
  late final $TripsTable trips = $TripsTable(this);
  late final $WorkoutSessionsTable workoutSessions = $WorkoutSessionsTable(
    this,
  );
  late final $NotesTable notes = $NotesTable(this);
  late final Index idxLocationPointsHistory = Index(
    'idx_location_points_history',
    'CREATE INDEX idx_location_points_history ON location_points (deleted_at, recorded_at)',
  );
  late final Index idxLocationPointsSyncState = Index(
    'idx_location_points_sync_state',
    'CREATE INDEX idx_location_points_sync_state ON location_points (sync_state)',
  );
  late final Index idxHealthSamplesMetricRecorded = Index(
    'idx_health_samples_metric_recorded',
    'CREATE INDEX idx_health_samples_metric_recorded ON health_samples (metric_type, recorded_at)',
  );
  late final Index idxHealthSamplesSyncState = Index(
    'idx_health_samples_sync_state',
    'CREATE INDEX idx_health_samples_sync_state ON health_samples (sync_state)',
  );
  late final Index idxActivitySamplesSyncState = Index(
    'idx_activity_samples_sync_state',
    'CREATE INDEX idx_activity_samples_sync_state ON activity_samples (sync_state)',
  );
  late final Index idxPlacesDeletedAt = Index(
    'idx_places_deleted_at',
    'CREATE INDEX idx_places_deleted_at ON places (deleted_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    devices,
    locationPoints,
    healthSamples,
    activitySamples,
    goals,
    places,
    trips,
    workoutSessions,
    notes,
    idxLocationPointsHistory,
    idxLocationPointsSyncState,
    idxHealthSamplesMetricRecorded,
    idxHealthSamplesSyncState,
    idxActivitySamplesSyncState,
    idxPlacesDeletedAt,
  ];
}

typedef $$DevicesTableCreateCompanionBuilder =
    DevicesCompanion Function({
      required String id,
      Value<String?> userId,
      required String name,
      required String platform,
      Value<String?> appVersion,
      Value<bool> isCurrentDevice,
      Value<DateTime> registeredAt,
      Value<DateTime> lastSeenAt,
      Value<int> rowid,
    });
typedef $$DevicesTableUpdateCompanionBuilder =
    DevicesCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String> name,
      Value<String> platform,
      Value<String?> appVersion,
      Value<bool> isCurrentDevice,
      Value<DateTime> registeredAt,
      Value<DateTime> lastSeenAt,
      Value<int> rowid,
    });

class $$DevicesTableFilterComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCurrentDevice => $composableBuilder(
    column: $table.isCurrentDevice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get registeredAt => $composableBuilder(
    column: $table.registeredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCurrentDevice => $composableBuilder(
    column: $table.isCurrentDevice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get registeredAt => $composableBuilder(
    column: $table.registeredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCurrentDevice => $composableBuilder(
    column: $table.isCurrentDevice,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get registeredAt => $composableBuilder(
    column: $table.registeredAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );
}

class $$DevicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DevicesTable,
          Device,
          $$DevicesTableFilterComposer,
          $$DevicesTableOrderingComposer,
          $$DevicesTableAnnotationComposer,
          $$DevicesTableCreateCompanionBuilder,
          $$DevicesTableUpdateCompanionBuilder,
          (Device, BaseReferences<_$AppDatabase, $DevicesTable, Device>),
          Device,
          PrefetchHooks Function()
        > {
  $$DevicesTableTableManager(_$AppDatabase db, $DevicesTable table)
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
                Value<String?> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String?> appVersion = const Value.absent(),
                Value<bool> isCurrentDevice = const Value.absent(),
                Value<DateTime> registeredAt = const Value.absent(),
                Value<DateTime> lastSeenAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion(
                id: id,
                userId: userId,
                name: name,
                platform: platform,
                appVersion: appVersion,
                isCurrentDevice: isCurrentDevice,
                registeredAt: registeredAt,
                lastSeenAt: lastSeenAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> userId = const Value.absent(),
                required String name,
                required String platform,
                Value<String?> appVersion = const Value.absent(),
                Value<bool> isCurrentDevice = const Value.absent(),
                Value<DateTime> registeredAt = const Value.absent(),
                Value<DateTime> lastSeenAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                platform: platform,
                appVersion: appVersion,
                isCurrentDevice: isCurrentDevice,
                registeredAt: registeredAt,
                lastSeenAt: lastSeenAt,
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
      _$AppDatabase,
      $DevicesTable,
      Device,
      $$DevicesTableFilterComposer,
      $$DevicesTableOrderingComposer,
      $$DevicesTableAnnotationComposer,
      $$DevicesTableCreateCompanionBuilder,
      $$DevicesTableUpdateCompanionBuilder,
      (Device, BaseReferences<_$AppDatabase, $DevicesTable, Device>),
      Device,
      PrefetchHooks Function()
    >;
typedef $$LocationPointsTableCreateCompanionBuilder =
    LocationPointsCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String?> deviceId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> localRev,
      Value<int?> serverRev,
      Value<SyncState> syncState,
      required RecordSource source,
      required double latitude,
      required double longitude,
      Value<double?> altitude,
      Value<double?> horizontalAccuracy,
      Value<double?> verticalAccuracy,
      Value<double?> speed,
      Value<double?> heading,
      required DateTime recordedAt,
      Value<int?> batteryLevel,
      Value<Connectivity> connectivity,
      required MonitoringMode monitoringMode,
      Value<int> rowid,
    });
typedef $$LocationPointsTableUpdateCompanionBuilder =
    LocationPointsCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String?> deviceId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> localRev,
      Value<int?> serverRev,
      Value<SyncState> syncState,
      Value<RecordSource> source,
      Value<double> latitude,
      Value<double> longitude,
      Value<double?> altitude,
      Value<double?> horizontalAccuracy,
      Value<double?> verticalAccuracy,
      Value<double?> speed,
      Value<double?> heading,
      Value<DateTime> recordedAt,
      Value<int?> batteryLevel,
      Value<Connectivity> connectivity,
      Value<MonitoringMode> monitoringMode,
      Value<int> rowid,
    });

class $$LocationPointsTableFilterComposer
    extends Composer<_$AppDatabase, $LocationPointsTable> {
  $$LocationPointsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localRev => $composableBuilder(
    column: $table.localRev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverRev => $composableBuilder(
    column: $table.serverRev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncState, SyncState, String> get syncState =>
      $composableBuilder(
        column: $table.syncState,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<RecordSource, RecordSource, String>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get horizontalAccuracy => $composableBuilder(
    column: $table.horizontalAccuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get verticalAccuracy => $composableBuilder(
    column: $table.verticalAccuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heading => $composableBuilder(
    column: $table.heading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get batteryLevel => $composableBuilder(
    column: $table.batteryLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Connectivity, Connectivity, String>
  get connectivity => $composableBuilder(
    column: $table.connectivity,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<MonitoringMode, MonitoringMode, String>
  get monitoringMode => $composableBuilder(
    column: $table.monitoringMode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$LocationPointsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocationPointsTable> {
  $$LocationPointsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localRev => $composableBuilder(
    column: $table.localRev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverRev => $composableBuilder(
    column: $table.serverRev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get horizontalAccuracy => $composableBuilder(
    column: $table.horizontalAccuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get verticalAccuracy => $composableBuilder(
    column: $table.verticalAccuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heading => $composableBuilder(
    column: $table.heading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get batteryLevel => $composableBuilder(
    column: $table.batteryLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get connectivity => $composableBuilder(
    column: $table.connectivity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get monitoringMode => $composableBuilder(
    column: $table.monitoringMode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocationPointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocationPointsTable> {
  $$LocationPointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localRev =>
      $composableBuilder(column: $table.localRev, builder: (column) => column);

  GeneratedColumn<int> get serverRev =>
      $composableBuilder(column: $table.serverRev, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncState, String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RecordSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get altitude =>
      $composableBuilder(column: $table.altitude, builder: (column) => column);

  GeneratedColumn<double> get horizontalAccuracy => $composableBuilder(
    column: $table.horizontalAccuracy,
    builder: (column) => column,
  );

  GeneratedColumn<double> get verticalAccuracy => $composableBuilder(
    column: $table.verticalAccuracy,
    builder: (column) => column,
  );

  GeneratedColumn<double> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  GeneratedColumn<double> get heading =>
      $composableBuilder(column: $table.heading, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get batteryLevel => $composableBuilder(
    column: $table.batteryLevel,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Connectivity, String> get connectivity =>
      $composableBuilder(
        column: $table.connectivity,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<MonitoringMode, String> get monitoringMode =>
      $composableBuilder(
        column: $table.monitoringMode,
        builder: (column) => column,
      );
}

class $$LocationPointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocationPointsTable,
          LocationPoint,
          $$LocationPointsTableFilterComposer,
          $$LocationPointsTableOrderingComposer,
          $$LocationPointsTableAnnotationComposer,
          $$LocationPointsTableCreateCompanionBuilder,
          $$LocationPointsTableUpdateCompanionBuilder,
          (
            LocationPoint,
            BaseReferences<_$AppDatabase, $LocationPointsTable, LocationPoint>,
          ),
          LocationPoint,
          PrefetchHooks Function()
        > {
  $$LocationPointsTableTableManager(
    _$AppDatabase db,
    $LocationPointsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationPointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationPointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocationPointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> localRev = const Value.absent(),
                Value<int?> serverRev = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                Value<RecordSource> source = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double?> altitude = const Value.absent(),
                Value<double?> horizontalAccuracy = const Value.absent(),
                Value<double?> verticalAccuracy = const Value.absent(),
                Value<double?> speed = const Value.absent(),
                Value<double?> heading = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<int?> batteryLevel = const Value.absent(),
                Value<Connectivity> connectivity = const Value.absent(),
                Value<MonitoringMode> monitoringMode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocationPointsCompanion(
                id: id,
                userId: userId,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRev: localRev,
                serverRev: serverRev,
                syncState: syncState,
                source: source,
                latitude: latitude,
                longitude: longitude,
                altitude: altitude,
                horizontalAccuracy: horizontalAccuracy,
                verticalAccuracy: verticalAccuracy,
                speed: speed,
                heading: heading,
                recordedAt: recordedAt,
                batteryLevel: batteryLevel,
                connectivity: connectivity,
                monitoringMode: monitoringMode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> localRev = const Value.absent(),
                Value<int?> serverRev = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                required RecordSource source,
                required double latitude,
                required double longitude,
                Value<double?> altitude = const Value.absent(),
                Value<double?> horizontalAccuracy = const Value.absent(),
                Value<double?> verticalAccuracy = const Value.absent(),
                Value<double?> speed = const Value.absent(),
                Value<double?> heading = const Value.absent(),
                required DateTime recordedAt,
                Value<int?> batteryLevel = const Value.absent(),
                Value<Connectivity> connectivity = const Value.absent(),
                required MonitoringMode monitoringMode,
                Value<int> rowid = const Value.absent(),
              }) => LocationPointsCompanion.insert(
                id: id,
                userId: userId,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRev: localRev,
                serverRev: serverRev,
                syncState: syncState,
                source: source,
                latitude: latitude,
                longitude: longitude,
                altitude: altitude,
                horizontalAccuracy: horizontalAccuracy,
                verticalAccuracy: verticalAccuracy,
                speed: speed,
                heading: heading,
                recordedAt: recordedAt,
                batteryLevel: batteryLevel,
                connectivity: connectivity,
                monitoringMode: monitoringMode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocationPointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocationPointsTable,
      LocationPoint,
      $$LocationPointsTableFilterComposer,
      $$LocationPointsTableOrderingComposer,
      $$LocationPointsTableAnnotationComposer,
      $$LocationPointsTableCreateCompanionBuilder,
      $$LocationPointsTableUpdateCompanionBuilder,
      (
        LocationPoint,
        BaseReferences<_$AppDatabase, $LocationPointsTable, LocationPoint>,
      ),
      LocationPoint,
      PrefetchHooks Function()
    >;
typedef $$HealthSamplesTableCreateCompanionBuilder =
    HealthSamplesCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String?> deviceId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> localRev,
      Value<int?> serverRev,
      Value<SyncState> syncState,
      required RecordSource source,
      required HealthMetricType metricType,
      required double value,
      Value<String> unit,
      required DateTime recordedAt,
      Value<String> note,
      Value<int> rowid,
    });
typedef $$HealthSamplesTableUpdateCompanionBuilder =
    HealthSamplesCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String?> deviceId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> localRev,
      Value<int?> serverRev,
      Value<SyncState> syncState,
      Value<RecordSource> source,
      Value<HealthMetricType> metricType,
      Value<double> value,
      Value<String> unit,
      Value<DateTime> recordedAt,
      Value<String> note,
      Value<int> rowid,
    });

class $$HealthSamplesTableFilterComposer
    extends Composer<_$AppDatabase, $HealthSamplesTable> {
  $$HealthSamplesTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localRev => $composableBuilder(
    column: $table.localRev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverRev => $composableBuilder(
    column: $table.serverRev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncState, SyncState, String> get syncState =>
      $composableBuilder(
        column: $table.syncState,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<RecordSource, RecordSource, String>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<HealthMetricType, HealthMetricType, String>
  get metricType => $composableBuilder(
    column: $table.metricType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HealthSamplesTableOrderingComposer
    extends Composer<_$AppDatabase, $HealthSamplesTable> {
  $$HealthSamplesTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localRev => $composableBuilder(
    column: $table.localRev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverRev => $composableBuilder(
    column: $table.serverRev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metricType => $composableBuilder(
    column: $table.metricType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HealthSamplesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HealthSamplesTable> {
  $$HealthSamplesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localRev =>
      $composableBuilder(column: $table.localRev, builder: (column) => column);

  GeneratedColumn<int> get serverRev =>
      $composableBuilder(column: $table.serverRev, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncState, String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RecordSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumnWithTypeConverter<HealthMetricType, String> get metricType =>
      $composableBuilder(
        column: $table.metricType,
        builder: (column) => column,
      );

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$HealthSamplesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HealthSamplesTable,
          HealthSample,
          $$HealthSamplesTableFilterComposer,
          $$HealthSamplesTableOrderingComposer,
          $$HealthSamplesTableAnnotationComposer,
          $$HealthSamplesTableCreateCompanionBuilder,
          $$HealthSamplesTableUpdateCompanionBuilder,
          (
            HealthSample,
            BaseReferences<_$AppDatabase, $HealthSamplesTable, HealthSample>,
          ),
          HealthSample,
          PrefetchHooks Function()
        > {
  $$HealthSamplesTableTableManager(_$AppDatabase db, $HealthSamplesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HealthSamplesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HealthSamplesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HealthSamplesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> localRev = const Value.absent(),
                Value<int?> serverRev = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                Value<RecordSource> source = const Value.absent(),
                Value<HealthMetricType> metricType = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HealthSamplesCompanion(
                id: id,
                userId: userId,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRev: localRev,
                serverRev: serverRev,
                syncState: syncState,
                source: source,
                metricType: metricType,
                value: value,
                unit: unit,
                recordedAt: recordedAt,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> localRev = const Value.absent(),
                Value<int?> serverRev = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                required RecordSource source,
                required HealthMetricType metricType,
                required double value,
                Value<String> unit = const Value.absent(),
                required DateTime recordedAt,
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HealthSamplesCompanion.insert(
                id: id,
                userId: userId,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRev: localRev,
                serverRev: serverRev,
                syncState: syncState,
                source: source,
                metricType: metricType,
                value: value,
                unit: unit,
                recordedAt: recordedAt,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HealthSamplesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HealthSamplesTable,
      HealthSample,
      $$HealthSamplesTableFilterComposer,
      $$HealthSamplesTableOrderingComposer,
      $$HealthSamplesTableAnnotationComposer,
      $$HealthSamplesTableCreateCompanionBuilder,
      $$HealthSamplesTableUpdateCompanionBuilder,
      (
        HealthSample,
        BaseReferences<_$AppDatabase, $HealthSamplesTable, HealthSample>,
      ),
      HealthSample,
      PrefetchHooks Function()
    >;
typedef $$ActivitySamplesTableCreateCompanionBuilder =
    ActivitySamplesCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String?> deviceId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> localRev,
      Value<int?> serverRev,
      Value<SyncState> syncState,
      required RecordSource source,
      required ActivityType activityType,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<double?> confidence,
      Value<double?> distanceMeters,
      Value<int?> steps,
      Value<int> rowid,
    });
typedef $$ActivitySamplesTableUpdateCompanionBuilder =
    ActivitySamplesCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String?> deviceId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> localRev,
      Value<int?> serverRev,
      Value<SyncState> syncState,
      Value<RecordSource> source,
      Value<ActivityType> activityType,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<double?> confidence,
      Value<double?> distanceMeters,
      Value<int?> steps,
      Value<int> rowid,
    });

class $$ActivitySamplesTableFilterComposer
    extends Composer<_$AppDatabase, $ActivitySamplesTable> {
  $$ActivitySamplesTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localRev => $composableBuilder(
    column: $table.localRev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverRev => $composableBuilder(
    column: $table.serverRev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncState, SyncState, String> get syncState =>
      $composableBuilder(
        column: $table.syncState,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<RecordSource, RecordSource, String>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<ActivityType, ActivityType, String>
  get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActivitySamplesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivitySamplesTable> {
  $$ActivitySamplesTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localRev => $composableBuilder(
    column: $table.localRev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverRev => $composableBuilder(
    column: $table.serverRev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivitySamplesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivitySamplesTable> {
  $$ActivitySamplesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localRev =>
      $composableBuilder(column: $table.localRev, builder: (column) => column);

  GeneratedColumn<int> get serverRev =>
      $composableBuilder(column: $table.serverRev, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncState, String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RecordSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActivityType, String> get activityType =>
      $composableBuilder(
        column: $table.activityType,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);
}

class $$ActivitySamplesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivitySamplesTable,
          ActivitySample,
          $$ActivitySamplesTableFilterComposer,
          $$ActivitySamplesTableOrderingComposer,
          $$ActivitySamplesTableAnnotationComposer,
          $$ActivitySamplesTableCreateCompanionBuilder,
          $$ActivitySamplesTableUpdateCompanionBuilder,
          (
            ActivitySample,
            BaseReferences<
              _$AppDatabase,
              $ActivitySamplesTable,
              ActivitySample
            >,
          ),
          ActivitySample,
          PrefetchHooks Function()
        > {
  $$ActivitySamplesTableTableManager(
    _$AppDatabase db,
    $ActivitySamplesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivitySamplesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivitySamplesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivitySamplesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> localRev = const Value.absent(),
                Value<int?> serverRev = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                Value<RecordSource> source = const Value.absent(),
                Value<ActivityType> activityType = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<double?> distanceMeters = const Value.absent(),
                Value<int?> steps = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitySamplesCompanion(
                id: id,
                userId: userId,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRev: localRev,
                serverRev: serverRev,
                syncState: syncState,
                source: source,
                activityType: activityType,
                startedAt: startedAt,
                endedAt: endedAt,
                confidence: confidence,
                distanceMeters: distanceMeters,
                steps: steps,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> localRev = const Value.absent(),
                Value<int?> serverRev = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                required RecordSource source,
                required ActivityType activityType,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<double?> distanceMeters = const Value.absent(),
                Value<int?> steps = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitySamplesCompanion.insert(
                id: id,
                userId: userId,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRev: localRev,
                serverRev: serverRev,
                syncState: syncState,
                source: source,
                activityType: activityType,
                startedAt: startedAt,
                endedAt: endedAt,
                confidence: confidence,
                distanceMeters: distanceMeters,
                steps: steps,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActivitySamplesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivitySamplesTable,
      ActivitySample,
      $$ActivitySamplesTableFilterComposer,
      $$ActivitySamplesTableOrderingComposer,
      $$ActivitySamplesTableAnnotationComposer,
      $$ActivitySamplesTableCreateCompanionBuilder,
      $$ActivitySamplesTableUpdateCompanionBuilder,
      (
        ActivitySample,
        BaseReferences<_$AppDatabase, $ActivitySamplesTable, ActivitySample>,
      ),
      ActivitySample,
      PrefetchHooks Function()
    >;
typedef $$GoalsTableCreateCompanionBuilder =
    GoalsCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String?> deviceId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> localRev,
      Value<int?> serverRev,
      Value<SyncState> syncState,
      required RecordSource source,
      required HealthMetricType metricType,
      required double targetValue,
      Value<GoalPeriod> period,
      required DateTime startDate,
      Value<DateTime?> endDate,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$GoalsTableUpdateCompanionBuilder =
    GoalsCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String?> deviceId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> localRev,
      Value<int?> serverRev,
      Value<SyncState> syncState,
      Value<RecordSource> source,
      Value<HealthMetricType> metricType,
      Value<double> targetValue,
      Value<GoalPeriod> period,
      Value<DateTime> startDate,
      Value<DateTime?> endDate,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localRev => $composableBuilder(
    column: $table.localRev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverRev => $composableBuilder(
    column: $table.serverRev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncState, SyncState, String> get syncState =>
      $composableBuilder(
        column: $table.syncState,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<RecordSource, RecordSource, String>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<HealthMetricType, HealthMetricType, String>
  get metricType => $composableBuilder(
    column: $table.metricType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<GoalPeriod, GoalPeriod, String> get period =>
      $composableBuilder(
        column: $table.period,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localRev => $composableBuilder(
    column: $table.localRev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverRev => $composableBuilder(
    column: $table.serverRev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metricType => $composableBuilder(
    column: $table.metricType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localRev =>
      $composableBuilder(column: $table.localRev, builder: (column) => column);

  GeneratedColumn<int> get serverRev =>
      $composableBuilder(column: $table.serverRev, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncState, String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RecordSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumnWithTypeConverter<HealthMetricType, String> get metricType =>
      $composableBuilder(
        column: $table.metricType,
        builder: (column) => column,
      );

  GeneratedColumn<double> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<GoalPeriod, String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$GoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalsTable,
          Goal,
          $$GoalsTableFilterComposer,
          $$GoalsTableOrderingComposer,
          $$GoalsTableAnnotationComposer,
          $$GoalsTableCreateCompanionBuilder,
          $$GoalsTableUpdateCompanionBuilder,
          (Goal, BaseReferences<_$AppDatabase, $GoalsTable, Goal>),
          Goal,
          PrefetchHooks Function()
        > {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> localRev = const Value.absent(),
                Value<int?> serverRev = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                Value<RecordSource> source = const Value.absent(),
                Value<HealthMetricType> metricType = const Value.absent(),
                Value<double> targetValue = const Value.absent(),
                Value<GoalPeriod> period = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion(
                id: id,
                userId: userId,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRev: localRev,
                serverRev: serverRev,
                syncState: syncState,
                source: source,
                metricType: metricType,
                targetValue: targetValue,
                period: period,
                startDate: startDate,
                endDate: endDate,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> localRev = const Value.absent(),
                Value<int?> serverRev = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                required RecordSource source,
                required HealthMetricType metricType,
                required double targetValue,
                Value<GoalPeriod> period = const Value.absent(),
                required DateTime startDate,
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion.insert(
                id: id,
                userId: userId,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRev: localRev,
                serverRev: serverRev,
                syncState: syncState,
                source: source,
                metricType: metricType,
                targetValue: targetValue,
                period: period,
                startDate: startDate,
                endDate: endDate,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalsTable,
      Goal,
      $$GoalsTableFilterComposer,
      $$GoalsTableOrderingComposer,
      $$GoalsTableAnnotationComposer,
      $$GoalsTableCreateCompanionBuilder,
      $$GoalsTableUpdateCompanionBuilder,
      (Goal, BaseReferences<_$AppDatabase, $GoalsTable, Goal>),
      Goal,
      PrefetchHooks Function()
    >;
typedef $$PlacesTableCreateCompanionBuilder =
    PlacesCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String?> deviceId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> localRev,
      Value<int?> serverRev,
      Value<SyncState> syncState,
      required RecordSource source,
      required String name,
      Value<PlaceCategory> category,
      required double latitude,
      required double longitude,
      Value<double> radiusMeters,
      Value<String> address,
      Value<bool> currentlyInside,
      Value<DateTime?> lastEnteredAt,
      Value<DateTime?> lastExitedAt,
      Value<DateTime?> stateAsOf,
      Value<int> rowid,
    });
typedef $$PlacesTableUpdateCompanionBuilder =
    PlacesCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String?> deviceId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> localRev,
      Value<int?> serverRev,
      Value<SyncState> syncState,
      Value<RecordSource> source,
      Value<String> name,
      Value<PlaceCategory> category,
      Value<double> latitude,
      Value<double> longitude,
      Value<double> radiusMeters,
      Value<String> address,
      Value<bool> currentlyInside,
      Value<DateTime?> lastEnteredAt,
      Value<DateTime?> lastExitedAt,
      Value<DateTime?> stateAsOf,
      Value<int> rowid,
    });

class $$PlacesTableFilterComposer
    extends Composer<_$AppDatabase, $PlacesTable> {
  $$PlacesTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localRev => $composableBuilder(
    column: $table.localRev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverRev => $composableBuilder(
    column: $table.serverRev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncState, SyncState, String> get syncState =>
      $composableBuilder(
        column: $table.syncState,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<RecordSource, RecordSource, String>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PlaceCategory, PlaceCategory, String>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get radiusMeters => $composableBuilder(
    column: $table.radiusMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get currentlyInside => $composableBuilder(
    column: $table.currentlyInside,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastEnteredAt => $composableBuilder(
    column: $table.lastEnteredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastExitedAt => $composableBuilder(
    column: $table.lastExitedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get stateAsOf => $composableBuilder(
    column: $table.stateAsOf,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlacesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlacesTable> {
  $$PlacesTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localRev => $composableBuilder(
    column: $table.localRev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverRev => $composableBuilder(
    column: $table.serverRev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get radiusMeters => $composableBuilder(
    column: $table.radiusMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get currentlyInside => $composableBuilder(
    column: $table.currentlyInside,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastEnteredAt => $composableBuilder(
    column: $table.lastEnteredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastExitedAt => $composableBuilder(
    column: $table.lastExitedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get stateAsOf => $composableBuilder(
    column: $table.stateAsOf,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlacesTable> {
  $$PlacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localRev =>
      $composableBuilder(column: $table.localRev, builder: (column) => column);

  GeneratedColumn<int> get serverRev =>
      $composableBuilder(column: $table.serverRev, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncState, String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RecordSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PlaceCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get radiusMeters => $composableBuilder(
    column: $table.radiusMeters,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<bool> get currentlyInside => $composableBuilder(
    column: $table.currentlyInside,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastEnteredAt => $composableBuilder(
    column: $table.lastEnteredAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastExitedAt => $composableBuilder(
    column: $table.lastExitedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get stateAsOf =>
      $composableBuilder(column: $table.stateAsOf, builder: (column) => column);
}

class $$PlacesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlacesTable,
          Place,
          $$PlacesTableFilterComposer,
          $$PlacesTableOrderingComposer,
          $$PlacesTableAnnotationComposer,
          $$PlacesTableCreateCompanionBuilder,
          $$PlacesTableUpdateCompanionBuilder,
          (Place, BaseReferences<_$AppDatabase, $PlacesTable, Place>),
          Place,
          PrefetchHooks Function()
        > {
  $$PlacesTableTableManager(_$AppDatabase db, $PlacesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> localRev = const Value.absent(),
                Value<int?> serverRev = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                Value<RecordSource> source = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<PlaceCategory> category = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double> radiusMeters = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<bool> currentlyInside = const Value.absent(),
                Value<DateTime?> lastEnteredAt = const Value.absent(),
                Value<DateTime?> lastExitedAt = const Value.absent(),
                Value<DateTime?> stateAsOf = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlacesCompanion(
                id: id,
                userId: userId,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRev: localRev,
                serverRev: serverRev,
                syncState: syncState,
                source: source,
                name: name,
                category: category,
                latitude: latitude,
                longitude: longitude,
                radiusMeters: radiusMeters,
                address: address,
                currentlyInside: currentlyInside,
                lastEnteredAt: lastEnteredAt,
                lastExitedAt: lastExitedAt,
                stateAsOf: stateAsOf,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> localRev = const Value.absent(),
                Value<int?> serverRev = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                required RecordSource source,
                required String name,
                Value<PlaceCategory> category = const Value.absent(),
                required double latitude,
                required double longitude,
                Value<double> radiusMeters = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<bool> currentlyInside = const Value.absent(),
                Value<DateTime?> lastEnteredAt = const Value.absent(),
                Value<DateTime?> lastExitedAt = const Value.absent(),
                Value<DateTime?> stateAsOf = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlacesCompanion.insert(
                id: id,
                userId: userId,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRev: localRev,
                serverRev: serverRev,
                syncState: syncState,
                source: source,
                name: name,
                category: category,
                latitude: latitude,
                longitude: longitude,
                radiusMeters: radiusMeters,
                address: address,
                currentlyInside: currentlyInside,
                lastEnteredAt: lastEnteredAt,
                lastExitedAt: lastExitedAt,
                stateAsOf: stateAsOf,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlacesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlacesTable,
      Place,
      $$PlacesTableFilterComposer,
      $$PlacesTableOrderingComposer,
      $$PlacesTableAnnotationComposer,
      $$PlacesTableCreateCompanionBuilder,
      $$PlacesTableUpdateCompanionBuilder,
      (Place, BaseReferences<_$AppDatabase, $PlacesTable, Place>),
      Place,
      PrefetchHooks Function()
    >;
typedef $$TripsTableCreateCompanionBuilder =
    TripsCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String?> deviceId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> localRev,
      Value<int?> serverRev,
      Value<SyncState> syncState,
      required RecordSource source,
      Value<String> name,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<double> distanceMeters,
      Value<int> pointCount,
      Value<String?> startPlaceId,
      Value<String?> endPlaceId,
      Value<int> rowid,
    });
typedef $$TripsTableUpdateCompanionBuilder =
    TripsCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String?> deviceId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> localRev,
      Value<int?> serverRev,
      Value<SyncState> syncState,
      Value<RecordSource> source,
      Value<String> name,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<double> distanceMeters,
      Value<int> pointCount,
      Value<String?> startPlaceId,
      Value<String?> endPlaceId,
      Value<int> rowid,
    });

class $$TripsTableFilterComposer extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localRev => $composableBuilder(
    column: $table.localRev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverRev => $composableBuilder(
    column: $table.serverRev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncState, SyncState, String> get syncState =>
      $composableBuilder(
        column: $table.syncState,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<RecordSource, RecordSource, String>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pointCount => $composableBuilder(
    column: $table.pointCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startPlaceId => $composableBuilder(
    column: $table.startPlaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endPlaceId => $composableBuilder(
    column: $table.endPlaceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TripsTableOrderingComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localRev => $composableBuilder(
    column: $table.localRev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverRev => $composableBuilder(
    column: $table.serverRev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pointCount => $composableBuilder(
    column: $table.pointCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startPlaceId => $composableBuilder(
    column: $table.startPlaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endPlaceId => $composableBuilder(
    column: $table.endPlaceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TripsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localRev =>
      $composableBuilder(column: $table.localRev, builder: (column) => column);

  GeneratedColumn<int> get serverRev =>
      $composableBuilder(column: $table.serverRev, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncState, String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RecordSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pointCount => $composableBuilder(
    column: $table.pointCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startPlaceId => $composableBuilder(
    column: $table.startPlaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endPlaceId => $composableBuilder(
    column: $table.endPlaceId,
    builder: (column) => column,
  );
}

class $$TripsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripsTable,
          Trip,
          $$TripsTableFilterComposer,
          $$TripsTableOrderingComposer,
          $$TripsTableAnnotationComposer,
          $$TripsTableCreateCompanionBuilder,
          $$TripsTableUpdateCompanionBuilder,
          (Trip, BaseReferences<_$AppDatabase, $TripsTable, Trip>),
          Trip,
          PrefetchHooks Function()
        > {
  $$TripsTableTableManager(_$AppDatabase db, $TripsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> localRev = const Value.absent(),
                Value<int?> serverRev = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                Value<RecordSource> source = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<double> distanceMeters = const Value.absent(),
                Value<int> pointCount = const Value.absent(),
                Value<String?> startPlaceId = const Value.absent(),
                Value<String?> endPlaceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripsCompanion(
                id: id,
                userId: userId,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRev: localRev,
                serverRev: serverRev,
                syncState: syncState,
                source: source,
                name: name,
                startedAt: startedAt,
                endedAt: endedAt,
                distanceMeters: distanceMeters,
                pointCount: pointCount,
                startPlaceId: startPlaceId,
                endPlaceId: endPlaceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> localRev = const Value.absent(),
                Value<int?> serverRev = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                required RecordSource source,
                Value<String> name = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<double> distanceMeters = const Value.absent(),
                Value<int> pointCount = const Value.absent(),
                Value<String?> startPlaceId = const Value.absent(),
                Value<String?> endPlaceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripsCompanion.insert(
                id: id,
                userId: userId,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRev: localRev,
                serverRev: serverRev,
                syncState: syncState,
                source: source,
                name: name,
                startedAt: startedAt,
                endedAt: endedAt,
                distanceMeters: distanceMeters,
                pointCount: pointCount,
                startPlaceId: startPlaceId,
                endPlaceId: endPlaceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TripsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripsTable,
      Trip,
      $$TripsTableFilterComposer,
      $$TripsTableOrderingComposer,
      $$TripsTableAnnotationComposer,
      $$TripsTableCreateCompanionBuilder,
      $$TripsTableUpdateCompanionBuilder,
      (Trip, BaseReferences<_$AppDatabase, $TripsTable, Trip>),
      Trip,
      PrefetchHooks Function()
    >;
typedef $$WorkoutSessionsTableCreateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String?> deviceId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> localRev,
      Value<int?> serverRev,
      Value<SyncState> syncState,
      required RecordSource source,
      required ActivityType activityType,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<double?> distanceMeters,
      Value<double?> calories,
      Value<String> notes,
      Value<int> rowid,
    });
typedef $$WorkoutSessionsTableUpdateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String?> deviceId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> localRev,
      Value<int?> serverRev,
      Value<SyncState> syncState,
      Value<RecordSource> source,
      Value<ActivityType> activityType,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<double?> distanceMeters,
      Value<double?> calories,
      Value<String> notes,
      Value<int> rowid,
    });

class $$WorkoutSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localRev => $composableBuilder(
    column: $table.localRev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverRev => $composableBuilder(
    column: $table.serverRev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncState, SyncState, String> get syncState =>
      $composableBuilder(
        column: $table.syncState,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<RecordSource, RecordSource, String>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<ActivityType, ActivityType, String>
  get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkoutSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localRev => $composableBuilder(
    column: $table.localRev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverRev => $composableBuilder(
    column: $table.serverRev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localRev =>
      $composableBuilder(column: $table.localRev, builder: (column) => column);

  GeneratedColumn<int> get serverRev =>
      $composableBuilder(column: $table.serverRev, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncState, String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RecordSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActivityType, String> get activityType =>
      $composableBuilder(
        column: $table.activityType,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$WorkoutSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSessionsTable,
          WorkoutSession,
          $$WorkoutSessionsTableFilterComposer,
          $$WorkoutSessionsTableOrderingComposer,
          $$WorkoutSessionsTableAnnotationComposer,
          $$WorkoutSessionsTableCreateCompanionBuilder,
          $$WorkoutSessionsTableUpdateCompanionBuilder,
          (
            WorkoutSession,
            BaseReferences<
              _$AppDatabase,
              $WorkoutSessionsTable,
              WorkoutSession
            >,
          ),
          WorkoutSession,
          PrefetchHooks Function()
        > {
  $$WorkoutSessionsTableTableManager(
    _$AppDatabase db,
    $WorkoutSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> localRev = const Value.absent(),
                Value<int?> serverRev = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                Value<RecordSource> source = const Value.absent(),
                Value<ActivityType> activityType = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<double?> distanceMeters = const Value.absent(),
                Value<double?> calories = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSessionsCompanion(
                id: id,
                userId: userId,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRev: localRev,
                serverRev: serverRev,
                syncState: syncState,
                source: source,
                activityType: activityType,
                startedAt: startedAt,
                endedAt: endedAt,
                distanceMeters: distanceMeters,
                calories: calories,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> localRev = const Value.absent(),
                Value<int?> serverRev = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                required RecordSource source,
                required ActivityType activityType,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<double?> distanceMeters = const Value.absent(),
                Value<double?> calories = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSessionsCompanion.insert(
                id: id,
                userId: userId,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRev: localRev,
                serverRev: serverRev,
                syncState: syncState,
                source: source,
                activityType: activityType,
                startedAt: startedAt,
                endedAt: endedAt,
                distanceMeters: distanceMeters,
                calories: calories,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSessionsTable,
      WorkoutSession,
      $$WorkoutSessionsTableFilterComposer,
      $$WorkoutSessionsTableOrderingComposer,
      $$WorkoutSessionsTableAnnotationComposer,
      $$WorkoutSessionsTableCreateCompanionBuilder,
      $$WorkoutSessionsTableUpdateCompanionBuilder,
      (
        WorkoutSession,
        BaseReferences<_$AppDatabase, $WorkoutSessionsTable, WorkoutSession>,
      ),
      WorkoutSession,
      PrefetchHooks Function()
    >;
typedef $$NotesTableCreateCompanionBuilder =
    NotesCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String?> deviceId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> localRev,
      Value<int?> serverRev,
      Value<SyncState> syncState,
      required RecordSource source,
      required String content,
      required DateTime noteDate,
      Value<String> context,
      Value<int> rowid,
    });
typedef $$NotesTableUpdateCompanionBuilder =
    NotesCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String?> deviceId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> localRev,
      Value<int?> serverRev,
      Value<SyncState> syncState,
      Value<RecordSource> source,
      Value<String> content,
      Value<DateTime> noteDate,
      Value<String> context,
      Value<int> rowid,
    });

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localRev => $composableBuilder(
    column: $table.localRev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverRev => $composableBuilder(
    column: $table.serverRev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncState, SyncState, String> get syncState =>
      $composableBuilder(
        column: $table.syncState,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<RecordSource, RecordSource, String>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get noteDate => $composableBuilder(
    column: $table.noteDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get context => $composableBuilder(
    column: $table.context,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localRev => $composableBuilder(
    column: $table.localRev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverRev => $composableBuilder(
    column: $table.serverRev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get noteDate => $composableBuilder(
    column: $table.noteDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get context => $composableBuilder(
    column: $table.context,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localRev =>
      $composableBuilder(column: $table.localRev, builder: (column) => column);

  GeneratedColumn<int> get serverRev =>
      $composableBuilder(column: $table.serverRev, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncState, String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RecordSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get noteDate =>
      $composableBuilder(column: $table.noteDate, builder: (column) => column);

  GeneratedColumn<String> get context =>
      $composableBuilder(column: $table.context, builder: (column) => column);
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotesTable,
          Note,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (Note, BaseReferences<_$AppDatabase, $NotesTable, Note>),
          Note,
          PrefetchHooks Function()
        > {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> localRev = const Value.absent(),
                Value<int?> serverRev = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                Value<RecordSource> source = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> noteDate = const Value.absent(),
                Value<String> context = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                userId: userId,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRev: localRev,
                serverRev: serverRev,
                syncState: syncState,
                source: source,
                content: content,
                noteDate: noteDate,
                context: context,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> localRev = const Value.absent(),
                Value<int?> serverRev = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                required RecordSource source,
                required String content,
                required DateTime noteDate,
                Value<String> context = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion.insert(
                id: id,
                userId: userId,
                deviceId: deviceId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRev: localRev,
                serverRev: serverRev,
                syncState: syncState,
                source: source,
                content: content,
                noteDate: noteDate,
                context: context,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotesTable,
      Note,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (Note, BaseReferences<_$AppDatabase, $NotesTable, Note>),
      Note,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
  $$LocationPointsTableTableManager get locationPoints =>
      $$LocationPointsTableTableManager(_db, _db.locationPoints);
  $$HealthSamplesTableTableManager get healthSamples =>
      $$HealthSamplesTableTableManager(_db, _db.healthSamples);
  $$ActivitySamplesTableTableManager get activitySamples =>
      $$ActivitySamplesTableTableManager(_db, _db.activitySamples);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$PlacesTableTableManager get places =>
      $$PlacesTableTableManager(_db, _db.places);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db, _db.trips);
  $$WorkoutSessionsTableTableManager get workoutSessions =>
      $$WorkoutSessionsTableTableManager(_db, _db.workoutSessions);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
}
