import 'package:dio/dio.dart';
import 'package:skanskin_app/core/network/api_runner.dart';
import 'package:skanskin_app/features/patients/data/models/patient.dart';

/// Reads the signed-in patient's account profile.
class PatientsRepository {
  PatientsRepository(this._dio);

  final Dio _dio;

  /// `GET /Patients/{id}` → the patient's profile.
  Future<Patient> byId(int id) {
    return runApi(() async {
      final res = await _dio.get('/Patients/$id');
      return Patient.fromJson((res.data as Map).cast<String, dynamic>());
    });
  }
}
