import 'package:flutter/material.dart';
import 'package:skanskin_app/core/theme/app_colors.dart';
import 'package:skanskin_app/core/theme/app_dimens.dart';

/// Quiet inline form-level error with no technical details.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message, this.icon});

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.s12,
        vertical: AppDimens.s12,
      ),
      decoration: BoxDecoration(
        color: AppColors.destructiveSoft,
        borderRadius: AppDimens.brControl,
        border: Border.all(
          color: AppColors.destructive.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon ?? Icons.error_outline_rounded,
            size: 20,
            color: AppColors.destructive,
          ),
          const SizedBox(width: AppDimens.s8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.cancelledText),
            ),
          ),
        ],
      ),
    );
  }
}
