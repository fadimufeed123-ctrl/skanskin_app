import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:skanskin_app/core/network/api_runner.dart';
import 'package:skanskin_app/core/utils/json_utils.dart';

/// Uploads consultation images to the backend's file store.
class FilesRepository {
  FilesRepository(this._dio);

  final Dio _dio;

  /// `POST /Files/upload` (multipart) → an opaque private storage reference,
  /// which is attached to the consultation as its `imagePath`.
  Future<String> uploadImage(File file) {
    return runApi(() async {
      final fileName = file.uri.pathSegments.isNotEmpty
          ? file.uri.pathSegments.last
          : 'upload.jpg';
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: _contentTypeFor(fileName),
        ),
      });
      final res = await _dio.post(
        '/Files/upload',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final data = (res.data as Map).cast<String, dynamic>();
      return J.asString(data['reference']);
    });
  }

  /// Fetches a consultation image through the ownership-protected endpoint.
  /// Dio's auth interceptor supplies the bearer token. Bytes remain in memory
  /// and are never handed to a persistent image cache.
  Future<Uint8List> getConsultationImage(int consultationId) {
    return runApi(() async {
      final res = await _dio.get<List<int>>(
        '/Files/consultations/$consultationId/image',
        options: Options(
          responseType: ResponseType.bytes,
          headers: const {'Cache-Control': 'no-store', 'Pragma': 'no-cache'},
        ),
      );

      final bytes = res.data;
      if (bytes == null || bytes.isEmpty) {
        throw StateError('The medical image response was empty.');
      }

      return Uint8List.fromList(bytes);
    });
  }

  static DioMediaType _contentTypeFor(String fileName) {
    final extension = fileName.contains('.')
        ? fileName.substring(fileName.lastIndexOf('.')).toLowerCase()
        : '';

    return switch (extension) {
      '.jpg' || '.jpeg' => DioMediaType('image', 'jpeg'),
      '.png' => DioMediaType('image', 'png'),
      '.webp' => DioMediaType('image', 'webp'),
      '.gif' => DioMediaType('image', 'gif'),
      _ => DioMediaType('application', 'octet-stream'),
    };
  }
}
