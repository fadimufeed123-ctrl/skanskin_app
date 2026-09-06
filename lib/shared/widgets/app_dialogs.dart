import 'package:flutter/material.dart';
import 'package:skanskin_app/core/theme/app_colors.dart';
import 'package:skanskin_app/core/theme/app_dimens.dart';
import 'package:skanskin_app/shared/widgets/app_button.dart';

/// Accessible confirmation dialog that adapts its actions to narrow screens and
/// large text. Resolves to `true` only when confirmed.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'تأكيد',
  String cancelLabel = 'تراجع',
  bool destructive = false,
  IconData icon = Icons.help_outline_rounded,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      final accent = destructive ? AppColors.destructive : AppColors.primary;
      final accentSoft = destructive
          ? AppColors.destructiveSoft
          : AppColors.primarySoft;
      return Dialog(
        backgroundColor: AppColors.surface,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppDimens.pageGutterSmall,
          vertical: AppDimens.s24,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppDimens.brDialog),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 360,
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.82,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.s24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: accentSoft,
                    borderRadius: AppDimens.brControl,
                  ),
                  child: Icon(icon, size: 24, color: accent),
                ),
                const SizedBox(height: AppDimens.s16),
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.s8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimens.s24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final textScale = MediaQuery.textScalerOf(context).scale(1);
                    final stackActions =
                        constraints.maxWidth < 280 || textScale > 1.3;

                    final cancel = AppButton(
                      label: cancelLabel,
                      full: stackActions,
                      variant: AppButtonVariant.outline,
                      onPressed: () => Navigator.of(ctx).pop(false),
                    );
                    final confirm = AppButton(
                      label: confirmLabel,
                      full: stackActions,
                      variant: destructive
                          ? AppButtonVariant.danger
                          : AppButtonVariant.primary,
                      onPressed: () => Navigator.of(ctx).pop(true),
                    );

                    if (stackActions) {
                      return Column(
                        children: [
                          confirm,
                          const SizedBox(height: AppDimens.s8),
                          cancel,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: cancel),
                        const SizedBox(width: AppDimens.s12),
                        Expanded(child: confirm),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  return result ?? false;
}
