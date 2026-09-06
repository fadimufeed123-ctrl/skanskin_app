import 'package:dio/dio.dart';
import 'package:skanskin_app/core/network/api_exception.dart';

/// Runs a data-layer [call] and guarantees any failure surfaces as an
/// [ApiException] with a friendly, user-safe message — never a raw
/// [DioException] or stack trace.
Future<T> runApi<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on ApiException {
    rethrow;
  } on DioException catch (e) {
    throw ApiException.fromDio(e);
  } catch (_) {
    throw ApiException.unexpected();
  }
}

/// Coerces a decoded JSON array into a typed list of models, skipping any
/// element that is not a JSON object.
List<T> mapJsonList<T>(
  dynamic data,
  T Function(Map<String, dynamic>) fromJson,
) {
  if (data is! List) return <T>[];
  return data
      .whereType<Map>()
      .map((e) => fromJson(e.cast<String, dynamic>()))
      .toList(growable: false);
}
