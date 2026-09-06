import 'package:dio/dio.dart';
import 'package:skanskin_app/core/network/api_runner.dart';
import 'package:skanskin_app/features/doctors/data/models/doctor.dart';

/// Reads the dermatologist directory the patient chooses from.
class DoctorsRepository {
  DoctorsRepository(this._dio);

  final Dio _dio;

  /// `GET /Doctors/available` → doctors currently accepting consultations.
  Future<List<Doctor>> available() {
    return runApi(() async {
      final res = await _dio.get('/Doctors/available');
      return mapJsonList(res.data, Doctor.fromJson);
    });
  }

  /// `GET /Doctors` → the full directory.
  Future<List<Doctor>> all() {
    return runApi(() async {
      final res = await _dio.get('/Doctors');
      return mapJsonList(res.data, Doctor.fromJson);
    });
  }

  /// `GET /Doctors/{id}` → a single doctor's profile.
  Future<Doctor> byId(int id) {
    return runApi(() async {
      final res = await _dio.get('/Doctors/$id');
      return Doctor.fromJson((res.data as Map).cast<String, dynamic>());
    });
  }
}
