import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skanskin_app/app/providers.dart';
import 'package:skanskin_app/features/doctors/data/models/doctor.dart';

/// Doctors currently available to receive a new consultation — used by the
/// create-consultation wizard's first step and the home preview.
final availableDoctorsProvider = FutureProvider.autoDispose<List<Doctor>>((
  ref,
) {
  return ref.watch(doctorsRepositoryProvider).available();
});

/// The full dermatologist directory, used by the create-consultation wizard so
/// the patient can browse every doctor (each row shows its availability).
final allDoctorsProvider = FutureProvider.autoDispose<List<Doctor>>((ref) {
  return ref.watch(doctorsRepositoryProvider).all();
});

/// A single doctor's profile, by id.
final doctorByIdProvider = FutureProvider.autoDispose.family<Doctor, int>((
  ref,
  id,
) {
  return ref.watch(doctorsRepositoryProvider).byId(id);
});
