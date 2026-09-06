/// Defensive JSON coercion helpers — the API is trusted but we never want a
/// malformed field to crash model parsing.
class J {
  J._();

  static int asInt(dynamic v, [int fallback = 0]) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  static int? asIntOrNull(dynamic v) {
    if (v == null) return null;
    return asInt(v);
  }

  static String asString(dynamic v, [String fallback = '']) {
    if (v == null) return fallback;
    return v.toString();
  }

  static String? asStringOrNull(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    return s.isEmpty ? null : s;
  }

  static bool asBool(dynamic v, [bool fallback = false]) {
    if (v is bool) return v;
    if (v is String) return v.toLowerCase() == 'true';
    if (v is num) return v != 0;
    return fallback;
  }

  static DateTime asDate(dynamic v) {
    if (v is String) return DateTime.tryParse(v)?.toLocal() ?? DateTime.now();
    return DateTime.now();
  }
}
