import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skanskin_app/core/network/api_exception.dart';
import 'package:skanskin_app/core/theme/app_colors.dart';
import 'package:skanskin_app/core/theme/app_dimens.dart';
import 'package:skanskin_app/core/utils/formatters.dart';
import 'package:skanskin_app/features/patients/data/models/patient.dart';
import 'package:skanskin_app/features/patients/state/patient_providers.dart';
import 'package:skanskin_app/shared/widgets/app_skeleton.dart';
import 'package:skanskin_app/shared/widgets/app_states.dart';
import 'package:skanskin_app/shared/widgets/mobile_top_bar.dart';
import 'package:skanskin_app/shared/widgets/skin_image.dart';

/// Read-only view of the signed-in patient's account details.
class PersonalInfoScreen extends ConsumerWidget {
  const PersonalInfoScreen({super.key});

  String _roleLabel(String role) {
    final normalized = role.trim().toLowerCase();
    if (normalized == 'patient') return 'مريض';
    return role.trim().isEmpty ? 'غير متوفر' : role.trim();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(patientProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      appBar: const MobileTopBar(title: 'المعلومات الشخصية', showBack: true),
      body: async.when(
        loading: () => const ColoredBox(
          color: AppColors.surface,
          child: _PersonalInfoSkeleton(),
        ),
        error: (error, _) => ColoredBox(
          color: AppColors.surface,
          child: _StateViewport(
            child: AppError(
              message: error is ApiException
                  ? error.message
                  : 'تعذّر تحميل بياناتك.',
              onRetry: () => ref.invalidate(patientProfileProvider),
            ),
          ),
        ),
        data: (patient) => _PersonalInfoBody(
          patient: patient,
          roleLabel: _roleLabel(patient.role),
        ),
      ),
    );
  }
}

class _PersonalInfoBody extends StatelessWidget {
  const _PersonalInfoBody({required this.patient, required this.roleLabel});

  final Patient patient;
  final String roleLabel;

  @override
  Widget build(BuildContext context) {
    final gutter = AppDimens.pageGutterFor(context);
    final name = patient.fullName.trim().isEmpty
        ? 'مستخدم'
        : patient.fullName.trim();
    final email = patient.email.trim().isEmpty
        ? 'غير متوفر'
        : patient.email.trim();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppDimens.maxContentWidth,
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  gutter,
                  AppDimens.s24,
                  gutter,
                  AppDimens.s24,
                ),
                child: _CompactIdentity(
                  monogram: patient.monogram,
                  name: name,
                  onBrand: true,
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppDimens.brSheetTop,
              boxShadow: [
                BoxShadow(
                  color: AppColors.panelShadow,
                  blurRadius: 24,
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
                      Semantics(
                        header: true,
                        child: Text(
                          'بيانات الحساب',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(height: AppDimens.s12),
                      _DetailsSurface(
                        children: [
                          _InfoItem(label: 'الاسم الكامل', value: name),
                          _InfoItem(
                            label: 'البريد الإلكتروني',
                            value: email,
                            ltrValue: true,
                          ),
                          _InfoItem(label: 'نوع الحساب', value: roleLabel),
                          _InfoItem(
                            label: 'عضو منذ',
                            value: Formatters.date(patient.createdAt),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsSurface extends StatelessWidget {
  const _DetailsSurface({required this.children});

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

class _CompactIdentity extends StatelessWidget {
  const _CompactIdentity({
    required this.monogram,
    required this.name,
    this.onBrand = false,
  });

  final String monogram;
  final String name;
  final bool onBrand;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Semantics(
          image: true,
          label: 'الصورة الرمزية للمستخدم $name',
          child: ExcludeSemantics(
            child: MonogramAvatar(
              monogram: monogram,
              size: 60,
              background: onBrand ? AppColors.surface : AppColors.primarySoft,
              foreground: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: AppDimens.s16),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              name,
              softWrap: true,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: onBrand
                    ? AppColors.brandForeground
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.label,
    required this.value,
    this.ltrValue = false,
  });

  final String label;
  final String value;
  final bool ltrValue;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$label: $value',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.s16,
            vertical: AppDimens.s16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimens.s8),
              Text(
                value,
                textDirection: ltrValue ? TextDirection.ltr : null,
                textAlign: ltrValue ? TextAlign.right : TextAlign.start,
                softWrap: true,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonalInfoSkeleton extends StatelessWidget {
  const _PersonalInfoSkeleton();

  @override
  Widget build(BuildContext context) {
    final gutter = AppDimens.pageGutterFor(context);

    return Semantics(
      container: true,
      liveRegion: true,
      label: 'جارٍ تحميل بياناتك',
      child: ExcludeSemantics(
        child: SingleChildScrollView(
          child: SafeArea(
            top: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppDimens.maxContentWidth,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    gutter,
                    AppDimens.s24,
                    gutter,
                    AppDimens.s32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SkeletonSurface(
                        child: Row(
                          children: [
                            Skeleton(
                              height: 56,
                              width: 56,
                              borderRadius: AppDimens.brControl,
                            ),
                            SizedBox(width: AppDimens.s16),
                            Expanded(child: Skeleton(height: 18, width: 180)),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimens.s32),
                      const Skeleton(height: 20, width: 120),
                      const SizedBox(height: AppDimens.s8),
                      _SkeletonSurface(
                        child: Column(
                          children: [
                            for (var index = 0; index < 4; index++) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppDimens.s16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Skeleton(height: 13, width: 96),
                                    SizedBox(height: AppDimens.s8),
                                    Skeleton(
                                      height: 16,
                                      width: double.infinity,
                                    ),
                                  ],
                                ),
                              ),
                              if (index < 3) const Divider(height: 1),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonSurface extends StatelessWidget {
  const _SkeletonSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimens.brCard,
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
    );
  }
}

class _StateViewport extends StatelessWidget {
  const _StateViewport({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
