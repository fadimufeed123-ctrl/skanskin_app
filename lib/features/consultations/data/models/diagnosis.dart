import 'package:skanskin_app/core/utils/json_utils.dart';

/// A doctor-authored diagnosis for a consultation. Read-only for the patient.
/// Mirrors the backend `DiagnosisDto`.
class Diagnosis {
  const Diagnosis({
    required this.id,
    required this.consultationId,
    required this.doctorId,
    required this.diseaseName,
    required this.prescription,
    required this.createdAt,
    this.doctorName,
  });

  final int id;
  final int consultationId;
  final int doctorId;
  final String diseaseName;
  final String prescription;
  final DateTime createdAt;
  final String? doctorName;

  factory Diagnosis.fromJson(Map<String, dynamic> json) => Diagnosis(
    id: J.asInt(json['id']),
    consultationId: J.asInt(json['consultationId']),
    doctorId: J.asInt(json['doctorId']),
    diseaseName: J.asString(json['diseaseName']),
    prescription: J.asString(json['prescription']),
    createdAt: J.asDate(json['createdAt']),
    doctorName: J.asStringOrNull(json['doctorName']),
  );
}
