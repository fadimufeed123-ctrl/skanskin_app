import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skanskin_app/core/network/dio_client.dart';
import 'package:skanskin_app/core/storage/auth_storage.dart';
import 'package:skanskin_app/features/auth/data/auth_repository.dart';
import 'package:skanskin_app/features/auth/state/auth_controller.dart';
import 'package:skanskin_app/features/consultations/data/consultations_repository.dart';
import 'package:skanskin_app/features/consultations/data/files_repository.dart';
import 'package:skanskin_app/features/doctors/data/doctors_repository.dart';
import 'package:skanskin_app/features/patients/data/patients_repository.dart';

/// Infrastructure and repository wiring. Everything that touches the network
/// flows through the single [dioProvider] so configuration, auth and error
/// handling stay centralized.
///
/// Explicit variable types are given below to break the (lazy, runtime-safe)
/// reference cycle between [dioProvider] and [authControllerProvider] that the
/// analyzer's type inference would otherwise reject.

final Provider<AuthStorage> authStorageProvider = Provider<AuthStorage>(
  (ref) => AuthStorage(),
);

final Provider<Dio> dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(authStorageProvider);
  return DioClient.create(
    storage: storage,
    // Resolved lazily at call time, so there is no construction-time cycle
    // between the Dio client and the auth controller.
    onUnauthorized: () =>
        ref.read(authControllerProvider.notifier).handleUnauthorized(),
  );
});

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository(ref.watch(dioProvider)));

final Provider<DoctorsRepository> doctorsRepositoryProvider =
    Provider<DoctorsRepository>(
      (ref) => DoctorsRepository(ref.watch(dioProvider)),
    );

final Provider<ConsultationsRepository> consultationsRepositoryProvider =
    Provider<ConsultationsRepository>(
      (ref) => ConsultationsRepository(ref.watch(dioProvider)),
    );

final Provider<FilesRepository> filesRepositoryProvider =
    Provider<FilesRepository>((ref) => FilesRepository(ref.watch(dioProvider)));

final Provider<PatientsRepository> patientsRepositoryProvider =
    Provider<PatientsRepository>(
      (ref) => PatientsRepository(ref.watch(dioProvider)),
    );

final StateNotifierProvider<AuthController, AuthState> authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
      return AuthController(
        ref.watch(authRepositoryProvider),
        ref.watch(authStorageProvider),
      );
    });
