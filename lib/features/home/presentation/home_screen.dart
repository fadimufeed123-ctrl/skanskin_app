import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skanskin_app/app/providers.dart';
import 'package:skanskin_app/app/routes.dart';
import 'package:skanskin_app/core/network/api_exception.dart';
import 'package:skanskin_app/core/theme/app_colors.dart';
import 'package:skanskin_app/core/theme/app_dimens.dart';
import 'package:skanskin_app/features/consultations/presentation/widgets/consultation_tile.dart';
import 'package:skanskin_app/features/consultations/state/consultations_providers.dart';
import 'package:skanskin_app/shared/widgets/app_button.dart';
import 'package:skanskin_app/shared/widgets/app_card.dart';
import 'package:skanskin_app/shared/widgets/brand_sheet.dart';
import 'package:skanskin_app/shared/widgets/skin_image.dart';

/// Home tab: greeting, the primary consultation action, and a concise preview
/// of the patient's latest consultations.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fullName =
        ref.watch(authControllerProvider.select((s) => s.session?.fullName)) ??
        '';
    final gutter = AppDimens.pageGutterFor(context);

    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.refresh(consultationsListProvider.future),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            _Header(fullName: fullName),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppDimens.brSheetTop,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.panelShadow,
                    blurRadius: 26,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppDimens.maxContentWidth,
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      gutter,
                      AppDimens.s32,
                      gutter,
                      AppDimens.s40,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StartConsultationSection(
                          onStart: () =>
                              context.push(Routes.createConsultation),
                        ),
                        const SizedBox(height: AppDimens.s16),
                        _ConsultationsNavigation(
                          onTap: () => context.go(Routes.consultations),
                        ),
                        const SizedBox(height: AppDimens.s32),
                        _LatestHeader(
                          onSeeAll: () => context.go(Routes.consultations),
                        ),
                        const SizedBox(height: AppDimens.s12),
                        const _LatestConsultations(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.fullName});

  final String fullName;

  String get _monogram {
    final trimmed = fullName.trim();
    return trimmed.isEmpty ? '؟' : trimmed.substring(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    final gutter = AppDimens.pageGutterFor(context);

    return Container(
      color: AppColors.brandBackground,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppDimens.maxContentWidth,
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                gutter,
                AppDimens.s20,
                gutter,
                AppDimens.s12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'مرحبًا بك في SkanSkin',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.brandForeground.withValues(
                                  alpha: 0.82,
                                ),
                              ),
                        ),
                        const SizedBox(height: AppDimens.s4),
                        Semantics(
                          header: true,
                          child: Text(
                            fullName.trim().isEmpty ? 'أهلًا بك' : fullName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  fontSize: 22,
                                  color: AppColors.brandForeground,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.s12),
                  Semantics(
                    button: true,
                    label: 'فتح الملف الشخصي',
                    onTap: () => context.go(Routes.profile),
                    child: ExcludeSemantics(
                      child: Tooltip(
                        message: 'الملف الشخصي',
                        child: Material(
                          color: Colors.transparent,
                          child: InkResponse(
                            onTap: () => context.go(Routes.profile),
                            radius: 28,
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: Center(
                                child: MonogramAvatar(
                                  monogram: _monogram,
                                  size: 44,
                                  background: AppColors.surface,
                                  foreground: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StartConsultationSection extends StatelessWidget {
  const _StartConsultationSection({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.surfaceTint,
      showBorder: false,
      showShadow: false,
      padding: const EdgeInsets.all(AppDimens.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppFeatureIcon(
                icon: Icons.add_photo_alternate_outlined,
                size: 52,
              ),
              const SizedBox(width: AppDimens.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        'ابدأ استشارتك الجلدية',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: AppDimens.s4),
                    Text(
                      'أضف صورة واضحة ووصفًا للأعراض ليتمكن الطبيب من مراجعة حالتك.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.s24),
          AppButton(
            label: 'استشارة جديدة',
            full: true,
            size: AppButtonSize.lg,
            icon: Icons.add_rounded,
            onPressed: onStart,
          ),
        ],
      ),
    );
  }
}

class _ConsultationsNavigation extends StatelessWidget {
  const _ConsultationsNavigation({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'استعراض استشاراتي',
      onTap: onTap,
      child: ExcludeSemantics(
        child: AppCard(
          onTap: onTap,
          color: AppColors.surfaceSubtle,
          showBorder: true,
          showShadow: false,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.s16,
            vertical: AppDimens.s12,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              children: [
                const AppFeatureIcon(
                  icon: Icons.assignment_outlined,
                  size: 44,
                  infoAccent: true,
                ),
                const SizedBox(width: AppDimens.s12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'استعراض استشاراتي',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: AppDimens.s4),
                      Text(
                        'عرض الحالات والتفاصيل السابقة',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimens.s8),
                const Icon(
                  Icons.chevron_left_rounded,
                  size: 24,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LatestHeader extends StatelessWidget {
  const _LatestHeader({required this.onSeeAll});

  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              'آخر الاستشارات',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        TextButton.icon(
          onPressed: onSeeAll,
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.chevron_left_rounded, size: 20),
          label: const Text('عرض الكل'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.s8),
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ],
    );
  }
}

class _LatestConsultations extends ConsumerWidget {
  const _LatestConsultations();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(consultationsListProvider);

    return async.when(
      loading: () => const _ConsultationRows(
        children: [
          ConsultationTileSkeleton(showSymptoms: false),
          ConsultationTileSkeleton(showSymptoms: false),
        ],
      ),
      error: (error, _) => _InlineError(
        message: error is ApiException
            ? error.message
            : 'تعذّر تحميل الاستشارات.',
        onRetry: () => ref.invalidate(consultationsListProvider),
      ),
      data: (items) {
        if (items.isEmpty) return const _HomeEmptyState();

        final preview = items.take(3).toList(growable: false);
        return _ConsultationRows(
          children: [
            for (final consultation in preview)
              ConsultationTile(
                consultation: consultation,
                showSymptoms: false,
                onTap: () =>
                    context.push(Routes.consultationDetailOf(consultation.id)),
              ),
          ],
        );
      },
    );
  }
}

class _ConsultationRows extends StatelessWidget {
  const _ConsultationRows({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimens.brCard,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0)
              const Divider(
                height: 1,
                indent: AppDimens.s16,
                endIndent: AppDimens.s16,
              ),
            children[index],
          ],
        ],
      ),
    );
  }
}

class _HomeEmptyState extends StatelessWidget {
  const _HomeEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.s20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimens.brCard,
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: AppDimens.brControl,
            ),
            child: const Icon(
              Icons.assignment_outlined,
              size: 23,
              color: AppColors.onPrimarySoft,
            ),
          ),
          const SizedBox(width: AppDimens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'لا توجد استشارات بعد',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimens.s4),
                Text(
                  'ستظهر أحدث استشاراتك هنا بعد إرسالها.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimens.brCard,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.infoSoft,
                  borderRadius: AppDimens.brControl,
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  size: 21,
                  color: AppColors.infoText,
                ),
              ),
              const SizedBox(width: AppDimens.s12),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.s12),
          AppButton(
            label: 'إعادة المحاولة',
            variant: AppButtonVariant.outline,
            size: AppButtonSize.sm,
            icon: Icons.refresh_rounded,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
