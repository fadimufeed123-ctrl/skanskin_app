import 'package:flutter_test/flutter_test.dart';
import 'package:skanskin_app/core/utils/validators.dart';

void main() {
  group('Validators.fullName', () {
    test('rejects empty and too-short names, accepts valid', () {
      expect(Validators.fullName(''), isNotNull);
      expect(Validators.fullName('  '), isNotNull);
      expect(Validators.fullName('اب'), isNotNull);
      expect(Validators.fullName('أحمد علي'), isNull);
    });
  });

  group('Validators.email', () {
    test('rejects malformed addresses', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('foo'), isNotNull);
      expect(Validators.email('foo@bar'), isNotNull);
      expect(Validators.email('foo@bar.com'), isNull);
    });
  });

  group('Validators.password', () {
    test('requires at least 8 characters', () {
      expect(Validators.password(''), isNotNull);
      expect(Validators.password('1234567'), isNotNull);
      expect(Validators.password('12345678'), isNull);
    });
  });

  group('Validators.loginPassword', () {
    test('only requires non-empty', () {
      expect(Validators.loginPassword(''), isNotNull);
      expect(Validators.loginPassword('x'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('must match the original', () {
      expect(Validators.confirmPassword('', 'abc12345'), isNotNull);
      expect(Validators.confirmPassword('nope', 'abc12345'), isNotNull);
      expect(Validators.confirmPassword('abc12345', 'abc12345'), isNull);
    });
  });

  group('Validators.symptoms', () {
    test('enforces the min/max length bounds', () {
      expect(Validators.symptoms(''), isNotNull);
      expect(Validators.symptoms('short'), isNotNull);
      expect(Validators.symptoms('a' * (Validators.symptomsMin - 1)), isNotNull);
      expect(Validators.symptoms('a' * Validators.symptomsMin), isNull);
      expect(Validators.symptoms('a' * (Validators.symptomsMax + 1)), isNotNull);
    });
  });
}
