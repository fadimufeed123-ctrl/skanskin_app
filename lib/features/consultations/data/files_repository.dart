import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:skanskin_app/core/network/api_runner.dart';
import 'package:skanskin_app/core/utils/json_utils.dart';

/// Uploads consultation images to the backend's file store.
class FilesRepository {
  FilesRepository(this._dio);

  final Dio _dio;

  /// `POST /Files/upload` (multipart) → an opaque private storage reference,
  /// which is attached to the consultation as its `imagePath`.
  ///
  /// Flutter Web's image picker exposes the selected image through a blob URL,
  /// not a real file-system path. Reading that URL as a native [File] causes
  /// an unsupported-operation error. On web we therefore fetch the blob bytes
  /// and build the multipart body from memory; native platforms keep using the
  /// real file path.
  Future<String> uploadImage(File file) {
    return runApi(() async {
      final MultipartFile multipart;

      if (kIsWeb) {
        final sourceResponse = await Dio().get<List<int>>(
          file.path,
          options: Options(responseType: ResponseType.bytes),
        );
        final rawBytes = sourceResponse.data;
        if (rawBytes == null || rawBytes.isEmpty) {
          throw StateError('The selected image was empty.');
        }

        final bytes = Uint8List.fromList(rawBytes);
        final info = _webImageInfo(
          sourceResponse.headers.value(Headers.contentTypeHeader),
          bytes,
        );

        multipart = MultipartFile.fromBytes(
          bytes,
          filename: 'upload${info.extension}',
          contentType: info.contentType,
        );
      } else {
        final fileName = file.uri.pathSegments.isNotEmpty
            ? file.uri.pathSegments.last
            : 'upload.jpg';
        multipart = await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: _contentTypeFor(fileName),
        );
      }

      final formData = FormData.fromMap({'file': multipart});
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
      '.heic' => DioMediaType('image', 'heic'),
      '.heif' => DioMediaType('image', 'heif'),
      _ => DioMediaType('application', 'octet-stream'),
    };
  }

  static _WebImageInfo _webImageInfo(
    String? declaredContentType,
    Uint8List bytes,
  ) {
    final type = declaredContentType?.split(';').first.trim().toLowerCase();

    switch (type) {
      case 'image/jpeg':
      case 'image/jpg':
      case 'image/pjpeg':
        return _WebImageInfo('.jpg', DioMediaType('image', 'jpeg'));
      case 'image/png':
        return _WebImageInfo('.png', DioMediaType('image', 'png'));
      case 'image/webp':
        return _WebImageInfo('.webp', DioMediaType('image', 'webp'));
      case 'image/gif':
        return _WebImageInfo('.gif', DioMediaType('image', 'gif'));
      case 'image/heic':
      case 'image/heic-sequence':
        return _WebImageInfo('.heic', DioMediaType('image', 'heic'));
      case 'image/heif':
      case 'image/heif-sequence':
        return _WebImageInfo('.heif', DioMediaType('image', 'heif'));
    }

    if (_hasPrefix(bytes, const [0xff, 0xd8, 0xff])) {
      return _WebImageInfo('.jpg', DioMediaType('image', 'jpeg'));
    }
    if (_hasPrefix(
      bytes,
      const [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a],
    )) {
      return _WebImageInfo('.png', DioMediaType('image', 'png'));
    }
    if (bytes.length >= 12 &&
        _matchesAt(bytes, 0, const [0x52, 0x49, 0x46, 0x46]) &&
        _matchesAt(bytes, 8, const [0x57, 0x45, 0x42, 0x50])) {
      return _WebImageInfo('.webp', DioMediaType('image', 'webp'));
    }
    if (bytes.length >= 6 &&
        (_matchesAt(
              bytes,
              0,
              const [0x47, 0x49, 0x46, 0x38, 0x37, 0x61],
            ) ||
            _matchesAt(
              bytes,
              0,
              const [0x47, 0x49, 0x46, 0x38, 0x39, 0x61],
            ))) {
      return _WebImageInfo('.gif', DioMediaType('image', 'gif'));
    }
    if (bytes.length >= 12 &&
        _matchesAt(bytes, 4, const [0x66, 0x74, 0x79, 0x70])) {
      final brand = String.fromCharCodes(bytes.sublist(8, 12));
      const heicBrands = {'heic', 'heix', 'hevc', 'hevx', 'heim', 'heis'};
      if (heicBrands.contains(brand)) {
        return _WebImageInfo('.heic', DioMediaType('image', 'heic'));
      }
      if (brand == 'mif1' || brand == 'msf1') {
        return _WebImageInfo('.heif', DioMediaType('image', 'heif'));
      }
    }

    throw StateError('Unsupported image format.');
  }

  static bool _hasPrefix(Uint8List bytes, List<int> signature) =>
      _matchesAt(bytes, 0, signature);

  static bool _matchesAt(Uint8List bytes, int offset, List<int> signature) {
    if (bytes.length < offset + signature.length) return false;
    for (var i = 0; i < signature.length; i++) {
      if (bytes[offset + i] != signature[i]) return false;
    }
    return true;
  }
}

class _WebImageInfo {
  const _WebImageInfo(this.extension, this.contentType);

  final String extension;
  final DioMediaType contentType;
}
