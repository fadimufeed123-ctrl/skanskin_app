import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skanskin_app/core/network/api_exception.dart';
import 'package:skanskin_app/core/storage/auth_storage.dart';
import 'package:skanskin_app/features/auth/data/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// The single source of truth for the session, consumed by the router to gate
/// access. [status] starts as [AuthStatus.unknown] while the persisted session
/// is restored on launch (the splash screen is shown during this window).
class AuthState {
  const AuthState({
    required this.status,
    required this.onboardingSeen,
    this.session,
  });

  final AuthStatus status;
  final bool onboardingSeen;
  final AuthSession? session;

  static const initial = AuthState(
    status: AuthStatus.unknown,
    onboardingSeen: false,
  );

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && session != null;

  AuthState copyWith({
    AuthStatus? status,
    bool? onboardingSeen,
    AuthSession? session,
    bool clearSession = false,
  }) => AuthState(
    status: status ?? this.status,
    onboardingSeen: onboardingSeen ?? this.onboardingSeen,
    session: clearSession ? null : (session ?? this.session),
  );
}

/// Owns authentication: session restoration, login, registration, logout, and
/// reacting to a server-side token rejection. Login/registration submission
/// state is handled locally by the screens; this controller only tracks the
/// durable session used for routing.
class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repo, this._storage) : super(AuthState.initial) {
    _bootstrap();
  }

  final AuthRepository _repo;
  final AuthStorage _storage;

  Future<void> _bootstrap() async {
    var onboardingSeen = false;
    try {
      onboardingSeen = await _storage.readOnboardingSeen();
      final session = await _storage.read();

      if (session != null && !session.isExpired) {
        state = AuthState(
          status: AuthStatus.authenticated,
          onboardingSeen: onboardingSeen,
          session: session,
        );
      } else {
        if (session != null) await _storage.clear(); // expired
        state = AuthState(
          status: AuthStatus.unauthenticated,
          onboardingSeen: onboardingSeen,
        );
      }
    } catch (_) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        onboardingSeen: onboardingSeen,
      );
    }
  }

  /// Authenticates and persists the session. Throws [ApiException] on failure,
  /// which the login screen surfaces to the user.
  Future<void> login({required String email, required String password}) async {
    final session = await _repo.login(email: email, password: password);
    _ensurePatient(session);
    try {
      await _storage.save(session);
    } catch (_) {
      throw const ApiException(
        type: ApiErrorType.unknown,
        message: 'تعذّر حفظ جلسة الدخول. حاول مرة أخرى.',
      );
    }
    state = state.copyWith(status: AuthStatus.authenticated, session: session);
  }

  /// Creates a patient account then authenticates — registration itself does
  /// not return a token, so we immediately log in to obtain the JWT session.
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      await _repo.register(
        fullName: fullName,
        email: email,
        password: password,
      );
    } on ApiException catch (registrationError) {
      if (registrationError.type != ApiErrorType.conflict) rethrow;

      try {
        await login(email: email, password: password);
        return;
      } on ApiException catch (loginError) {
        if (loginError.type == ApiErrorType.unauthorized ||
            loginError.type == ApiErrorType.forbidden) {
          throw registrationError;
        }
        rethrow;
      }
    }

    await login(email: email, password: password);
  }

  /// This app is for patients only. A Doctor/Admin/Owner account is refused
  /// even though the backend would issue it a token, preserving the strict
  /// separation between the patient app and the staff dashboard.
  void _ensurePatient(AuthSession session) {
    if (session.role.toLowerCase() != 'patient') {
      throw const ApiException(
        type: ApiErrorType.forbidden,
        message: 'هذا التطبيق مخصص للمرضى فقط.',
      );
    }
  }

  Future<void> completeOnboarding() async {
    await _storage.setOnboardingSeen();
    state = state.copyWith(onboardingSeen: true);
  }

  Future<void> logout() async {
    await _storage.clear();
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      clearSession: true,
    );
  }

  /// Called by the Dio interceptor when the server rejects the token (401):
  /// the session is dropped and the router sends the user back to login.
  Future<void> handleUnauthorized() async {
    if (state.status == AuthStatus.unauthenticated) return;
    await _storage.clear();
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      clearSession: true,
    );
  }
}
