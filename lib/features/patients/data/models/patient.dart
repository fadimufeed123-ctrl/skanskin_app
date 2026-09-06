import 'package:skanskin_app/core/utils/json_utils.dart';

/// The signed-in patient's account profile. Mirrors the backend `PatientDto`.
class Patient {
  const Patient({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  final int id;
  final String fullName;
  final String email;
  final String role;
  final DateTime createdAt;

  /// First letter of the given name, for the avatar monogram.
  String get monogram {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return '؟';
    return trimmed.substring(0, 1);
  }

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
    id: J.asInt(json['id']),
    fullName: J.asString(json['fullName']),
    email: J.asString(json['email']),
    role: J.asString(json['role']),
    createdAt: J.asDate(json['createdAt']),
  );
}
