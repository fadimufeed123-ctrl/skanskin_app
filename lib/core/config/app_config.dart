/// Centralized, build-time configurable application settings.
///
/// The API host can be overridden at build/run time without touching code:
///   flutter run --dart-define=API_HOST=http://192.168.1.20:5093
///
/// Defaults target the ScanSkin backend as it runs in development
/// (`http://localhost:5093`). On the Android emulator the host machine's
/// `localhost` is reached through the special alias `10.0.2.2`, which is why
/// that is the default here. For a physical device, pass your machine's LAN IP
/// via the `API_HOST` define.
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
