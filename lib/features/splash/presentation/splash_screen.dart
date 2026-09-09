import 'package:flutter/material.dart';
import 'package:skanskin_app/core/theme/app_colors.dart';
import 'package:skanskin_app/core/theme/app_dimens.dart';
import 'package:skanskin_app/shared/widgets/app_brand.dart';
import 'package:skanskin_app/shared/widgets/app_fade_in.dart';

/// Branded launch screen shown while the persisted session is being restored.
/// Navigation remains entirely driven by the router once auth state resolves.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gutter = AppDimens.pageGutterFor(context);
    final animationsDisabled =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final verticalPadding = constraints.maxHeight < 420
                ? AppDimens.s16
                : AppDimens.s24;
            final minimumHeight = constraints.maxHeight - verticalPadding * 2;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: gutter,
                vertical: verticalPadding,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: minimumHeight > 0 ? minimumHeight : 0,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppFadeIn(
                          offset: 16,
                          duration: Duration(milliseconds: 420),
                          child: AppBrandLockup(
                            logoSize: 96,
                            subtitle: 'استشارات الأمراض الجلدية',
                            onBrand: true,
                          ),
                        ),
                        const SizedBox(height: AppDimens.s40),
                        Semantics(
                          container: true,
                          liveRegion: true,
                          label: 'جارٍ تحميل التطبيق',
                          child: ExcludeSemantics(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: animationsDisabled
                                  ? const Icon(
                                      Icons.hourglass_empty_rounded,
                                      size: 20,
                                      color: AppColors.brandForeground,
                                    )
                                  : const CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: AppColors.brandForeground,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
