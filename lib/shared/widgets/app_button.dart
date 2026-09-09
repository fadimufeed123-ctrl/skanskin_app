import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_elevation.dart';
import 'pressable_scale.dart';

enum AppButtonVariant {
  primary,
  secondary,
  ghost,
  outline,
  danger,
  dangerOutline,
  soft,
}

enum AppButtonSize { sm, md, lg }

/// Accessible MVC-aligned SkanSkin action button with stable loading geometry.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
    this.full = false,
    this.loading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool full;
  final bool loading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final bool disabled = !enabled || onPressed == null;
    final bool interactionBlocked = disabled || loading;
    final sizing = _sizingFor(size);
    final colors = _colorsFor(variant);

    final style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(0, sizing.minHeight)),
      padding: WidgetStatePropertyAll(sizing.padding),
      tapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      animationDuration: const Duration(milliseconds: 160),
      elevation: const WidgetStatePropertyAll(0),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: AppDimens.brControl),
      ),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return colors.disabledBg;
        if (states.contains(WidgetState.pressed)) return colors.pressedBg;
        return colors.bg;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return colors.disabledFg;
        return colors.fg;
      }),
      side: WidgetStateProperty.resolveWith((states) {
        final border = states.contains(WidgetState.disabled)
            ? colors.disabledBorder
            : colors.border;
        return border == null ? BorderSide.none : BorderSide(color: border);
      }),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
    );

    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      fontSize: sizing.fontSize,
      height: 20 / sizing.fontSize,
      color: interactionBlocked ? colors.disabledFg : colors.fg,
    );

    final visibleContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: sizing.iconSize),
          const SizedBox(width: AppDimens.s8),
        ],
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            softWrap: true,
            style: labelStyle,
          ),
        ),
      ],
    );

    final button = TextButton(
      style: style,
      onPressed: disabled ? null : onPressed,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(opacity: loading ? 0 : 1, child: visibleContent),
          if (loading)
            SizedBox(
              width: sizing.spinnerSize,
              height: sizing.spinnerSize,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: colors.fg,
              ),
            ),
        ],
      ),
    );

    Widget visual = full
        ? SizedBox(width: double.infinity, child: button)
        : button;

    final shadow = _shadowFor(variant, interactionBlocked);
    if (shadow != null) {
      visual = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppDimens.brControl,
          boxShadow: shadow,
        ),
        child: visual,
      );
    }

    return Semantics(
      button: true,
      enabled: !interactionBlocked,
      liveRegion: loading,
      label: loading ? '$label، جارٍ التنفيذ' : label,
      onTap: interactionBlocked ? null : onPressed,
      child: ExcludeSemantics(
        child: IgnorePointer(
          ignoring: loading,
          child: PressableScale(enabled: !interactionBlocked, child: visual),
        ),
      ),
    );
  }

  /// A soft lift for the two emphasis variants only, so the primary action
  /// clearly stands out. Suppressed while disabled or loading.
  static List<BoxShadow>? _shadowFor(AppButtonVariant variant, bool blocked) {
    if (blocked) return null;
    return switch (variant) {
      AppButtonVariant.primary => AppElevation.brand,
      AppButtonVariant.danger => AppElevation.sm,
      _ => null,
    };
  }

  static ({
    double minHeight,
    double fontSize,
    double iconSize,
    double spinnerSize,
    EdgeInsets padding,
  })
  _sizingFor(AppButtonSize size) => switch (size) {
    AppButtonSize.sm => (
      minHeight: 48,
      fontSize: 14,
      iconSize: 18,
      spinnerSize: 18,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.s16,
        vertical: AppDimens.s8,
      ),
    ),
    AppButtonSize.md => (
      minHeight: 52,
      fontSize: 14,
      iconSize: 20,
      spinnerSize: 20,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.s16,
        vertical: AppDimens.s12,
      ),
    ),
    AppButtonSize.lg => (
      minHeight: 56,
      fontSize: 15,
      iconSize: 20,
      spinnerSize: 22,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.s20,
        vertical: AppDimens.s12,
      ),
    ),
  };

  static _ButtonColors _colorsFor(AppButtonVariant variant) =>
      switch (variant) {
        AppButtonVariant.primary => const _ButtonColors(
          bg: AppColors.primaryAction,
          pressedBg: AppColors.primaryPressed,
          fg: AppColors.primaryForeground,
        ),
        AppButtonVariant.secondary || AppButtonVariant.soft => _ButtonColors(
          bg: AppColors.primarySoft,
          pressedBg: Color.alphaBlend(
            AppColors.primary.withValues(alpha: 0.10),
            AppColors.primarySoft,
          ),
          fg: AppColors.onPrimarySoft,
        ),
        AppButtonVariant.outline => const _ButtonColors(
          bg: AppColors.surface,
          pressedBg: AppColors.surfaceSubtle,
          fg: AppColors.textPrimary,
          border: AppColors.divider,
        ),
        AppButtonVariant.ghost => const _ButtonColors(
          bg: Colors.transparent,
          pressedBg: AppColors.surfaceSubtle,
          fg: AppColors.textPrimary,
        ),
        AppButtonVariant.danger => _ButtonColors(
          bg: AppColors.error,
          pressedBg: Color.alphaBlend(
            AppColors.textPrimary.withValues(alpha: 0.14),
            AppColors.error,
          ),
          fg: AppColors.destructiveForeground,
        ),
        AppButtonVariant.dangerOutline => const _ButtonColors(
          bg: AppColors.surface,
          pressedBg: AppColors.errorSoft,
          fg: AppColors.error,
          border: AppColors.error,
        ),
      };
}

class _ButtonColors {
  const _ButtonColors({
    required this.bg,
    required this.pressedBg,
    required this.fg,
    this.border,
  });

  final Color bg;
  final Color pressedBg;
  final Color fg;
  final Color? border;

  Color get disabledBg => AppColors.surfaceSubtle;
  Color get disabledFg => AppColors.textSecondary;
  Color? get disabledBorder => border == null ? null : AppColors.divider;
}
