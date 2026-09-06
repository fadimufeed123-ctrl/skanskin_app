import 'package:flutter/material.dart';

/// Flutter translation of the live MVC SkanSkin palette in
/// `wwwroot/css/skanskin.css`.
///
/// The MVC source uses OKLCH values. Their sRGB equivalents are kept here so
/// the mobile and web products render the same identity. Semantic aliases are
/// retained for existing feature callers.
class AppColors {
  AppColors._();

  // MVC brand / actions: --sk-primary and --sk-primary-soft.
  static const Color primary = Color(0xFF009B95);
  static const Color primaryAction = primary;
  static const Color primaryPressed = Color(0xFF00706C);
  static const Color primaryForeground = Color(0xFFF8FDFD);
  static const Color primarySoft = Color(0xFFCEF4F1);
  static const Color onPrimarySoft = Color(0xFF006F6B);
  static const Color brandBackground = primary;
  static const Color brandForeground = Color(0xFFFFFFFF);

  // Core surfaces and text
  static const Color background = Color(0xFFF6FBFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF6FBFC);
  static const Color surfaceTint = Color(0xFFECF8F7);
  static const Color textPrimary = Color(0xFF0B1D27);
  static const Color textSecondary = Color(0xFF5E6B72);

  // Lines / controls
  static const Color divider = Color(0xFFDEE6E9);
  static const Color controlBorder = Color(0xFFE1EAEC);

  // Feedback
  static const Color success = Color(0xFF269E5F);
  static const Color successSoft = Color(0xFFD2F6DD);
  static const Color warning = Color(0xFF856404);
  static const Color warningAccent = Color(0xFFE1A035);
  static const Color warningSoft = Color(0xFFFFECC1);
  static const Color error = Color(0xFFD73337);
  static const Color errorSoft = Color(0xFFFFE5E1);
  static const Color info = Color(0xFF2B88C0);
  static const Color infoSoft = Color(0xFFD4F0FF);
  static const Color infoTextDark = Color(0xFF0C5460);

  // Compatibility aliases used by existing screens and domain UI.
  static const Color foreground = textPrimary;
  static const Color card = surface;
  static const Color cardForeground = textPrimary;
  static const Color surface2 = surfaceTint;
  static const Color secondary = primarySoft;
  static const Color secondaryForeground = onPrimarySoft;
  static const Color muted = surfaceSubtle;
  static const Color mutedForeground = textSecondary;
  static const Color accent = primarySoft;
  static const Color accentForeground = onPrimarySoft;
  static const Color destructive = error;
  static const Color destructiveForeground = Color(0xFFFFFFFF);
  static const Color destructiveSoft = errorSoft;
  static const Color successForeground = Color(0xFFFFFFFF);
  static const Color successText = success;
  static const Color warningForeground = warning;
  static const Color infoText = infoTextDark;
  static const Color inReviewText = infoTextDark;
  static const Color diagnosedText = success;
  static const Color cancelledText = error;
  static const Color border = divider;
  static const Color input = controlBorder;
  static const Color ring = primary;
  static const Color dark = textPrimary;

  /// Bootstrap's `shadow-sm`: rgba(0, 0, 0, .075).
  static const Color shadow = Color(0x13000000);
  static const Color panelShadow = Color(0x24005F5B);
}
