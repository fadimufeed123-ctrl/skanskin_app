import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../storage/auth_storage.dart';
import 'auth_interceptor.dart';

/// Builds and configures the single shared [Dio] instance for the app.
///
/// UI and repositories never construct their own Dio clients — they receive
/// this one through Riverpod so base URL, headers, auth and error handling stay
/// centralized.
class DioClient {
  static Dio create({
    required AuthStorage storage,
    required Future<void> Function() onUnauthorized,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        // Let the app layer translate non-2xx into ApiException.
        validateStatus: (status) =>
            status != null && status >= 200 && status < 300,
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(storage, onUnauthorized: onUnauthorized),
    );

    if (kDebugMode && AppConfig.enableNetworkLogging) {
      dio.interceptors.add(_RedactingLogInterceptor());
    }

    return dio;
  }
}

/// Lightweight request/response logger that never prints the Authorization
/// header or password fields.
class _RedactingLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('→ ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '✕ ${err.response?.statusCode ?? '-'} ${err.requestOptions.uri} :: ${err.type.name}',
    );
    handler.next(err);
  }
}
