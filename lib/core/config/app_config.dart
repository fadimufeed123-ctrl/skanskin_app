/// Centralized, build-time configurable application settings.
///
/// The API host can be overridden at build/run time without touching code:
///   flutter run --dart-define=API_HOST=http://192.168.1.20:5093
///
/// Keep the default aligned with the development host that was already working
/// for this project before the consultation reliability fixes. Android emulator
/// or physical-device hosts can still be supplied explicitly through API_HOST.
class AppConfig {
  AppConfig._();

  /// Root host of the backend (no `/api` suffix, no trailing slash).
  static const String host = String.fromEnvironment(
    'API_HOST',
    defaultValue: 'https://localhost:7250',
  );

  /// Base URL for all REST calls.
  static String get apiBaseUrl => '$host/api';

  /// Resolves public profile media returned by the API into an absolute URL.
  /// Medical consultation images deliberately do not use this helper.
  static String resolveMediaUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return path.startsWith('/') ? '$host$path' : '$host/$path';
  }

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Enables verbose Dio request/response logging (never logs auth secrets).
  static const bool enableNetworkLogging = true;
}
