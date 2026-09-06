import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimens.dart';

/// Material 3 implementation of the live MVC SkanSkin identity.
///
/// Almarai, MVC colors, Bootstrap-like radii, quiet borders, and `shadow-sm`
/// surfaces are translated to mobile without altering feature behavior.
class AppTheme {
  AppTheme._();

  static const String fontFamily = 'Almarai';

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);

    final colorScheme = const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.primaryForeground,
      primaryContainer: AppColors.primarySoft,
      onPrimaryContainer: AppColors.onPrimarySoft,
      secondary: AppColors.onPrimarySoft,
      onSecondary: AppColors.primaryForeground,
      secondaryContainer: AppColors.primarySoft,
      onSecondaryContainer: AppColors.onPrimarySoft,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceSubtle,
      error: AppColors.error,
      onError: AppColors.destructiveForeground,
      errorContainer: AppColors.errorSoft,
      onErrorContainer: AppColors.error,
      outline: AppColors.controlBorder,
      outlineVariant: AppColors.divider,
    );

    final textTheme = _textTheme(base.textTheme);

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      primaryColor: AppColors.primary,
      dividerColor: AppColors.divider,
      disabledColor: AppColors.textSecondary,
      shadowColor: AppColors.shadow,
      focusColor: AppColors.primarySoft,
      splashColor: AppColors.primary.withValues(alpha: 0.10),
      highlightColor: AppColors.primary.withValues(alpha: 0.06),
      textTheme: textTheme,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: AppColors.surface,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          height: 28 / 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary, size: 22),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shadowColor: AppColors.shadow,
        margin: EdgeInsets.zero,
        surfaceTintColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppDimens.brCard),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
          tapTargetSize: MaterialTapTargetSize.padded,
          foregroundColor: const WidgetStatePropertyAll(AppColors.textPrimary),
          overlayColor: WidgetStatePropertyAll(
            AppColors.primary.withValues(alpha: 0.10),
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceSubtle,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimens.s16,
          vertical: AppDimens.s16,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: AppDimens.brControl,
          borderSide: const BorderSide(color: AppColors.controlBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimens.brControl,
          borderSide: const BorderSide(color: AppColors.controlBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimens.brControl,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppDimens.brControl,
          borderSide: const BorderSide(color: AppColors.error, width: 1.25),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppDimens.brControl,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppDimens.brControl,
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        errorStyle: const TextStyle(
          fontFamily: fontFamily,
          color: AppColors.error,
          fontSize: 12,
          height: 18 / 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primarySoft,
        disabledColor: AppColors.surfaceSubtle,
        checkmarkColor: AppColors.onPrimarySoft,
        side: const BorderSide(color: AppColors.divider),
        shape: const RoundedRectangleBorder(borderRadius: AppDimens.brControl),
        labelStyle: textTheme.labelLarge?.copyWith(
          color: AppColors.textSecondary,
        ),
        secondaryLabelStyle: textTheme.labelLarge?.copyWith(
          color: AppColors.onPrimarySoft,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.s12,
          vertical: AppDimens.s8,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimens.rDialog),
          ),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(borderRadius: AppDimens.brDialog),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: Colors.white,
          fontSize: 13,
          height: 21 / 13,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppDimens.brControl),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: AppColors.surface,
        elevation: 0,
        indicatorColor: AppColors.primarySoft,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            height: 18 / 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w400,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textSecondary,
          );
        }),
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    TextStyle s(
      double size,
      double lineHeight,
      FontWeight weight, {
      Color color = AppColors.textPrimary,
    }) => TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: lineHeight / size,
    );

    return base
        .copyWith(
          displayLarge: s(28, 38, FontWeight.w800),
          displayMedium: s(24, 34, FontWeight.w800),
          displaySmall: s(24, 34, FontWeight.w800),
          headlineLarge: s(24, 34, FontWeight.w800),
          headlineMedium: s(18, 28, FontWeight.w700),
          headlineSmall: s(18, 28, FontWeight.w700),
          titleLarge: s(18, 28, FontWeight.w700),
          titleMedium: s(16, 25, FontWeight.w700),
          titleSmall: s(13, 20, FontWeight.w700),
          bodyLarge: s(16, 26, FontWeight.w400),
          bodyMedium: s(14, 23, FontWeight.w400),
          bodySmall: s(13, 21, FontWeight.w400, color: AppColors.textSecondary),
          labelLarge: s(13, 20, FontWeight.w700),
          labelMedium: s(12, 18, FontWeight.w700),
          labelSmall: s(
            12,
            18,
            FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        )
        .apply(fontFamily: fontFamily);
  }
}
