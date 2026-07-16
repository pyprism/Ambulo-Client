import 'dart:async';

import 'package:drift/drift.dart';

/// Several tests intentionally hold multiple `AppDatabase` instances open at
/// once — e.g. `friends_integration_test.dart` simulates two signed-in users,
/// each with their own independent in-memory database. Drift's
/// multiple-database warning is a heuristic aimed at the *actual* footgun
/// (two databases sharing one `QueryExecutor`), which doesn't apply here:
/// every test creates its own `NativeDatabase.memory()`/file, so there's no
/// shared executor and no real race. Silencing it here (once, for the whole
/// suite) avoids that repeated false-positive without papering over a case
/// that would genuinely need it.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  await testMain();
}
