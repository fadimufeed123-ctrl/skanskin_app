import 'package:dio/dio.dart';
import '../storage/auth_storage.dart';

/// Attaches the bearer token to every outgoing request and detects expired /
/// invalid sessions (HTTP 401) so the app can force a re-login.
///
/// The [onUnauthorized] callback fires at most once per session teardown and is
/// skipped for the login/registration endpoints (a 401 there is a credential
/// error, not an expired session).
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, {required this.onUnauthorized});

  final AuthStorage _storage;
  final Future<void> Function() onUnauthorized;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final path = err.requestOptions.path;
    final bool isAuthEndpoint =
        path.contains('/Auth/login') || path.endsWith('/Patients');

    if (status == 401 && !isAuthEndpoint) {
      await onUnauthorized();
    }
    handler.next(err);
  }
}
