import 'package:flutter/material.dart';
import 'package:skanskin_app/core/theme/app_colors.dart';
import 'package:skanskin_app/core/theme/app_dimens.dart';
import 'package:skanskin_app/core/theme/app_elevation.dart';
import 'package:skanskin_app/shared/widgets/pressable_scale.dart';

/// Mobile counterpart of MVC's white `.card.shadow-sm` surface.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimens.s16),
    this.onTap,
    this.borderRadius = AppDimens.brCard,
    this.color = AppColors.surface,
    this.showBorder = true,
    this.showShadow = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final Color color;
  final bool showBorder;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: color,
      borderRadius: borderRadius,
      border: showBorder ? Border.all(color: AppColors.divider) : null,
      boxShadow: showShadow ? AppElevation.card : null,
    );

    if (onTap == null) {
      return Container(padding: padding, decoration: decoration, child: child);
    }

    return Semantics(
      button: true,
      child: PressableScale(
        child: DecoratedBox(
          decoration: decoration,
          child: Material(
            color: Colors.transparent,
            borderRadius: borderRadius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              borderRadius: borderRadius,
              overlayColor: WidgetStatePropertyAll(
                AppColors.primary.withValues(alpha: 0.08),
              ),
              child: Padding(padding: padding, child: child),
            ),
          ),
        ),
      ),
    );
  }
}
