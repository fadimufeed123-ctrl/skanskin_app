import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skanskin_app/app/providers.dart';
import 'package:skanskin_app/core/network/api_exception.dart';
import 'package:skanskin_app/core/theme/app_colors.dart';
import 'package:skanskin_app/core/theme/app_dimens.dart';
import 'package:skanskin_app/core/utils/formatters.dart';
import 'package:skanskin_app/features/consultations/data/models/consultation.dart';
import 'package:skanskin_app/features/consultations/data/models/consultation_status.dart';
import 'package:skanskin_app/features/consultations/state/consultations_providers.dart';
import 'package:skanskin_app/features/doctors/state/doctors_providers.dart';
import 'package:skanskin_app/shared/widgets/app_button.dart';
import 'package:skanskin_app/shared/widgets/app_dialogs.dart';
import 'package:skanskin_app/shared/widgets/app_skeleton.dart';
import 'package:skanskin_app/shared/widgets/app_states.dart';
import 'package:skanskin_app/shared/widgets/mobile_top_bar.dart';
import 'package:skanskin_app/shared/widgets/skin_image.dart';
import 'package:skanskin_app/shared/widgets/status_pill.dart';

/// Patient-facing medical record for a single consultation.
///
/// Data loading, authenticated image access, diagnosis content, and
/// cancellation behavior remain owned by their existing providers/repository.
class ConsultationDetailScreen extends ConsumerStatefulWidget {
  const ConsultationDetailScreen({super.key, required this.id});

  final int id;

  @override
  ConsumerState<ConsultationDetailScreen> createState() =>
      _ConsultationDetailScreenState();
}

