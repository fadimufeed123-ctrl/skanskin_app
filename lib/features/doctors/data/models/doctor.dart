import 'package:skanskin_app/core/utils/json_utils.dart';

/// A dermatologist the patient can browse and select for a consultation.
/// Mirrors the backend `DoctorDto`.
class Doctor {
  const Doctor({
    required this.id,
    required this.fullName,
    required this.email,
    required this.specialization,
    required this.biography,
    required this.imageUrl,
    required this.yearsOfExperience,
    required this.phone,
    required this.isAvailable,
  });

  final int id;
  final String fullName;
  final String email;
  final String specialization;
  final String biography;
  final String imageUrl;
  final int yearsOfExperience;
  final String phone;
  final bool isAvailable;

  /// First letter of the given name, for the avatar monogram fallback.
  String get monogram {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return '؟';
    // Skip an honorific prefix like "د." so we show the actual name initial.
    final parts = trimmed.split(RegExp(r'\s+'));
    final namePart = parts.length > 1 && parts.first.contains('.')
        ? parts[1]
        : parts.first;
    return namePart.isNotEmpty
        ? namePart.substring(0, 1)
        : trimmed.substring(0, 1);
  }

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
    id: J.asInt(json['id']),
    fullName: J.asString(json['fullName']),
    email: J.asString(json['email']),
    specialization: J.asString(json['specialization']),
    biography: J.asString(json['biography']),
    imageUrl: J.asString(json['imageUrl']),
    yearsOfExperience: J.asInt(json['yearsOfExperience']),
    phone: J.asString(json['phone']),
    isAvailable: J.asBool(json['isAvailable'], true),
  );
}
