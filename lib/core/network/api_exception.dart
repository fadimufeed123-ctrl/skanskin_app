import 'package:dio/dio.dart';

/// Kinds of failures the UI may need to react to differently.
enum ApiErrorType {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  validation,
  server,
  unknown,
}

/// A normalized, user-safe error translated from a [DioException] or any other
/// failure in the data layer. Carries a friendly Arabic [message] plus optional
/// per-field validation errors extracted from the backend's `errors` payload.
///
/// Raw exceptions, stack traces and technical detail are never surfaced to the
/// end user through [message].
class ApiException implements Exception {
  const ApiException({
    required this.type,
    required this.message,
    this.statusCode,
    this.fieldErrors = const {},
  });

  final ApiErrorType type;
  final String message;
  final int? statusCode;
  final Map<String, String> fieldErrors;

  bool get isUnauthorized => type == ApiErrorType.unauthorized;

  factory ApiException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const ApiException(
          type: ApiErrorType.timeout,
          message:
              'انتهت مهلة الاتصال. تحقق من اتصالك بالإنترنت وحاول مرة أخرى.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          type: ApiErrorType.network,
          message: 'تعذّر الاتصال بالخادم. تأكد من اتصالك بالإنترنت.',
        );
      case DioExceptionType.badCertificate:
        return const ApiException(
          type: ApiErrorType.network,
          message: 'تعذّر التحقق من أمان الاتصال بالخادم.',
        );
      case DioExceptionType.cancel:
        return const ApiException(
          type: ApiErrorType.unknown,
          message: 'تم إلغاء الطلب.',
        );
      case DioExceptionType.badResponse:
        return _fromResponse(e.response);
      case DioExceptionType.unknown:
        return const ApiException(
          type: ApiErrorType.network,
          message: 'تعذّر الاتصال بالخادم. تأكد من اتصالك بالإنترنت.',
        );
    }
  }

  static ApiException _fromResponse(Response? response) {
    final int status = response?.statusCode ?? 0;
    final dynamic data = response?.data;

    final Map<String, String> fieldErrors = _extractFieldErrors(data);
    final String? serverMessage = _extractMessage(data);

    switch (status) {
      case 400:
      case 422:
        return ApiException(
          type: ApiErrorType.validation,
          statusCode: status,
          fieldErrors: fieldErrors,
          message: fieldErrors.isNotEmpty
              ? fieldErrors.values.first
              : (serverMessage ?? 'البيانات المُدخلة غير صحيحة.'),
        );
      case 401:
        return ApiException(
          type: ApiErrorType.unauthorized,
          statusCode: status,
          message:
              'انتهت الجلسة أو بيانات الدخول غير صحيحة. الرجاء تسجيل الدخول مجددًا.',
        );
      case 403:
        return ApiException(
          type: ApiErrorType.forbidden,
          statusCode: status,
          message: 'لا تملك صلاحية الوصول لهذا المحتوى.',
        );
      case 404:
        return ApiException(
          type: ApiErrorType.notFound,
          statusCode: status,
          message: serverMessage ?? 'العنصر المطلوب غير موجود.',
        );
      case 409:
        return ApiException(
          type: ApiErrorType.conflict,
          statusCode: status,
          message:
              serverMessage ??
              'يوجد تعارض في البيانات. قد يكون هذا العنصر مستخدمًا بالفعل.',
        );
      default:
        if (status >= 500) {
          return ApiException(
            type: ApiErrorType.server,
            statusCode: status,
            message: 'حدث خطأ في الخادم. الرجاء المحاولة لاحقًا.',
          );
        }
        return ApiException(
          type: ApiErrorType.unknown,
          statusCode: status,
          message:
              serverMessage ?? 'حدث خطأ غير متوقع. الرجاء المحاولة مرة أخرى.',
        );
    }
  }

  /// Parses the backend validation shape:
  /// `{ "errors": { "Email": ["...","..."], ... } }`.
  static Map<String, String> _extractFieldErrors(dynamic data) {
    if (data is! Map) return const {};
    final dynamic errors = data['errors'];
    if (errors is! Map) return const {};
    final result = <String, String>{};
    errors.forEach((key, value) {
      final String field = key.toString();
      if (value is List && value.isNotEmpty) {
        result[field] = value.first.toString();
      } else if (value is String) {
        result[field] = value;
      }
    });
    return result;
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map) {
      final dynamic msg = data['message'] ?? data['title'] ?? data['detail'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    return null;
  }

  /// Wraps any non-Dio error so the UI always receives an [ApiException].
  factory ApiException.unexpected([Object? error]) => const ApiException(
    type: ApiErrorType.unknown,
    message: 'حدث خطأ غير متوقع. الرجاء المحاولة مرة أخرى.',
  );

  @override
  String toString() => 'ApiException($type, $statusCode): $message';
}
