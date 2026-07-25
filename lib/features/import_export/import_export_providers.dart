import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../../data/local/database_provider.dart';
import '../../data/repositories/export_repository.dart';
import '../../data/repositories/health_connect_repository.dart';
import '../../data/repositories/import_repository.dart';
import '../../data/repositories/server_import_repository.dart';

final exportRepositoryProvider = Provider<ExportRepository>((ref) {
  return ExportRepository(ref.watch(appDatabaseProvider));
});

final importRepositoryProvider = Provider<ImportRepository>((ref) {
  return ImportRepository(ref.watch(appDatabaseProvider));
});

final serverImportRepositoryProvider = Provider<ServerImportRepository>((ref) {
  return ServerImportRepository(ref.watch(dioProvider));
});

final healthConnectRepositoryProvider = Provider<HealthConnectRepository>((
  ref,
) {
  return HealthConnectRepository(ref.watch(appDatabaseProvider));
});
