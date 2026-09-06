import 'package:skanskin_app/core/utils/json_utils.dart';
import 'package:skanskin_app/features/consultations/data/models/consultation_status.dart';
import 'package:skanskin_app/features/consultations/data/models/diagnosis.dart';

/// A consultation as it appears in the patient's list view.
/// Mirrors the backend `ConsultationListDto` (no image, no diagnosis).
class ConsultationSummary {
  const ConsultationSummary({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.symptoms,
    required this.status,
    required this.createdAt,
    this.doctorName,
  });

  final int id;
  final int patientId;
  final int doctorId;
  final String symptoms;
  final ConsultationStatus status;
  final DateTime createdAt;
  final String? doctorName;

  factory ConsultationSummary.fromJson(Map<String, dynamic> json) =>
      ConsultationSummary(
        id: J.asInt(json['id']),
        patientId: J.asInt(json['patientId']),
        doctorId: J.asInt(json['doctorId']),
        symptoms: J.asString(json['symptoms']),
        status: ConsultationStatus.fromApi(J.asStringOrNull(json['status'])),
        createdAt: J.asDate(json['createdAt']),
        doctorName: J.asStringOrNull(json['doctorName']),
      );
}

/// A consultation with its full detail, including the doctor's diagnosis when
/// one has been authored. Mirrors the backend `ConsultationDto`.
class Consultation {
  const Consultation({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.imagePath,
    required this.symptoms,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.doctorName,
    this.diagnosis,
  });

  final int id;
  final int patientId;
  final int doctorId;
  final String imagePath;
  final String symptoms;
  final ConsultationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? doctorName;
  final Diagnosis? diagnosis;

  bool get hasImage => imagePath.trim().isNotEmpty;

  factory Consultation.fromJson(Map<String, dynamic> json) {
    final diagnosisJson = json['diagnosis'];
    return Consultation(
      id: J.asInt(json['id']),
      patientId: J.asInt(json['patientId']),
      doctorId: J.asInt(json['doctorId']),
      imagePath: J.asString(json['imagePath']),
      symptoms: J.asString(json['symptoms']),
      status: ConsultationStatus.fromApi(J.asStringOrNull(json['status'])),
      createdAt: J.asDate(json['createdAt']),
      updatedAt: J.asDate(json['updatedAt']),
      doctorName: J.asStringOrNull(json['doctorName']),
      diagnosis: diagnosisJson is Map<String, dynamic>
          ? Diagnosis.fromJson(diagnosisJson)
          : null,
    );
  }
}
