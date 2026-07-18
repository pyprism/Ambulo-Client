import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_mode_controller.dart';
import '../features/fitness/fitness_providers.dart';
import '../features/friends/friends_providers.dart';
import '../platform/fitness/step_tracking_provider.dart';
import '../platform/location/location_tracking_provider.dart';

class AmbuloApp extends ConsumerStatefulWidget {
  const AmbuloApp({super.key});

  @override
  ConsumerState<AmbuloApp> createState() => _AmbuloAppState();
}

class _AmbuloAppState extends ConsumerState<AmbuloApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Friend sharing is explicitly poll-based (pull on sync/foreground),
    // never a live push — this is the "foreground" half of that contract.
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(friendshipsProvider);
      ref.invalidate(friendLocationsProvider);
      ref.invalidate(notificationsProvider);
      // Fitness stats are point-in-time queries — without this they'd keep
      // showing whatever was true at first build (often 0) even though
      // Significant/Move tracking may have kept recording in the
      // background while the app was away.
      ref.invalidate(todayStatsProvider);
      ref.invalidate(weeklyStatsProvider);
      ref.invalidate(monthlyStatsProvider);
    } else if (state == AppLifecycleState.paused) {
      // Steps buffer in memory between debounced DB flushes (see
      // StepTrackingService) — flush on backgrounding so a buffered-but-
      // unwritten count isn't lost if the OS kills the process outright.
      ref.read(stepTrackingServiceProvider).flush();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    // Keeps the location/step services alive for the app's lifetime and
    // reactive to monitoring-mode changes; the values themselves aren't
    // needed here.
    ref.watch(locationTrackingServiceProvider);
    ref.watch(stepTrackingServiceProvider);

    return MaterialApp.router(
      title: 'Ambulo',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
      // Every screen's text is selectable/copyable by default (dashboard
      // stats, location coordinates, sync errors, etc. all need to be
      // copyable — no per-screen opt-in to remember). SelectionArea needs an
      // Overlay ancestor, which doesn't exist yet at this point in the tree
      // (the router's Navigator creates its own further down), so it's
      // given a dedicated one here.
      builder: (context, child) => Overlay(
        initialEntries: [
          OverlayEntry(builder: (context) => SelectionArea(child: child!)),
        ],
      ),
    );
  }
}