class _ConsultationDetailScreenState
    extends ConsumerState<ConsultationDetailScreen> {
  bool _cancelling = false;

  Future<void> _cancel() async {
    final idText = Formatters.toArabicDigits('${widget.id}');
    final confirmed = await showConfirmDialog(
      context,
      title: 'إلغاء الاستشارة؟',
      message:
          'سيتم إلغاء الاستشارة #$idText نهائيًا ولا يمكن التراجع عن هذا الإجراء.',
      confirmLabel: 'نعم، ألغِها',
      cancelLabel: 'تراجع',
      destructive: true,
      icon: Icons.warning_amber_rounded,
    );
    if (!confirmed || !mounted) return;

    setState(() => _cancelling = true);
    try {
      await ref.read(consultationsRepositoryProvider).cancel(widget.id);
      ref.invalidate(consultationsListProvider);
      ref.invalidate(consultationDetailProvider(widget.id));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم إلغاء الاستشارة')));
      }
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  void _openFullImage(Consultation consultation) {
    if (!consultation.hasImage) return;

    showDialog<void>(
      context: context,
      barrierColor: Colors.black,
      useSafeArea: false,
      builder: (dialogContext) => _FullScreenImageViewer(
        consultationId: consultation.id,
        onClose: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(consultationDetailProvider(widget.id));

    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      appBar: const MobileTopBar(title: 'تفاصيل الاستشارة', showBack: true),
      body: async.when(
        loading: () => const ColoredBox(
          color: AppColors.surface,
          child: _ConsultationDetailSkeleton(),
        ),
        error: (error, _) => ColoredBox(
          color: AppColors.surface,
          child: AppError(
            message: error is ApiException
                ? error.message
                : 'تعذّر تحميل تفاصيل الاستشارة.',
            onRetry: () =>
                ref.invalidate(consultationDetailProvider(widget.id)),
          ),
        ),
        data: _buildDetail,
      ),
    );
  }

  Widget _buildDetail(Consultation consultation) {
    final gutter = AppDimens.pageGutterFor(context);

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
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
                    AppDimens.s20,
                    gutter,
                    AppDimens.s24,
                  ),
                  child: _ConsultationSummary(consultation: consultation),
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _SectionHeading(title: 'الطبيب المعالج'),
                        const SizedBox(height: AppDimens.s12),
                        _DoctorSection(
                          doctorId: consultation.doctorId,
                          fallbackName: consultation.doctorName,
                        ),
                        const SizedBox(height: AppDimens.s32),
                        const _SectionHeading(title: 'صورة الحالة'),
                        const SizedBox(height: AppDimens.s12),
                        _MedicalImageSection(
                          consultation: consultation,
                          onOpen: () => _openFullImage(consultation),
                        ),
                        const SizedBox(height: AppDimens.s32),
                        const _SectionHeading(title: 'الأعراض المرسلة'),
                        const SizedBox(height: AppDimens.s12),
                        _SymptomsSection(symptoms: consultation.symptoms),
                        if (consultation.diagnosis != null) ...[
                          const SizedBox(height: AppDimens.s32),
                          _DiagnosisSection(consultation: consultation),
                        ] else if (consultation.status.isActive) ...[
                          const SizedBox(height: AppDimens.s32),
                          _ReviewState(status: consultation.status),
                        ] else if (consultation.status.isCancelled) ...[
                          const SizedBox(height: AppDimens.s32),
                          const _CancelledState(),
                        ],
                        if (consultation.status.isActive) ...[
                          const SizedBox(height: AppDimens.s32),
                          AppButton(
                            label: 'إلغاء الاستشارة',
                            full: true,
                            variant: AppButtonVariant.dangerOutline,
                            icon: Icons.close_rounded,
                            loading: _cancelling,
                            onPressed: _cancel,
                          ),
                        ],
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

class _ConsultationDetailSkeleton extends StatelessWidget {
  const _ConsultationDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    final gutter = AppDimens.pageGutterFor(context);

    return Semantics(
      container: true,
      liveRegion: true,
      label: 'جارٍ تحميل تفاصيل الاستشارة',
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
                    AppDimens.s16,
                    gutter,
                    AppDimens.s32,
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Skeleton(height: 118, borderRadius: AppDimens.brCard),
                      SizedBox(height: AppDimens.s24),
                      Skeleton(height: 20, width: 128),
                      SizedBox(height: AppDimens.s12),
                      Row(
                        children: [
                          Skeleton(
                            width: 56,
                            height: 56,
                            borderRadius: AppDimens.brControl,
                          ),
                          SizedBox(width: AppDimens.s12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Skeleton(height: 16, width: 172),
                                SizedBox(height: AppDimens.s8),
                                Skeleton(height: 13, width: 120),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppDimens.s32),
                      Skeleton(height: 20, width: 110),
                      SizedBox(height: AppDimens.s12),
                      AspectRatio(
                        aspectRatio: 4 / 3,
                        child: Skeleton(borderRadius: AppDimens.brCard),
                      ),
                      SizedBox(height: AppDimens.s32),
                      Skeleton(height: 20, width: 140),
                      SizedBox(height: AppDimens.s12),
                      Skeleton(height: 84, borderRadius: AppDimens.brControl),
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

class _ConsultationSummary extends StatelessWidget {
  const _ConsultationSummary({required this.consultation});

  final Consultation consultation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final idText = Formatters.toArabicDigits('${consultation.id}');

    return Container(
      padding: const EdgeInsets.all(AppDimens.s16),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppDimens.s12,
            runSpacing: AppDimens.s8,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'رقم الاستشارة',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.brandForeground.withValues(alpha: 0.78),
                    ),
                  ),
                  const SizedBox(height: AppDimens.s4),
                  Text(
                    '#$idText',
                    textDirection: TextDirection.ltr,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.brandForeground,
                    ),
                  ),
                ],
              ),
              StatusPill(consultation.status),
            ],
          ),
          const SizedBox(height: AppDimens.s12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: Color(0xCCFFFFFF),
                ),
              ),
              const SizedBox(width: AppDimens.s8),
              Expanded(
                child: Text(
                  'أُرسلت ${Formatters.dateTime(consultation.createdAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.brandForeground.withValues(alpha: 0.78),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.s8),
          Text(
            _statusMessage(consultation.status),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.brandForeground,
            ),
          ),
        ],
      ),
    );
  }
}

String _statusMessage(ConsultationStatus status) => switch (status) {
  ConsultationStatus.pending => 'تم استلام طلبك وهو بانتظار بدء المراجعة.',
  ConsultationStatus.inReview => 'الطبيب يراجع تفاصيل حالتك.',
  ConsultationStatus.diagnosed => 'اكتملت المراجعة وأصبح التشخيص جاهزًا.',
  ConsultationStatus.cancelled => 'تم إلغاء هذه الاستشارة.',
  ConsultationStatus.unknown => 'تفاصيل حالة الاستشارة غير متاحة.',
};

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}

class _DoctorSection extends ConsumerWidget {
  const _DoctorSection({required this.doctorId, this.fallbackName});

  final int doctorId;
  final String? fallbackName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(doctorByIdProvider(doctorId));
    final fallback = fallbackName?.trim();
    final fallbackDoctorName = fallback == null || fallback.isEmpty
        ? 'الطبيب المختص'
        : fallback;

