import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skanskin_app/app/providers.dart';
import 'package:skanskin_app/app/routes.dart';
import 'package:skanskin_app/core/theme/app_colors.dart';
import 'package:skanskin_app/core/theme/app_dimens.dart';
import 'package:skanskin_app/shared/widgets/app_brand.dart';
import 'package:skanskin_app/shared/widgets/app_button.dart';
import 'package:skanskin_app/shared/widgets/brand_sheet.dart';

class _Slide {
  const _Slide({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;
}

/// One-time introduction shown to first-time users before login. Completing or
/// skipping marks onboarding as seen so it is not shown again.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _slides = [
    _Slide(
      icon: Icons.camera_alt_outlined,
      title: 'صوّر بشرتك بسهولة',
      body: 'التقط صورة واضحة للمنطقة المصابة بإضاءة كافية خلال ثوانٍ.',
    ),
    _Slide(
      icon: Icons.medical_services_outlined,
      title: 'أرسلها لطبيب مختص',
      body: 'اختر طبيب الأمراض الجلدية المناسب وأرفق وصفًا دقيقًا للأعراض.',
    ),
    _Slide(
      icon: Icons.verified_outlined,
      title: 'احصل على تشخيص ووصفة',
      body: 'يراجع الطبيب حالتك ويزوّدك بالتشخيص والوصفة العلاجية بوضوح.',
    ),
  ];

  bool get _isLast => _index == _slides.length - 1;

  Future<void> _finish() async {
    await ref.read(authControllerProvider.notifier).completeOnboarding();
    if (mounted) context.go(Routes.login);
  }

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }

    final animationsDisabled =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (animationsDisabled) {
      _controller.jumpToPage(_index + 1);
      return;
    }

    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gutter = AppDimens.pageGutterFor(context);
    final animationsDisabled =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return BrandSheetScaffold(
      headerExtent: 220,
      header: Stack(
        fit: StackFit.expand,
        children: [
          const Center(child: AppBrandLockup(logoSize: 72, onBrand: true)),
          PositionedDirectional(
            end: gutter,
            top: AppDimens.s8,
            child: Semantics(
              button: true,
              label: 'تخطي المقدمة',
              onTap: _finish,
              child: ExcludeSemantics(
                child: TextButton(
                  onPressed: _finish,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.brandForeground,
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    minimumSize: const Size(72, 48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.s16,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppDimens.brFull,
                    ),
                    textStyle: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(fontSize: 14),
                  ),
                  child: const Text('تخطي'),
                ),
              ),
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _slides.length,
              onPageChanged: (index) => setState(() => _index = index),
              itemBuilder: (context, index) =>
                  _OnboardingPage(slide: _slides[index]),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppDimens.maxContentWidth,
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  gutter,
                  AppDimens.s12,
                  gutter,
                  AppDimens.s24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PageIndicator(
                      currentIndex: _index,
                      pageCount: _slides.length,
                      animationsDisabled: animationsDisabled,
                    ),
                    const SizedBox(height: AppDimens.s16),
                    AppButton(
                      label: _isLast ? 'ابدأ الآن' : 'التالي',
                      full: true,
                      size: AppButtonSize.lg,
                      onPressed: _next,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.slide});

  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    final gutter = AppDimens.pageGutterFor(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final verticalPadding = constraints.maxHeight < 420
            ? AppDimens.s12
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
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppFeatureIcon(icon: slide.icon, size: 88),
                    const SizedBox(height: AppDimens.s32),
                    Semantics(
                      header: true,
                      child: Text(
                        slide.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontSize: 24,
                              height: 34 / 24,
                              color: AppColors.textPrimary,
                            ),
                      ),
                    ),
                    const SizedBox(height: AppDimens.s12),
                    Text(
                      slide.body,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 15,
                        height: 25 / 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.currentIndex,
    required this.pageCount,
    required this.animationsDisabled,
  });

  final int currentIndex;
  final int pageCount;
  final bool animationsDisabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'الخطوة ${currentIndex + 1} من $pageCount',
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(pageCount, (index) {
            final active = index == currentIndex;
            return AnimatedContainer(
              duration: animationsDisabled
                  ? Duration.zero
                  : const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: AppDimens.s4),
              height: 8,
              width: active ? 28 : 8,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.divider,
                borderRadius: AppDimens.brFull,
              ),
            );
          }),
        ),
      ),
    );
  }
}
