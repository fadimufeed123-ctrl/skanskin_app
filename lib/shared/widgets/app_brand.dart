import 'package:flutter/material.dart';
import 'package:skanskin_app/core/theme/app_colors.dart';
import 'package:skanskin_app/core/theme/app_dimens.dart';

/// The official, unmodified SkanSkin mark from `assets/images/logo.png`.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 72,
    this.semanticLabel = 'شعار SkanSkin',
    this.onBrand = false,
  });

  final double size;
  final String semanticLabel;
  final bool onBrand;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(size * 0.10),
          decoration: BoxDecoration(
            color: onBrand ? AppColors.surface : AppColors.primary,
            borderRadius: BorderRadius.circular(size * 0.22),
            boxShadow: onBrand
                ? const [
                    BoxShadow(
                      color: AppColors.panelShadow,
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}

/// MVC-aligned brand lockup for launch and authentication surfaces.
class AppBrandLockup extends StatelessWidget {
  const AppBrandLockup({
    super.key,
    this.logoSize = 72,
    this.subtitle,
    this.compact = false,
    this.onBrand = false,
  });

  final double logoSize;
  final String? subtitle;
  final bool compact;
  final bool onBrand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = compact
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppLogo(size: logoSize, onBrand: onBrand),
              const SizedBox(width: AppDimens.s8),
              Flexible(
                child: Text(
                  'SkanSkin',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: onBrand
                        ? AppColors.brandForeground
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppLogo(size: logoSize, onBrand: onBrand),
              const SizedBox(height: AppDimens.s12),
              Text(
                'SkanSkin',
                textDirection: TextDirection.ltr,
                style: theme.textTheme.displayLarge?.copyWith(
                  color: onBrand
                      ? AppColors.brandForeground
                      : AppColors.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppDimens.s4),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: onBrand
                        ? AppColors.brandForeground.withValues(alpha: 0.84)
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          );

    return Semantics(
      container: true,
      label: subtitle == null ? 'SkanSkin' : 'SkanSkin، $subtitle',
      child: ExcludeSemantics(child: content),
    );
  }
}
