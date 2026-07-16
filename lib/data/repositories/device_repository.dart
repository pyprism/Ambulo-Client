import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../platform/device_identity.dart';
import '../local/database.dart';
import '../local/database_provider.dart';

/// Owns this installation's device identity: a stable client-generated UUID
/// created once locally, then registered/kept alive with the server
/// (multi-device by default).
class DeviceRepository {
  DeviceRepository(this._db);

  final AppDatabase _db;

  Future<Device> ensureLocalDevice() async {
    final existing = await (_db.select(
      _db.devices,
    )..where((d) => d.isCurrentDevice.equals(true))).getSingleOrNull();
    if (existing != null) return existing;

    final entry = DevicesCompanion.insert(
      id: const Uuid().v4(),
      name: defaultDeviceName(),
      platform: currentPlatformName(),
      isCurrentDevice: const Value(true),
    );
    await _db.into(_db.devices).insert(entry);
    return (_db.select(
      _db.devices,
    )..where((d) => d.isCurrentDevice.equals(true))).getSingle();
  }

  /// Idempotent: safe to call on every login/app start. The device
  /// registration response only echoes the device itself (no user field),
  /// so the owning user id comes from the already-authenticated session.
  Future<void> registerWithServer(Dio dio, {required int userId}) async {
    final device = await ensureLocalDevice();
    await dio.post(
      '/api/accounts/devices/',
      data: {'id': device.id, 'name': device.name, 'platform': device.platform},
    );
    await (_db.update(_db.devices)..where((d) => d.id.equals(device.id))).write(
      DevicesCompanion(
        lastSeenAt: Value(DateTime.now()),
        userId: Value(userId.toString()),
      ),
    );
  }
}

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  return DeviceRepository(ref.watch(appDatabaseProvider));
});
