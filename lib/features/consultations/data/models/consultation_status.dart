import 'package:flutter/material.dart';
import 'package:skanskin_app/core/theme/app_colors.dart';

/// The patient-facing consultation lifecycle.
///
/// Maps the backend's string status values to the four MVC-aligned visual
/// states:
///   Pending    → قيد الانتظار   (pending)
///   InProgress → قيد المراجعة   (in review)
///   Completed  → تم التشخيص     (diagnosed — a Diagnosis has been authored)
///   Cancelled  → ملغاة          (cancelled)
enum ConsultationStatus {
  pending('Pending', 'قيد الانتظار'),
  inReview('InProgress', 'قيد المراجعة'),
  diagnosed('Completed', 'تم التشخيص'),
  cancelled('Cancelled', 'ملغاة'),
  unknown('', '—');

  const ConsultationStatus(this.apiValue, this.label);

  /// The exact string the backend expects/returns.
  final String apiValue;

  /// Arabic label shown in the UI.
  final String label;

  static ConsultationStatus fromApi(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'pending':
        return ConsultationStatus.pending;
      case 'inprogress':
      case 'in_progress':
      case 'inreview':
        return ConsultationStatus.inReview;
      case 'completed':
      case 'diagnosed':
        return ConsultationStatus.diagnosed;
      case 'cancelled':
      case 'canceled':
        return ConsultationStatus.cancelled;
      default:
        return ConsultationStatus.unknown;
    }
  }

  bool get isDiagnosed => this == ConsultationStatus.diagnosed;
  bool get isCancelled => this == ConsultationStatus.cancelled;
  bool get isActive =>
      this == ConsultationStatus.pending || this == ConsultationStatus.inReview;

  /// Background / foreground pair used by [StatusPill], derived from MVC.
  ({Color bg, Color fg}) get colors => switch (this) {
    ConsultationStatus.pending => (
      bg: AppColors.warningSoft,
      fg: AppColors.warningForeground,
    ),
    ConsultationStatus.inReview => (
      bg: AppColors.infoSoft,
      fg: AppColors.inReviewText,
    ),
    ConsultationStatus.diagnosed => (
      bg: AppColors.successSoft,
      fg: AppColors.diagnosedText,
    ),
    ConsultationStatus.cancelled => (
      bg: AppColors.destructiveSoft,
      fg: AppColors.cancelledText,
    ),
    ConsultationStatus.unknown => (
      bg: AppColors.muted,
      fg: AppColors.mutedForeground,
    ),
  };
}
