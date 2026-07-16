import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ambulo/app/app.dart';
import 'package:ambulo/data/local/database.dart';
import 'package:ambulo/data/local/database_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows onboarding first, then reaches the dashboard shell', (
    tester,
  ) async {
    // Own the ProviderContainer directly so disposal order is explicit:
    // provider streams must be torn down before the database closes, or
    // drift's internal "keep cache a bit longer" Timer (see
    // stream_queries.dart) never resolves and the test hangs.
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const AmbuloApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Skip'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.byIcon(Icons.dashboard_outlined), findsWidgets);
  });
}
