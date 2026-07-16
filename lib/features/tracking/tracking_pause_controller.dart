import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'tracking_paused';

/// A temporary "incognito" pause, independent of the selected monitoring
/// mode: turning it on stops all collection (as if mode were Quit) without
/// losing the user's actual mode setting, so un-pausing resumes exactly
/// where they left off.
class TrackingPauseController extends Notifier<bool> {
  final _readyCompleter = Completer<void>();

  /// Resolves once the persisted pause flag has been loaded. A persisted
  /// `true` must never be raced by the synchronous `false` default —
  /// callers that gate real sensor activation on this state must await
  /// this before their first apply (see `location_tracking_provider.dart`).
  Future<void> get ready => _readyCompleter.future;

  @override
  bool build() {
    _restore();
    return false;
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_prefsKey) ?? false;
    _readyCompleter.complete();
  }

  Future<void> setPaused(bool paused) async {
    state = paused;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, paused);
  }
}

final trackingPausedProvider = NotifierProvider<TrackingPauseController, bool>(
  TrackingPauseController.new,
);
