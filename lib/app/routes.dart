/// Centralized route paths and names for the app router.
///
/// Detail and create flows live at top-level paths (outside the bottom-nav
/// shell) so they present full-screen without the tab bar. The three shell
/// branches are the only tabbed destinations — there is deliberately no
/// notifications destination.
class Routes {
  Routes._();

  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';

  // Bottom-nav shell branches
  static const home = '/home';
  static const consultations = '/consultations';
  static const profile = '/profile';

  // Full-screen (outside shell)
  static const createConsultation = '/new-consultation';
  static const personalInfo = '/personal-info';

  /// Detail path template + builder.
  static const consultationDetail = '/consultation/:id';
  static String consultationDetailOf(int id) => '/consultation/$id';
}
