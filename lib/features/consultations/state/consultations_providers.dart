import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skanskin_app/app/providers.dart';
import 'package:skanskin_app/features/consultations/data/models/consultation.dart';
import 'package:skanskin_app/features/consultations/data/models/consultation_status.dart';

/// The signed-in patient's consultations, newest first. Returns an empty list
/// if there is somehow no active session (the router prevents this in practice).
final consultationsListProvider =
    FutureProvider.autoDispose<List<ConsultationSummary>>((ref) {
      final session = ref.watch(authControllerProvider).session;
      if (session == null) return <ConsultationSummary>[];
      return ref
          .watch(consultationsRepositoryProvider)
          .byPatient(session.patientId);
    });

/// The currently selected status filter chip on the consultations list.
/// `null` means "الكل" (all).
final consultationFilterProvider =
    StateProvider.autoDispose<ConsultationStatus?>((ref) => null);

/// Full detail (including diagnosis) for a single consultation, by id.
final consultationDetailProvider = FutureProvider.autoDispose
    .family<Consultation, int>((ref, id) {
      return ref.watch(consultationsRepositoryProvider).byId(id);
    });

/// Authenticated, memory-only image bytes for a consultation. The provider is
/// disposed when no medical-image widget is using it.
final consultationImageProvider = FutureProvider.autoDispose
    .family<Uint8List, int>((ref, consultationId) {
      return ref
          .watch(filesRepositoryProvider)
          .getConsultationImage(consultationId);
    });
