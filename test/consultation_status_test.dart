import 'package:flutter_test/flutter_test.dart';
import 'package:skanskin_app/features/consultations/data/models/consultation_status.dart';

void main() {
  group('ConsultationStatus.fromApi', () {
    test('maps backend strings case-insensitively', () {
      expect(ConsultationStatus.fromApi('Pending'), ConsultationStatus.pending);
      expect(ConsultationStatus.fromApi('pending'), ConsultationStatus.pending);
      expect(ConsultationStatus.fromApi('InProgress'), ConsultationStatus.inReview);
      expect(ConsultationStatus.fromApi('inreview'), ConsultationStatus.inReview);
      expect(ConsultationStatus.fromApi('Completed'), ConsultationStatus.diagnosed);
      expect(ConsultationStatus.fromApi('Cancelled'), ConsultationStatus.cancelled);
    });

    test('unknown / null falls back to unknown', () {
      expect(ConsultationStatus.fromApi(null), ConsultationStatus.unknown);
      expect(ConsultationStatus.fromApi('weird'), ConsultationStatus.unknown);
    });
  });

  group('ConsultationStatus flags', () {
    test('isActive covers pending and inReview only', () {
      expect(ConsultationStatus.pending.isActive, isTrue);
      expect(ConsultationStatus.inReview.isActive, isTrue);
      expect(ConsultationStatus.diagnosed.isActive, isFalse);
      expect(ConsultationStatus.cancelled.isActive, isFalse);
    });

    test('isDiagnosed / isCancelled are exclusive', () {
      expect(ConsultationStatus.diagnosed.isDiagnosed, isTrue);
      expect(ConsultationStatus.cancelled.isCancelled, isTrue);
      expect(ConsultationStatus.pending.isDiagnosed, isFalse);
      expect(ConsultationStatus.pending.isCancelled, isFalse);
    });
  });

  test('apiValue round-trips through fromApi for real statuses', () {
    for (final status in [
      ConsultationStatus.pending,
      ConsultationStatus.inReview,
      ConsultationStatus.diagnosed,
      ConsultationStatus.cancelled,
    ]) {
      expect(ConsultationStatus.fromApi(status.apiValue), status);
    }
  });
}
