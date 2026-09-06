import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skanskin_app/app/providers.dart';
import 'package:skanskin_app/features/patients/data/models/patient.dart';

/// The signed-in patient's account profile, fetched from the backend for the
/// personal-info screen.
final patientProfileProvider = FutureProvider.autoDispose<Patient>((ref) {
  final session = ref.watch(authControllerProvider).session;
  if (session == null) {
    throw StateError('No active session');
  }
  return ref.watch(patientsRepositoryProvider).byId(session.patientId);
});