    return async.when(
      data: (doctor) => _DoctorRow(
        name: doctor.fullName,
        specialization: doctor.specialization,
        monogram: doctor.monogram,
        imageUrl: doctor.imageUrl,
        yearsOfExperience: doctor.yearsOfExperience,
      ),
      loading: () => _DoctorRow(
        name: fallbackDoctorName,
        supportingText: 'جارٍ تحميل بيانات الطبيب…',
        monogram: _monogramFor(fallbackDoctorName),
      ),
      error: (_, _) => _DoctorRow(
        name: fallbackDoctorName,
        monogram: _monogramFor(fallbackDoctorName),
      ),
    );
  }
}

class _DoctorRow extends StatelessWidget {
  const _DoctorRow({
    required this.name,
    required this.monogram,
    this.specialization,
    this.imageUrl,
    this.yearsOfExperience = 0,
    this.supportingText,
  });

  final String name;
  final String monogram;
  final String? specialization;
  final String? imageUrl;
  final int yearsOfExperience;
  final String? supportingText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final specializationText = specialization?.trim();
    final experienceText = yearsOfExperience > 0
        ? '${Formatters.toArabicDigits('$yearsOfExperience')} سنوات خبرة'
        : null;
    final semanticsLabel = [
      name,
      if (specializationText != null && specializationText.isNotEmpty)
        specializationText,
      if (experienceText != null) experienceText,
      if (supportingText != null) supportingText!,
    ].join('، ');

