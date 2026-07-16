import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'onboarding_complete';

/// Whether the mobile onboarding carousel has been completed. Not used on web
/// (web always starts at login).
class OnboardingStatusController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsKey) ?? false;
  }

  Future<void> complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
    state = const AsyncData(true);
  }
}

final onboardingStatusProvider =
    AsyncNotifierProvider<OnboardingStatusController, bool>(
      OnboardingStatusController.new,
    );
