/// Form validators returning Arabic messages, aligned with the backend's
/// Flutter-side validation aligned with the backend's FluentValidation rules.
class Validators {
  Validators._();

  static final RegExp _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? fullName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'الاسم الكامل مطلوب';
    if (v.length < 3) return 'الاسم قصير جدًا (٣ أحرف على الأقل)';
    if (v.length > 200) return 'الاسم طويل جدًا';
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'البريد الإلكتروني مطلوب';
    if (!_emailRe.hasMatch(v)) return 'صيغة البريد الإلكتروني غير صحيحة';
    if (v.length > 200) return 'البريد الإلكتروني طويل جدًا';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'كلمة المرور مطلوبة';
    if (v.length < 8) return 'كلمة المرور يجب ألا تقل عن ٨ أحرف';
    return null;
  }

  static String? loginPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'كلمة المرور مطلوبة';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if ((value ?? '').isEmpty) return 'تأكيد كلمة المرور مطلوب';
    if (value != original) return 'كلمتا المرور غير متطابقتين';
    return null;
  }

  static const int symptomsMin = 20;
  static const int symptomsMax = 1000;

  static String? symptoms(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'وصف الأعراض مطلوب';
    if (v.length < symptomsMin) {
      return 'يجب أن يحتوي وصف الأعراض على ٢٠ حرفًا على الأقل';
    }
    if (v.length > symptomsMax) return 'وصف الأعراض طويل جدًا';
    return null;
  }
}
