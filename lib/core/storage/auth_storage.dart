import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persisted authentication session.
class AuthSession {
  const AuthSession({
    required this.token,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    required this.expiresAt,
  });

  final String token;
  final int userId;
  final String fullName;
  final String email;
  final String role;
  final DateTime expiresAt;

  /// For a Patient (TPT inheritance) the User id equals the Patient id.
  int get patientId => userId;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  AuthSession copyWith({String? fullName, String? email}) => AuthSession(
    token: token,
    userId: userId,
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    role: role,
    expiresAt: expiresAt,
  );
}

/// Wraps [FlutterSecureStorage] to persist the JWT and minimal user profile
/// needed to restore a session. Uses encrypted shared preferences on Android.
class AuthStorage {
  AuthStorage([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          );

  final FlutterSecureStorage _storage;

  static const _kToken = 'auth_token';
  static const _kUserId = 'auth_user_id';
  static const _kFullName = 'auth_full_name';
  static const _kEmail = 'auth_email';
  static const _kRole = 'auth_role';
  static const _kExpiresAt = 'auth_expires_at';
  static const _kOnboardingSeen = 'onboarding_seen';

  Future<void> save(AuthSession session) async {
    await Future.wait([
      _storage.write(key: _kToken, value: session.token),
      _storage.write(key: _kUserId, value: session.userId.toString()),
      _storage.write(key: _kFullName, value: session.fullName),
      _storage.write(key: _kEmail, value: session.email),
      _storage.write(key: _kRole, value: session.role),
      _storage.write(
        key: _kExpiresAt,
        value: session.expiresAt.toIso8601String(),
      ),
    ]);
  }

  Future<AuthSession?> read() async {
    final token = await _storage.read(key: _kToken);
    final userIdRaw = await _storage.read(key: _kUserId);
    if (token == null || token.isEmpty || userIdRaw == null) return null;

    final expiresRaw = await _storage.read(key: _kExpiresAt);
    return AuthSession(
      token: token,
      userId: int.tryParse(userIdRaw) ?? 0,
      fullName: await _storage.read(key: _kFullName) ?? '',
      email: await _storage.read(key: _kEmail) ?? '',
      role: await _storage.read(key: _kRole) ?? 'Patient',
      expiresAt: DateTime.tryParse(expiresRaw ?? '') ?? DateTime.now(),
    );
  }

  /// Returns the raw token without deserializing the whole session — used by
  /// the auth interceptor on every request.
  Future<String?> readToken() => _storage.read(key: _kToken);

  /// Whether the user has completed the one-time onboarding. This flag is
  /// deliberately preserved across [clear] (logout) so returning users are not
  /// shown onboarding again.
  Future<bool> readOnboardingSeen() async =>
      (await _storage.read(key: _kOnboardingSeen)) == 'true';

  Future<void> setOnboardingSeen() =>
      _storage.write(key: _kOnboardingSeen, value: 'true');

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _kToken),
      _storage.delete(key: _kUserId),
      _storage.delete(key: _kFullName),
      _storage.delete(key: _kEmail),
      _storage.delete(key: _kRole),
      _storage.delete(key: _kExpiresAt),
    ]);
  }
}
