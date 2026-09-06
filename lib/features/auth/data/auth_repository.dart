import 'package:dio/dio.dart';
import 'package:skanskin_app/core/network/api_runner.dart';
import 'package:skanskin_app/core/storage/auth_storage.dart';
import 'package:skanskin_app/core/utils/json_utils.dart';

/// Talks to the backend authentication and patient-registration endpoints.
///
/// Registration and login are two distinct backend calls: creating a patient
/// (`POST /Patients`) does not return a token, so after a successful signup the
/// caller authenticates through [login] to obtain the JWT session.
class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  /// `POST /Auth/login` → JWT session for the authenticated user.
  Future<AuthSession> login({required String email, required String password}) {
    return runApi(() async {
      final res = await _dio.post(
        '/Auth/login',
        data: {'email': email, 'password': password},
      );
      final data = (res.data as Map).cast<String, dynamic>();
      return AuthSession(
        token: J.asString(data['token']),
        userId: J.asInt(data['userId']),
        fullName: J.asString(data['fullName']),
        email: J.asString(data['email']),
        role: J.asString(data['role']),
        expiresAt: J.asDate(data['expiresAt']),
      );
    });
  }

  /// `POST /Patients` → creates the patient account. The backend hashes the
  /// plain password it receives in the `password` field before persisting it.
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) {
    return runApi(() async {
      await _dio.post(
        '/Patients',
        data: {'fullName': fullName, 'email': email, 'password': password},
      );
    });
  }
}
