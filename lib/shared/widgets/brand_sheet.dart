import 'package:flutter/material.dart';
import 'package:skanskin_app/core/theme/app_colors.dart';
import 'package:skanskin_app/core/theme/app_dimens.dart';

/// Reference-driven mobile composition: a concise brand area followed by one
/// large white content sheet. It is intentionally layout-only; callers keep
/// ownership of scrolling, state, and navigation.
class BrandSheetScaffold extends StatelessWidget {
  const BrandSheetScaffold({
    super.key,
    required this.header,
    required this.child,
    this.headerExtent = 172,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget header;
  final Widget child;
  final double headerExtent;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final compactExtent = height < 640 ? headerExtent * 0.76 : headerExtent;
    final accessibilityExtra = ((textScale - 1).clamp(0, 1)) * 52;

    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              height: compactExtent + accessibilityExtra,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppDimens.maxContentWidth,
                  ),
                  child: header,
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppDimens.brSheetTop,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.panelShadow,
                      blurRadius: 28,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact, factual reassurance used on authentication and consultation
/// surfaces. The icon and text are both exposed as one semantic statement.
class AppTrustCue extends StatelessWidget {
  const AppTrustCue({
    super.key,
    this.label = 'تُستخدم بياناتك لتقديم الاستشارة الطبية بأمان',
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: label,
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shield_outlined,
              size: 18,
              color: AppColors.success,
            ),
            const SizedBox(width: AppDimens.s8),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared visual language for a small number of meaningful feature icons.
class AppFeatureIcon extends StatelessWidget {
  const AppFeatureIcon({
    super.key,
    required this.icon,
    this.size = 52,
    this.infoAccent = false,
  });

  final IconData icon;
  final double size;
  final bool infoAccent;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: infoAccent ? AppColors.info : AppColors.primary,
          borderRadius: AppDimens.brControl,
        ),
        child: Icon(icon, size: size * 0.44, color: AppColors.brandForeground),
      ),
    );
  }
}
