import 'package:intl/intl.dart';

/// Arabic-aware display formatting: Gregorian dates with Arabic month names,
/// Eastern-Arabic (Arabic-Indic) digits, and relative "time ago" phrasing.
class Formatters {
  Formatters._();

  static const _arabicDigits = [
    '٠',
    '١',
    '٢',
    '٣',
    '٤',
    '٥',
    '٦',
    '٧',
    '٨',
    '٩',
  ];

  /// Converts Western digits in [input] to Eastern-Arabic digits.
  static String toArabicDigits(String input) {
    final buffer = StringBuffer();
    for (final code in input.runes) {
      if (code >= 0x30 && code <= 0x39) {
        buffer.write(_arabicDigits[code - 0x30]);
      } else {
        buffer.writeCharCode(code);
      }
    }
    return buffer.toString();
  }

  /// e.g. `٠٣ نوفمبر ٢٠٢٦`
  static String date(DateTime dt) =>
      toArabicDigits(DateFormat('dd MMMM yyyy', 'ar').format(dt.toLocal()));

  /// e.g. `٠٣ نوفمبر ٢٠٢٦ · ٠٢:١٥ م`
  static String dateTime(DateTime dt) {
    final d = DateFormat('dd MMMM yyyy', 'ar').format(dt.toLocal());
    final t = DateFormat('hh:mm a', 'ar').format(dt.toLocal());
    return toArabicDigits('$d · $t');
  }

  /// Relative phrasing for recent items: اليوم / أمس / منذ N أيام / date.
  static String relative(DateTime dt) {
    final now = DateTime.now();
    final local = dt.toLocal();
    final diff = now.difference(local);

    if (diff.inSeconds < 60) return 'الآن';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return m == 1 ? 'منذ دقيقة' : 'منذ ${toArabicDigits('$m')} دقيقة';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return h == 1 ? 'منذ ساعة' : 'منذ ${toArabicDigits('$h')} ساعات';
    }
    final days = diff.inDays;
    if (days == 0) return 'اليوم';
    if (days == 1) return 'أمس';
    if (days < 7) return 'منذ ${toArabicDigits('$days')} أيام';
    return date(local);
  }

  /// `147 / 1000` → `١٤٧ / ١٠٠٠`
  static String counter(int current, int max) =>
      toArabicDigits('$current / $max');
}
