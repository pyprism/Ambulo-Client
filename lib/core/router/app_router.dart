import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_controller.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/server_setup_screen.dart';
import '../../features/charts/charts_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/diagnostics/diagnostics_screen.dart';
import '../../features/fitness/activity_detail_screen.dart';
import '../../features/fitness/fitness_screen.dart';
import '../../features/friends/friends_screen.dart';
import '../../features/friends/notifications_screen.dart';
import '../../features/import_export/import_export_screen.dart';
import '../../features/map/map_screen.dart';
import '../../features/notes/notes_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/places/places_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/sync/conflicts_screen.dart';
import '../../features/timeline/timeline_screen.dart';
import '../../features/timeline/trip_detail_screen.dart';
import '../../features/workouts/workouts_screen.dart';
import '../../shared/widgets/adaptive_nav_shell.dart';
import 'onboarding_status_controller.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

const _navDestinations = [
  NavDestinationSpec(
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
    label: 'Dashboard',
  ),
  NavDestinationSpec(
    icon: Icons.timeline_outlined,
    selectedIcon: Icons.timeline,
    label: 'Timeline',
  ),
  NavDestinationSpec(
    icon: Icons.map_outlined,
    selectedIcon: Icons.map,
    label: 'Map',
  ),
  NavDestinationSpec(
    icon: Icons.directions_walk_outlined,
    selectedIcon: Icons.directions_walk,
    label: 'Fitness',
  ),
  NavDestinationSpec(
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    label: 'Settings',
  ),
];

const _authRoutes = {'/login', '/register', '/server-setup'};

/// Bridges Riverpod state changes into GoRouter's redirect re-evaluation
/// without recreating the GoRouter (and its navigator stack) on every change.
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
    ref.listen(onboardingStatusProvider, (_, _) => notifyListeners());
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: kIsWeb ? '/login' : '/onboarding',
    refreshListenable: _RouterRefreshNotifier(ref),
    redirect: (context, state) {
      final loc = state.matchedLocation;

      // Web: login/register is always the gate.
      if (kIsWeb) {
        final isAuthenticated = ref.read(authControllerProvider).value != null;
        if (!isAuthenticated) {
          return _authRoutes.contains(loc) ? null : '/login';
        }
        if (loc == '/login' || loc == '/register') return '/dashboard';
        return null;
      }

      // Mobile: onboarding gates first launch; local-only mode is allowed,
      // so auth routes are only reachable by explicit navigation from
      // Settings, never forced.
      final onboardingDone = ref.read(onboardingStatusProvider).value ?? false;
      final atOnboarding = loc == '/onboarding';
      if (!onboardingDone && !atOnboarding) return '/onboarding';
      if (onboardingDone && atOnboarding) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) =>
            OnboardingScreen(onDone: () => context.go('/dashboard')),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            LoginScreen(onAuthenticated: () => context.go('/dashboard')),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) =>
            RegisterScreen(onAuthenticated: () => context.go('/dashboard')),
      ),
      GoRoute(
        path: '/server-setup',
        builder: (context, state) => const ServerSetupScreen(),
      ),
      GoRoute(
        path: '/sync-conflicts',
        builder: (context, state) => const ConflictsScreen(),
      ),
      GoRoute(
        path: '/charts',
        builder: (context, state) => const ChartsScreen(),
      ),
      GoRoute(
        path: '/places',
        builder: (context, state) => const PlacesScreen(),
      ),
      GoRoute(
        path: '/trips/:id',
        builder: (context, state) =>
            TripDetailScreen(tripId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/activities/:id',
        builder: (context, state) =>
            ActivityDetailScreen(activityId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/import-export',
        builder: (context, state) => const ImportExportScreen(),
      ),
      GoRoute(
        path: '/friends',
        builder: (context, state) => const FriendsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/diagnostics',
        builder: (context, state) => const DiagnosticsScreen(),
      ),
      GoRoute(
        path: '/workouts',
        builder: (context, state) => const WorkoutsScreen(),
      ),
      GoRoute(path: '/notes', builder: (context, state) => const NotesScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdaptiveNavShell(
            destinations: _navDestinations,
            currentIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            ),
            body: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/timeline',
                builder: (context, state) => const TimelineScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                builder: (context, state) => const MapScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/fitness',
                builder: (context, state) => const FitnessScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

extension AmbuloNavigation on BuildContext {
  void pushServerSetup() => push('/server-setup');
  void pushRegister() => push('/register');
}
