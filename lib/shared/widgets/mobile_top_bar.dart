import 'package:flutter/material.dart';
import 'package:skanskin_app/core/theme/app_colors.dart';
import 'package:skanskin_app/core/theme/app_dimens.dart';

/// RTL mobile translation of MVC's white, bottom-bordered top bar.
class MobileTopBar extends StatelessWidget implements PreferredSizeWidget {
  const MobileTopBar({
    super.key,
    required this.title,
    this.showBack = false,
    this.onBack,
    this.actions,
  });

  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppDimens.maxContentWidth,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.s8),
                child: Row(
                  children: [
                    if (showBack)
                      IconButton(
                        constraints: const BoxConstraints.tightFor(
                          width: 48,
                          height: 48,
                        ),
                        icon: const Icon(Icons.chevron_right, size: 26),
                        color: AppColors.textPrimary,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surfaceTint,
                          foregroundColor: AppColors.primary,
                        ),
                        onPressed:
                            onBack ?? () => Navigator.of(context).maybePop(),
                        tooltip: 'رجوع',
                      )
                    else
                      const SizedBox(width: AppDimens.s8),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontSize: 19,
                                color: AppColors.textPrimary,
                              ),
                        ),
                      ),
                    ),
                    if (actions != null) ...actions!,
                    const SizedBox(width: AppDimens.s4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
