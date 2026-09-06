import 'package:dio/dio.dart';
import 'package:skanskin_app/core/network/api_runner.dart';
import 'package:skanskin_app/features/consultations/data/models/consultation.dart';
import 'package:skanskin_app/features/consultations/data/models/consultation_status.dart';

/// Reads and writes the patient's own consultations.
class ConsultationsRepository {
  ConsultationsRepository(this._dio);

  final Dio _dio;

  /// `GET /Consultations/by-patient/{patientId}` → the patient's consultations,
  /// newest first (ordering is applied server-side).
  Future<List<ConsultationSummary>> byPatient(int patientId) {
    return runApi(() async {
      final res = await _dio.get('/Consultations/by-patient/$patientId');
      return mapJsonList(res.data, ConsultationSummary.fromJson);
    });
  }

  /// `GET /Consultations/{id}` → full detail including the diagnosis, if any.
  Future<Consultation> byId(int id) {
    return runApi(() async {
      final res = await _dio.get('/Consultations/$id');
      return Consultation.fromJson((res.data as Map).cast<String, dynamic>());
    });
  }

  /// `POST /Consultations` → creates a new consultation and returns it.
  Future<Consultation> create({
    required int patientId,
    required int doctorId,
    required String imagePath,
    required String symptoms,
  }) {
    return runApi(() async {
      final res = await _dio.post(
        '/Consultations',
        data: {
          'patientId': patientId,
          'doctorId': doctorId,
          'imagePath': imagePath,
          'symptoms': symptoms,
        },
      );
      return Consultation.fromJson((res.data as Map).cast<String, dynamic>());
    });
  }

  /// `PATCH /Consultations/{id}/status` with `Cancelled` — the patient cancels
  /// a consultation that has not yet been diagnosed.
  Future<Consultation> cancel(int id) {
    return runApi(() async {
      final res = await _dio.patch(
        '/Consultations/$id/status',
        data: {'status': ConsultationStatus.cancelled.apiValue},
      );
      return Consultation.fromJson((res.data as Map).cast<String, dynamic>());
    });
  }
}
