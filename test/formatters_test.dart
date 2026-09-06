import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:skanskin_app/core/utils/formatters.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ar', null);
  });

  group('Formatters.toArabicDigits', () {
    test('converts Western digits, preserves other characters', () {
      expect(Formatters.toArabicDigits('2026'), '٢٠٢٦');
      expect(Formatters.toArabicDigits('#12'), '#١٢');
      expect(Formatters.toArabicDigits('لا أرقام'), 'لا أرقام');
    });
  });

  group('Formatters.counter', () {
    test('formats "current / max" with Arabic digits', () {
      expect(Formatters.counter(147, 1000), '١٤٧ / ١٠٠٠');
      expect(Formatters.counter(0, 20), '٠ / ٢٠');
    });
  });

  group('Formatters.relative', () {
    test('recent times read as "الآن"', () {
      final now = DateTime.now();
      expect(Formatters.relative(now), 'الآن');
    });

    test('one day ago reads as "أمس"', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1, hours: 1));
      expect(Formatters.relative(yesterday), 'أمس');
    });
  });

  group('Formatters.date', () {
    test('renders with Arabic-Indic digits', () {
      final formatted = Formatters.date(DateTime(2026, 3, 11));
      // Should contain the Arabic-Indic year digits.
      expect(formatted.contains('٢٠٢٦'), isTrue);
    });
  });
}
