import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import 'app_button.dart';

/// Compact loading state for short, in-app waits.
class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final semanticLabel = message ?? 'جارٍ التحميل';

    return Center(
      child: Semantics(
        container: true,
        liveRegion: true,
        label: semanticLabel,
        child: ExcludeSemantics(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  color: AppColors.primary,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: AppDimens.s16),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Calm empty-state placeholder with an optional existing action.
class AppEmpty extends StatelessWidget {
  const AppEmpty({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.pageGutterLarge,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: AppDimens.brControl,
                ),
                child: Icon(icon, size: 29, color: AppColors.primary),
              ),
              const SizedBox(height: AppDimens.s16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary),
              ),
              if (message != null) ...[
                const SizedBox(height: AppDimens.s8),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppDimens.s20),
                AppButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  icon: actionIcon,
                  size: AppButtonSize.md,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Neutral error-state placeholder with an explicit retry action.
class AppError extends StatelessWidget {
  const AppError({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.icon = Icons.wifi_off_rounded,
  });

  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final heading = title ?? 'تعذّر إكمال الطلب';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.pageGutterLarge,
          ),
          child: Semantics(
            container: true,
            liveRegion: true,
            label: '$heading. $message',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 48,
                        width: 48,
                        decoration: const BoxDecoration(
                          color: AppColors.infoSoft,
                          borderRadius: AppDimens.brControl,
                        ),
                        child: Icon(icon, size: 23, color: AppColors.infoText),
                      ),
                      const SizedBox(height: AppDimens.s16),
                      Text(
                        heading,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: AppDimens.s8),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: AppDimens.s20),
                  AppButton(
                    label: 'إعادة المحاولة',
                    onPressed: onRetry,
                    variant: AppButtonVariant.outline,
                    icon: Icons.refresh_rounded,
                    size: AppButtonSize.md,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