    return Semantics(
      container: true,
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimens.s16),
          decoration: BoxDecoration(
            color: AppColors.surfaceSubtle,
            borderRadius: AppDimens.brCard,
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MonogramAvatar(monogram: monogram, imageUrl: imageUrl, size: 56),
              const SizedBox(width: AppDimens.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (specializationText != null &&
                        specializationText.isNotEmpty) ...[
                      const SizedBox(height: AppDimens.s4),
                      Text(
                        specializationText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (experienceText != null) ...[
                      const SizedBox(height: AppDimens.s4),
                      Row(
                        children: [
                          const Icon(
                            Icons.workspace_premium_outlined,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppDimens.s4),
                          Flexible(
                            child: Text(
                              experienceText,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else if (supportingText != null) ...[
                      const SizedBox(height: AppDimens.s4),
                      Text(
                        supportingText!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _monogramFor(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '؟';
  final parts = trimmed.split(RegExp(r'\s+'));
  final namePart = parts.length > 1 && parts.first.contains('.')
      ? parts[1]
      : parts.first;
  return namePart.isEmpty ? '؟' : namePart.substring(0, 1);
}

class _MedicalImageSection extends ConsumerWidget {
  const _MedicalImageSection({
    required this.consultation,
    required this.onOpen,
  });

  final Consultation consultation;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!consultation.hasImage) {
      return const _MedicalImageState(
        icon: Icons.image_not_supported_outlined,
        message: 'لا توجد صورة مرفقة.',
      );
    }

    final image = ref.watch(consultationImageProvider(consultation.id));

    return image.when(
      loading: () => const _MedicalImageState(
        icon: Icons.image_outlined,
        message: 'جارٍ تحميل صورة الحالة…',
      ),
      error: (_, _) => _MedicalImageState(
        icon: Icons.broken_image_outlined,
        message: 'تعذّر تحميل الصورة.',
        onRetry: () =>
            ref.invalidate(consultationImageProvider(consultation.id)),
      ),
      data: (_) => Semantics(
        button: true,
        image: true,
        label: 'عرض صورة الحالة بحجم كامل',
        onTap: onOpen,
        child: ExcludeSemantics(
          child: Material(
            color: AppColors.surface,
            elevation: 0,
            shadowColor: AppColors.shadow,
            borderRadius: AppDimens.brCard,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onOpen,
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: SkinImage(
                      consultationId: consultation.id,
                      hasImage: true,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  PositionedDirectional(
                    end: AppDimens.s8,
                    bottom: AppDimens.s8,
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.s12,
                        vertical: AppDimens.s8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary.withValues(alpha: 0.78),
                        borderRadius: AppDimens.brControl,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.open_in_full_rounded,
                            size: 18,
                            color: AppColors.primaryForeground,
                          ),
                          SizedBox(width: AppDimens.s8),
                          Text(
                            'عرض الصورة',
                            style: TextStyle(
                              fontSize: 13,
                              height: 20 / 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryForeground,
                            ),
                          ),
                        ],
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

class _MedicalImageState extends StatelessWidget {
  const _MedicalImageState({
    required this.icon,
    required this.message,
    this.onRetry,
  });

  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceSubtle,
          borderRadius: AppDimens.brCard,
          border: Border.all(color: AppColors.divider),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.s16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (AppDimens.s16 * 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 36, color: AppColors.textSecondary),
                    const SizedBox(height: AppDimens.s8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (onRetry != null) ...[
                      const SizedBox(height: AppDimens.s12),
                      AppButton(
                        label: 'إعادة المحاولة',
                        variant: AppButtonVariant.outline,
                        size: AppButtonSize.sm,
                        icon: Icons.refresh_rounded,
                        onPressed: onRetry,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FullScreenImageViewer extends StatelessWidget {
  const _FullScreenImageViewer({
    required this.consultationId,
    required this.onClose,
  });

  final int consultationId;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Semantics(
                image: true,
                label: 'صورة الحالة بحجم كامل',
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: SkinImage(
                      consultationId: consultationId,
                      hasImage: true,
                      fit: BoxFit.contain,
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              top: AppDimens.s8,
              end: AppDimens.s8,
              child: Semantics(
                button: true,
                label: 'إغلاق عارض الصورة',
                onTap: onClose,
                child: ExcludeSemantics(
                  child: IconButton(
                    onPressed: onClose,
                    tooltip: 'إغلاق',
                    constraints: const BoxConstraints.tightFor(
                      width: 48,
                      height: 48,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.close_rounded, size: 26),
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

class _SymptomsSection extends StatelessWidget {
  const _SymptomsSection({required this.symptoms});

  final String symptoms;

  @override
  Widget build(BuildContext context) {
    final value = symptoms.trim().isEmpty ? '—' : symptoms.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.s16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: AppDimens.brCard,
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 15,
          height: 25 / 15,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _DiagnosisSection extends StatelessWidget {
  const _DiagnosisSection({required this.consultation});

  final Consultation consultation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diagnosis = consultation.diagnosis!;
    final diseaseName = diagnosis.diseaseName.trim().isEmpty
        ? '—'
        : diagnosis.diseaseName.trim();
    final prescription = diagnosis.prescription.trim().isEmpty
        ? '—'
        : diagnosis.prescription.trim();

    return Container(
      padding: const EdgeInsets.all(AppDimens.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimens.brCard,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: AppDimens.brControl,
                ),
                child: const Icon(
                  Icons.medical_information_outlined,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppDimens.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionHeading(title: 'التشخيص'),
                    const SizedBox(height: AppDimens.s4),
                    Text(
                      'صدر بتاريخ ${Formatters.dateTime(diagnosis.createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.s20),
          Text(
            diseaseName,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimens.s20),
          Container(
            padding: const EdgeInsets.all(AppDimens.s16),
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: AppDimens.brControl,
              border: Border.fromBorderSide(
                BorderSide(color: AppColors.divider),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.medication_outlined,
                      size: 20,
                      color: AppColors.onPrimarySoft,
                    ),
                    const SizedBox(width: AppDimens.s8),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          'العلاج / الوصفة',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.onPrimarySoft,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.s8),
                Text(
                  prescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 15,
                    height: 25 / 15,
                    color: AppColors.textPrimary,
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

class _ReviewState extends StatelessWidget {
  const _ReviewState({required this.status});

  final ConsultationStatus status;

  @override
  Widget build(BuildContext context) {
    final inReview = status == ConsultationStatus.inReview;
    final title = inReview ? 'طلبك قيد المراجعة' : 'طلبك بانتظار المراجعة';
    final message = inReview
        ? 'يراجع الطبيب تفاصيل حالتك الطبية.'
        : 'تم استلام استشارتك وستظهر النتيجة هنا بعد المراجعة.';

    return _CalmStateSurface(
      icon: inReview ? Icons.manage_search_rounded : Icons.schedule_outlined,
      title: title,
      message: message,
      background: inReview ? AppColors.infoSoft : AppColors.warningSoft,
      foreground: inReview ? AppColors.info : AppColors.warning,
    );
  }
}

class _CancelledState extends StatelessWidget {
  const _CancelledState();

  @override
  Widget build(BuildContext context) {
    return const _CalmStateSurface(
      icon: Icons.cancel_outlined,
      title: 'الاستشارة ملغاة',
      message: 'تم إلغاء هذه الاستشارة، ولا توجد إجراءات مطلوبة.',
      background: AppColors.surfaceSubtle,
      foreground: AppColors.textSecondary,
    );
  }
}

class _CalmStateSurface extends StatelessWidget {
  const _CalmStateSurface({
    required this.icon,
    required this.title,
    required this.message,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      label: '$title. $message',
      child: ExcludeSemantics(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimens.s16),
          decoration: BoxDecoration(
            color: background,
            borderRadius: AppDimens.brControl,
            border: Border.all(color: foreground.withValues(alpha: 0.20)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 24, color: foreground),
              const SizedBox(width: AppDimens.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimens.s4),
                    Text(
                      message,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
