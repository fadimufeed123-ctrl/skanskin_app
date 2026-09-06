import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skanskin_app/app/main_shell.dart';
import 'package:skanskin_app/app/providers.dart';
import 'package:skanskin_app/app/routes.dart';
import 'package:skanskin_app/features/auth/presentation/login_screen.dart';
import 'package:skanskin_app/features/auth/presentation/register_screen.dart';
import 'package:skanskin_app/features/auth/state/auth_controller.dart';
import 'package:skanskin_app/features/consultations/presentation/consultation_detail_screen.dart';
import 'package:skanskin_app/features/consultations/presentation/consultations_screen.dart';
import 'package:skanskin_app/features/consultations/presentation/create_consultation_screen.dart';
import 'package:skanskin_app/features/home/presentation/home_screen.dart';
import 'package:skanskin_app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:skanskin_app/features/profile/presentation/personal_info_screen.dart';
import 'package:skanskin_app/features/profile/presentation/profile_screen.dart';
import 'package:skanskin_app/features/splash/presentation/splash_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// The app router. Access is gated by [authControllerProvider] via [redirect];
/// the router refreshes whenever auth state changes (login, logout, token
/// expiry) so the user is moved to the correct screen automatically.
final Provider<GoRouter> goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final loc = state.matchedLocation;

      // Session is still being restored — hold on the splash screen.
      if (auth.status == AuthStatus.unknown) {
        return loc == Routes.splash ? null : Routes.splash;
      }

      final loggedIn = auth.isAuthenticated;
      final atSplash = loc == Routes.splash;
      final atOnboarding = loc == Routes.onboarding;
      final atAuth = loc == Routes.login || loc == Routes.register;

      if (!loggedIn) {
        if (!auth.onboardingSeen) {
          return atOnboarding ? null : Routes.onboarding;
        }
        return atAuth ? null : Routes.login;
      }

      // Authenticated: keep the user out of the pre-auth flow.
      if (atSplash || atOnboarding || atAuth) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(path: Routes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: Routes.register,
        builder: (_, __) => const RegisterScreen(),
      ),

      // Bottom-nav shell: the three tabbed destinations.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (_, __) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.consultations,
                builder: (_, __) => const ConsultationsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (_, __) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Full-screen flows presented above the tab bar (root navigator).
      GoRoute(
        path: Routes.createConsultation,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const CreateConsultationScreen(),
      ),
      GoRoute(
        path: Routes.personalInfo,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const PersonalInfoScreen(),
      ),
      GoRoute(
        path: Routes.consultationDetail,
        parentNavigatorKey: _rootNavigatorKey,
        redirect: (_, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          return id == null || id <= 0 ? Routes.consultations : null;
        },
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ConsultationDetailScreen(id: id);
        },
      ),
    ],
  );
});

/// Bridges Riverpod's [authControllerProvider] to go_router's
/// [GoRouter.refreshListenable]: any change to auth state prompts the router to
/// re-run its redirect logic.
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Ref ref) {
    _sub = ref.listen<AuthState>(
      authControllerProvider,
      (_, __) => notifyListeners(),
      fireImmediately: false,
    );
  }

  late final ProviderSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
