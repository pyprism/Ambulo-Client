import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/dio_client.dart';
import '../auth/auth_controller.dart';
import '../auth/auth_user.dart';

enum BiologicalSex { male, female, other }

const _dobKey = 'profile_date_of_birth';
const _sexKey = 'profile_biological_sex';
const _dirtyKey = 'profile_pending_upload';

/// Personal-profile attributes used to personalize calorie estimates
/// (`FitnessStatsRepository`). Weight/height are NOT here — they're
/// time-varying readings tracked as `HealthSample(metric_type: weight |
/// height)` instead, same as any other health metric, so they get a
/// history graph and the existing generic sync path for free. Only what
/// doesn't already fit that shape (age, sex) lives in this profile.
class UserProfile {
  const UserProfile({this.dateOfBirth, this.sex});

  final DateTime? dateOfBirth;
  final BiologicalSex? sex;

  int? get age {
    final dob = dateOfBirth;
    if (dob == null) return null;
    final now = DateTime.now();
    var years = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      years--;
    }
    return years;
  }

  /// All fields needed for a BMR calculation are present (weight/height are
  /// checked separately, straight from HealthSample, by the repository).
  bool get isComplete => dateOfBirth != null && sex != null;
}

/// Local-first, per-device SharedPreferences storage (same pattern as
/// `ThemeModeController`) — required because BMR must work offline and in
/// local-only mode (no account). When signed in, edits are additionally
/// pushed to `/me` (best-effort) so other devices can pick them up, and a
/// device with no local value yet adopts whatever the server has.
class UserProfileController extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    _restoreAndReconcile();
    ref.listen(authControllerProvider, (previous, next) {
      final user = next.value;
      if (user != null) _reconcileWithServer(user);
    });
    return const UserProfile();
  }

  Future<void> _restoreAndReconcile() async {
    final prefs = await SharedPreferences.getInstance();
    final dobText = prefs.getString(_dobKey);
    final sexName = prefs.getString(_sexKey);
    state = UserProfile(
      dateOfBirth: dobText == null ? null : DateTime.parse(dobText),
      sex: sexName == null
          ? null
          : BiologicalSex.values.firstWhere(
              (s) => s.name == sexName,
              orElse: () => BiologicalSex.other,
            ),
    );
    final authUser = ref.read(authControllerProvider).value;
    if (authUser != null) await _reconcileWithServer(authUser);
  }

  /// A local value always wins — this only fills in fields this device
  /// hasn't set yet (fresh install, second device), so it can't clobber an
  /// offline edit that hasn't reached the server.
  Future<void> _reconcileWithServer(AuthUser authUser) async {
    if (state.dateOfBirth == null && authUser.dateOfBirth != null) {
      await setDateOfBirth(authUser.dateOfBirth, push: false);
    }
    if (state.sex == null && authUser.biologicalSex != null) {
      final sex = BiologicalSex.values.firstWhere(
        (s) => s.name == authUser.biologicalSex,
        orElse: () => BiologicalSex.other,
      );
      await setSex(sex, push: false);
    }
    await retryPendingUpload();
  }

  Future<void> setDateOfBirth(DateTime? value, {bool push = true}) async {
    state = UserProfile(dateOfBirth: value, sex: state.sex);
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_dobKey);
    } else {
      await prefs.setString(_dobKey, value.toIso8601String());
    }
    if (push) {
      await _pushToServer({
        'date_of_birth': value == null
            ? null
            : DateFormat('yyyy-MM-dd').format(value),
      });
    }
  }

  Future<void> setSex(BiologicalSex? value, {bool push = true}) async {
    state = UserProfile(dateOfBirth: state.dateOfBirth, sex: value);
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_sexKey);
    } else {
      await prefs.setString(_sexKey, value.name);
    }
    if (push) {
      await _pushToServer({'biological_sex': value?.name ?? ''});
    }
  }

  Future<void> retryPendingUpload() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_dirtyKey) != true ||
        ref.read(authControllerProvider).value == null) {
      return;
    }
    await _pushToServer({
      'date_of_birth': state.dateOfBirth == null
          ? null
          : DateFormat('yyyy-MM-dd').format(state.dateOfBirth!),
      'biological_sex': state.sex?.name ?? '',
    });
  }

  Future<void> _pushToServer(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    if (ref.read(authControllerProvider).value == null) {
      await prefs.setBool(_dirtyKey, true);
      return;
    }
    try {
      await ref.read(dioProvider).patch('/api/accounts/users/me/', data: data);
      await prefs.remove(_dirtyKey);
    } catch (_) {
      await prefs.setBool(_dirtyKey, true);
    }
  }
}

final userProfileProvider =
    NotifierProvider<UserProfileController, UserProfile>(
      UserProfileController.new,
    );
