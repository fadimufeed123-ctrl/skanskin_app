import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skanskin_app/app/providers.dart';
import 'package:skanskin_app/app/routes.dart';
import 'package:skanskin_app/core/network/api_exception.dart';
import 'package:skanskin_app/core/theme/app_colors.dart';
import 'package:skanskin_app/core/theme/app_dimens.dart';
import 'package:skanskin_app/core/utils/formatters.dart';
import 'package:skanskin_app/core/utils/validators.dart';
import 'package:skanskin_app/features/doctors/data/models/doctor.dart';
import 'package:skanskin_app/features/doctors/state/doctors_providers.dart';
import 'package:skanskin_app/features/consultations/state/consultations_providers.dart';
import 'package:skanskin_app/shared/widgets/app_button.dart';
import 'package:skanskin_app/shared/widgets/app_skeleton.dart';
import 'package:skanskin_app/shared/widgets/app_states.dart';
import 'package:skanskin_app/shared/widgets/app_text_field.dart';
import 'package:skanskin_app/shared/widgets/mobile_top_bar.dart';
import 'package:skanskin_app/shared/widgets/skin_image.dart';

/// Three-step wizard for creating a consultation:
///   1. choose a doctor, 2. add a skin image, 3. describe symptoms & submit.
/// Submission uploads the image, creates the consultation, then confirms.
class CreateConsultationScreen extends ConsumerStatefulWidget {
  const CreateConsultationScreen({super.key});

  @override
  ConsumerState<CreateConsultationScreen> createState() =>
      _CreateConsultationScreenState();
}

class _CreateConsultationScreenState
    extends ConsumerState<CreateConsultationScreen> {
  int _step = 0;

  Doctor? _doctor;
  String _doctorQuery = '';

  File? _image;

  final _symptomsController = TextEditingController();
  bool _symptomsTouched = false;

  bool _submitting = false;

  static const _titles = [
    'اختيار الطبيب',
    'إضافة صورة الحالة',
    'مراجعة وإرسال',
  ];
  static const _stepLabels = ['الطبيب', 'الصورة', 'المراجعة'];
  static const _stepDescriptions = [
    'اختر الطبيب المناسب لمراجعة حالتك.',
    'أضف صورة واضحة للمنطقة المصابة.',
    'صف الأعراض، ثم راجع التفاصيل قبل الإرسال.',
  ];

  @override
  void initState() {
    super.initState();
    _symptomsController.addListener(_onSymptomsChanged);
  }

  @override
  void dispose() {
    _symptomsController.removeListener(_onSymptomsChanged);
    _symptomsController.dispose();
    super.dispose();
  }

  void _onSymptomsChanged() => setState(() {});

  void _back() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_step > 0) {
      setState(() => _step -= 1);
    } else {
      context.pop();
    }
  }

  void _goToStep(int step) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _step = step);
  }

  Future<void> _openImageSource() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ImageSourceSheet(),
    );
    if (source != null) await _pickImage(source);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (picked == null) return;
      setState(() => _image = File(picked.path));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذّر الوصول إلى الصورة. تحقق من الأذونات.'),
          ),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _symptomsTouched = true);

    final symptomsError = Validators.symptoms(_symptomsController.text);
    if (symptomsError != null) return;

    final doctor = _doctor;
    final image = _image;
    final session = ref.read(authControllerProvider).session;

    if (doctor == null) {
      _showError('يرجى تحديد الطبيب أولاً');
      return;
    }
    if (image == null) {
      _showError('يرجى اختيار صورة للتحليل');
      return;
    }
    if (session == null) {
      _showError('جلسة المستخدم غير صالحة، يرجى إعادة تسجيل الدخول');
      return;
    }

    setState(() => _submitting = true);

    try {
      final imagePath = await ref
          .read(filesRepositoryProvider)
          .uploadImage(image);

      final created = await ref
          .read(consultationsRepositoryProvider)
          .create(
            patientId: session.patientId,
            doctorId: doctor.id,
            imagePath: imagePath,
            symptoms: _symptomsController.text.trim(),
          );

      ref.invalidate(consultationsListProvider);

      if (mounted) {
        setState(() => _submitting = false);
        _showSuccess(created.id, doctor.fullName);
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        _showError(e.message);
      }
    } catch (e, st) {
      debugPrint('=== REAL ERROR: $e');
      debugPrint('=== STACKTRACE: $st');
      if (mounted) {
        setState(() => _submitting = false);
        _showError('تعذّر إرسال الاستشارة حاليًا. يرجى المحاولة مرة أخرى.');
      }
    }
  }

  void _showSuccess(int id, String doctorName) {
    final idText = Formatters.toArabicDigits('$id');
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ResultDialog(
        icon: Icons.check_circle_outline_rounded,
        accent: AppColors.success,
        accentSoft: AppColors.successSoft,
        title: 'تم إرسال الاستشارة بنجاح',
        message:
            'سيراجع $doctorName حالتك ويزوّدك بالتشخيص قريبًا. يمكنك متابعة حالتها من قائمة استشاراتك.',
        chipLabel: 'رقم الاستشارة: #$idText',
        primaryLabel: 'عرض التفاصيل',
        secondaryLabel: 'للرئيسية',
        onPrimary: () {
          Navigator.of(ctx).pop();
          context.pushReplacement(Routes.consultationDetailOf(id));
        },
        onSecondary: () {
          Navigator.of(ctx).pop();
          context.go(Routes.home);
        },
      ),
    );
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _ResultDialog(
        icon: Icons.error_outline_rounded,
        accent: AppColors.destructive,
        accentSoft: AppColors.destructiveSoft,
        title: 'تعذّر إرسال الاستشارة',
        message: message,
        primaryLabel: 'إعادة المحاولة',
        secondaryLabel: 'إغلاق',
        onPrimary: () {
          Navigator.of(ctx).pop();
          _submit();
        },
        onSecondary: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_submitting,
      child: Scaffold(
        backgroundColor: AppColors.primarySoft,
        appBar: MobileTopBar(
          title: _titles[_step],
          showBack: !_submitting,
          onBack: _back,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalInset =
                constraints.maxWidth > AppDimens.maxContentWidth
                ? (constraints.maxWidth - AppDimens.maxContentWidth) / 2
                : 0.0;

            return Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalInset),
                    child: _buildStep(),
                  ),
                ),
                if (_submitting) const _SubmittingOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      0 => _DoctorStep(
        selected: _doctor,
        query: _doctorQuery,
        onQuery: (q) => setState(() => _doctorQuery = q),
        onSelect: (d) => setState(() => _doctor = d),
        onNext: () => _goToStep(1),
      ),
      1 => _ImageStep(
        image: _image,
        onAdd: _openImageSource,
        onRemove: () => setState(() => _image = null),
        onNext: () => _goToStep(2),
      ),
      _ => _SymptomsStep(
        controller: _symptomsController,
        touched: _symptomsTouched,
        doctor: _doctor,
        image: _image,
        submitting: _submitting,
        onBack: () => _goToStep(1),
        onSubmit: _submit,
      ),
    };
  }
}

String _fileName(File f) =>
    f.uri.pathSegments.isNotEmpty ? f.uri.pathSegments.last : 'image.jpg';

/// Compact progress treatment shared by the three existing steps.
class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.step});
  final int step; // 0-based

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentStep = Formatters.toArabicDigits('${step + 1}');

    return Semantics(
      container: true,
      label:
          'الخطوة $currentStep من ٣، ${_CreateConsultationScreenState._stepLabels[step]}',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _CreateConsultationScreenState._stepLabels[step],
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Text(
                  '$currentStep / ٣',
                  textDirection: TextDirection.ltr,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.s12),
            ClipRRect(
              borderRadius: AppDimens.brFull,
              child: LinearProgressIndicator(
                value: (step + 1) / 3,
                minHeight: AppDimens.s4,
                backgroundColor: AppColors.divider,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimens.s12),
            Text(
              _CreateConsultationScreenState._stepDescriptions[step],
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 1: doctor selection ────────────────────────────────────────────────
class _DoctorStep extends ConsumerWidget {
  const _DoctorStep({
    required this.selected,
    required this.query,
    required this.onQuery,
    required this.onSelect,
    required this.onNext,
  });

  final Doctor? selected;
  final String query;
  final ValueChanged<String> onQuery;
  final ValueChanged<Doctor> onSelect;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(availableDoctorsProvider);
    final gutter = AppDimens.pageGutterFor(context);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(gutter, AppDimens.s16, gutter, 0),
          child: Column(
            children: [
              const _StepHeader(step: 0),
              const SizedBox(height: AppDimens.s20),
              _SearchBox(hint: 'ابحث بالاسم أو التخصص…', onChanged: onQuery),
              const SizedBox(height: AppDimens.s16),
            ],
          ),
        ),
        Expanded(
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppDimens.brSheetTop,
              boxShadow: [
                BoxShadow(
                  color: AppColors.panelShadow,
                  blurRadius: 22,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: async.when(
              loading: () => _DoctorListSurface(
                gutter: gutter,
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: 3,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    indent: AppDimens.s16,
                    endIndent: AppDimens.s16,
                  ),
                  itemBuilder: (_, _) => const _DoctorRowSkeleton(),
                ),
              ),
              error: (error, _) => AppError(
                message: error is ApiException
                    ? error.message
                    : 'تعذّر تحميل قائمة الأطباء.',
                onRetry: () => ref.invalidate(availableDoctorsProvider),
              ),
              data: (doctors) {
                final normalizedQuery = query.trim().toLowerCase();
                final filtered = normalizedQuery.isEmpty
                    ? doctors
                    : doctors
                          .where(
                            (doctor) =>
                                doctor.fullName.toLowerCase().contains(
                                  normalizedQuery,
                                ) ||
                                doctor.specialization.toLowerCase().contains(
                                  normalizedQuery,
                                ),
                          )
                          .toList(growable: false);

                if (doctors.isEmpty) {
                  return AppEmpty(
                    icon: Icons.person_search_outlined,
                    title: 'لا يوجد أطباء متاحون حاليًا',
                    message: 'حاول تحديث القائمة بعد قليل.',
                    actionLabel: 'إعادة المحاولة',
                    actionIcon: Icons.refresh_rounded,
                    onAction: () => ref.invalidate(availableDoctorsProvider),
                  );
                }
                if (filtered.isEmpty) {
                  return const AppEmpty(
                    icon: Icons.search_off_rounded,
                    title: 'لا توجد نتائج',
                    message: 'جرّب البحث باسم أو تخصص آخر.',
                  );
                }

                return _DoctorListSurface(
                  gutter: gutter,
                  child: ListView.separated(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.zero,
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      indent: AppDimens.s16,
                      endIndent: AppDimens.s16,
                    ),
                    itemBuilder: (context, index) {
                      final doctor = filtered[index];
                      return _DoctorRow(
                        doctor: doctor,
                        selected: selected?.id == doctor.id,
                        onTap: () => onSelect(doctor),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
        _BottomBar(
          child: AppButton(
            label: 'التالي · إضافة صورة',
            full: true,
            size: AppButtonSize.lg,
            enabled: selected != null,
            onPressed: onNext,
          ),
        ),
      ],
    );
  }
}

class _DoctorRow extends StatelessWidget {
  const _DoctorRow({
    required this.doctor,
    required this.selected,
    required this.onTap,
  });

  final Doctor doctor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final experience = doctor.yearsOfExperience > 0
        ? '${Formatters.toArabicDigits('${doctor.yearsOfExperience}')} سنوات خبرة'
        : null;
    final semanticLabel = [
      doctor.fullName,
      doctor.specialization,
      if (experience != null) experience,
    ].join('، ');

    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      onTap: onTap,
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: selected ? AppColors.surfaceTint : AppColors.surface,
            borderRadius: AppDimens.brControl,
            border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: AppDimens.brControl,
            child: InkWell(
              onTap: onTap,
              borderRadius: AppDimens.brControl,
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.s16),
                child: Row(
                  children: [
                    MonogramAvatar(
                      monogram: doctor.monogram,
                      imageUrl: doctor.imageUrl,
                      size: 56,
                    ),
                    const SizedBox(width: AppDimens.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.fullName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppDimens.s4),
                          Text(
                            doctor.specialization,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (experience != null) ...[
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
                                    experience,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimens.s8),
                    _SelectionIndicator(selected: selected),
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

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 160),
      height: 28,
      width: 28,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.controlBorder,
          width: 1.5,
        ),
      ),
      child: selected
          ? const Icon(
              Icons.check_rounded,
              size: 18,
              color: AppColors.primaryForeground,
            )
          : null,
    );
  }
}

class _DoctorRowSkeleton extends StatelessWidget {
  const _DoctorRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'جارٍ تحميل بيانات الطبيب',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(AppDimens.s16),
          color: AppColors.surface,
          child: const Row(
            children: [
              Skeleton(
                height: 56,
                width: 56,
                borderRadius: AppDimens.brControl,
              ),
              SizedBox(width: AppDimens.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(height: 16, width: 156),
                    SizedBox(height: AppDimens.s8),
                    Skeleton(height: 13, width: 112),
                    SizedBox(height: AppDimens.s8),
                    Skeleton(height: 12, width: 88),
                  ],
                ),
              ),
              SizedBox(width: AppDimens.s8),
              Skeleton(height: 28, width: 28, borderRadius: AppDimens.brFull),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorListSurface extends StatelessWidget {
  const _DoctorListSurface({required this.gutter, required this.child});

  final double gutter;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        gutter,
        AppDimens.s20,
        gutter,
        AppDimens.s16,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppDimens.brCard,
          border: Border.all(color: AppColors.divider),
        ),
        child: ClipRRect(borderRadius: AppDimens.brCard, child: child),
      ),
    );
  }
}

// ── Step 2: image ───────────────────────────────────────────────────────────
class _ImageStep extends StatelessWidget {
  const _ImageStep({
    required this.image,
    required this.onAdd,
    required this.onRemove,
    required this.onNext,
  });

  final File? image;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final gutter = AppDimens.pageGutterFor(context);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            gutter,
            AppDimens.s16,
            gutter,
            AppDimens.s20,
          ),
          child: const _StepHeader(step: 1),
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
                  blurRadius: 22,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                gutter,
                AppDimens.s24,
                gutter,
                AppDimens.s16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (image == null)
                    _ImageDropTarget(onAdd: onAdd)
                  else
                    _ImagePreview(image: image!, onRemove: onRemove),
                  const SizedBox(height: AppDimens.s16),
                  const _ImageTip(),
                ],
              ),
            ),
          ),
        ),
        _BottomBar(
          child: image == null
              ? AppButton(
                  label: 'إضافة صورة',
                  full: true,
                  size: AppButtonSize.lg,
                  icon: Icons.add_a_photo_outlined,
                  onPressed: onAdd,
                )
              : _AdaptiveActionPair(
                  secondaryLabel: 'استبدال الصورة',
                  secondaryIcon: Icons.photo_library_outlined,
                  onSecondary: onAdd,
                  primaryLabel: 'التالي · المراجعة',
                  onPrimary: onNext,
                ),
        ),
      ],
    );
  }
}

class _ImageDropTarget extends StatelessWidget {
  const _ImageDropTarget({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: 'اختيار صورة للمنطقة المصابة',
      hint: 'يفتح خيارات الكاميرا أو معرض الصور',
      onTap: onAdd,
      child: ExcludeSemantics(
        child: Material(
          color: AppColors.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimens.brCard,
            side: BorderSide(color: AppColors.controlBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onAdd,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 200),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.s20,
                  vertical: AppDimens.s32,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 56,
                      width: 56,
                      decoration: const BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: AppDimens.brControl,
                      ),
                      child: const Icon(
                        Icons.add_a_photo_outlined,
                        size: 28,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppDimens.s16),
                    Text(
                      'أضف صورة للمنطقة المصابة',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimens.s8),
                    Text(
                      'اختر صورة واضحة من الكاميرا أو معرض الصور',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimens.s16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: AppDimens.s8,
                      runSpacing: AppDimens.s8,
                      children: const [
                        _ImageMetaLabel(
                          icon: Icons.image_outlined,
                          label: 'JPG، PNG أو WEBP',
                        ),
                        _ImageMetaLabel(
                          icon: Icons.data_usage_rounded,
                          label: 'حتى ٥ MB',
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.s16),
                    Text(
                      'تُستخدم الصورة لمراجعة حالتك الطبية',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
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

class _ImageMetaLabel extends StatelessWidget {
  const _ImageMetaLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.s12,
          vertical: AppDimens.s8,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surfaceSubtle,
          borderRadius: AppDimens.brFull,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: AppDimens.s4),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.image, required this.onRemove});
  final File image;
  final VoidCallback onRemove;

  String get _sizeLabel {
    try {
      final mb = image.lengthSync() / (1024 * 1024);
      return Formatters.toArabicDigits('${mb.toStringAsFixed(1)}MB');
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final caption = [
      _fileName(image),
      if (_sizeLabel.isNotEmpty) _sizeLabel,
    ].join(' · ');
    return Semantics(
      image: true,
      label: 'معاينة الصورة المختارة، $caption',
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppDimens.brCard,
          border: Border.all(color: AppColors.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: kIsWeb
                      ? Image.network(
                          image.path,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          image,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                PositionedDirectional(
                  top: AppDimens.s8,
                  start: AppDimens.s8,
                  child: Semantics(
                    button: true,
                    label: 'حذف الصورة المختارة',
                    onTap: onRemove,
                    child: ExcludeSemantics(
                      child: IconButton(
                        onPressed: onRemove,
                        tooltip: 'حذف الصورة',
                        style: IconButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          backgroundColor: AppColors.surface,
                          foregroundColor: AppColors.error,
                        ),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimens.s12),
              child: Row(
                children: [
                  const Icon(
                    Icons.image_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppDimens.s8),
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        _fileName(image),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  if (_sizeLabel.isNotEmpty) ...[
                    const SizedBox(width: AppDimens.s8),
                    Text(
                      _sizeLabel,
                      textDirection: TextDirection.ltr,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
    );
  }
}

class _ImageTip extends StatelessWidget {
  const _ImageTip();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.s16),
      decoration: BoxDecoration(
        color: AppColors.infoSoft,
        borderRadius: AppDimens.brControl,
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 20, color: AppColors.info),
          SizedBox(width: AppDimens.s12),
          Expanded(
            child: Text(
              'تأكد أن الصورة واضحة وتُظهر المنطقة المصابة بإضاءة كافية.',
              style: TextStyle(
                fontSize: 13,
                height: 21 / 13,
                color: AppColors.infoText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 3: symptoms ────────────────────────────────────────────────────────
class _SymptomsStep extends StatelessWidget {
  const _SymptomsStep({
    required this.controller,
    required this.touched,
    required this.doctor,
    required this.image,
    required this.submitting,
    required this.onBack,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool touched;
  final Doctor? doctor;
  final File? image;
  final bool submitting;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final text = controller.text;
    final length = text.characters.length;
    final error = touched ? Validators.symptoms(text) : null;
    final isValid = Validators.symptoms(text) == null;
    final gutter = AppDimens.pageGutterFor(context);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            gutter,
            AppDimens.s16,
            gutter,
            AppDimens.s20,
          ),
          child: const _StepHeader(step: 2),
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
                  blurRadius: 22,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                gutter,
                AppDimens.s24,
                gutter,
                AppDimens.s24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SymptomsField(
                    controller: controller,
                    length: length,
                    isValid: isValid,
                    error: error,
                  ),
                  const SizedBox(height: AppDimens.s32),
                  Text(
                    'راجع الاستشارة',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimens.s4),
                  Text(
                    'تأكد من الطبيب والصورة ووصف الأعراض قبل الإرسال.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimens.s12),
                  _ReviewSummary(
                    doctor: doctor,
                    image: image,
                    symptoms: text.trim(),
                  ),
                ],
              ),
            ),
          ),
        ),
        _BottomBar(
          child: _AdaptiveActionPair(
            secondaryLabel: 'السابق',
            secondaryIcon: Icons.arrow_forward_rounded,
            secondaryEnabled: !submitting,
            onSecondary: onBack,
            primaryLabel: 'إرسال الاستشارة',
            primaryIcon: Icons.send_outlined,
            primaryLoading: submitting,
            onPrimary: onSubmit,
          ),
        ),
      ],
    );
  }
}

class _SymptomsField extends StatelessWidget {
  const _SymptomsField({
    required this.controller,
    required this.length,
    required this.isValid,
    required this.error,
  });

  final TextEditingController controller;
  final int length;
  final bool isValid;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'وصف الأعراض *',
          controller: controller,
          hint: 'مثال: ظهور بقع حمراء في الذراع مصحوبة بحكة منذ ٣ أيام…',
          helperText: 'اذكر متى بدأت الأعراض وأي تغيرات لاحظتها.',
          errorText: error,
          maxLines: 7,
          minLines: 5,
          maxLength: Validators.symptomsMax,
          textInputAction: TextInputAction.newline,
          keyboardType: TextInputType.multiline,
        ),
        const SizedBox(height: AppDimens.s8),
        LayoutBuilder(
          builder: (context, constraints) {
            final textScale = MediaQuery.textScalerOf(context).scale(1);
            final stack = constraints.maxWidth < 300 || textScale > 1.3;
            final counter = Semantics(
              label:
                  '${Formatters.toArabicDigits('$length')} حرف من ${Formatters.toArabicDigits('${Validators.symptomsMax}')}',
              child: ExcludeSemantics(
                child: Text(
                  '${Formatters.counter(length, Validators.symptomsMax)} حرف',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: error == null
                        ? AppColors.textSecondary
                        : AppColors.error,
                  ),
                ),
              ),
            );
            final validLabel = isValid
                ? Text(
                    '✓ الوصف مكتمل',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null;

            if (stack) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  counter,
                  if (validLabel != null) ...[
                    const SizedBox(height: AppDimens.s4),
                    validLabel,
                  ],
                ],
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [counter, if (validLabel != null) validLabel],
            );
          },
        ),
      ],
    );
  }
}

class _ReviewSummary extends StatelessWidget {
  const _ReviewSummary({
    required this.doctor,
    required this.image,
    required this.symptoms,
  });

  final Doctor? doctor;
  final File? image;
  final String symptoms;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimens.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimens.brCard,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ReviewSectionLabel(label: 'الطبيب'),
          const SizedBox(height: AppDimens.s8),
          Row(
            children: [
              MonogramAvatar(
                monogram: doctor?.monogram ?? '؟',
                imageUrl: doctor?.imageUrl ?? '',
                size: 48,
              ),
              const SizedBox(width: AppDimens.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor?.fullName ?? '—',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimens.s4),
                    Text(
                      doctor?.specialization ?? '—',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: AppDimens.s32),
          const _ReviewSectionLabel(label: 'صورة الحالة'),
          const SizedBox(height: AppDimens.s8),
          if (image == null)
            Text('—', style: theme.textTheme.bodyMedium)
          else
            Row(
              children: [
                ClipRRect(
                  borderRadius: AppDimens.brSmall,
                  child: SizedBox(
                    height: 72,
                    width: 72,
                    child: kIsWeb
                        ? Image.network(image!.path, fit: BoxFit.cover)
                        : Image.file(image!, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: AppDimens.s12),
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      _fileName(image!),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          const Divider(height: AppDimens.s32),
          const _ReviewSectionLabel(label: 'وصف الأعراض'),
          const SizedBox(height: AppDimens.s8),
          Text(
            symptoms.isEmpty ? 'لم يُضف الوصف بعد.' : symptoms,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: symptoms.isEmpty
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewSectionLabel extends StatelessWidget {
  const _ReviewSectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

// ── Shared bits ─────────────────────────────────────────────────────────────
class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.hint, required this.onChanged});
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: 'البحث عن طبيب',
      child: TextField(
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 15,
          height: 23 / 15,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: AppColors.surfaceSubtle,
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: AppColors.textSecondary,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: AppDimens.s16,
            horizontal: AppDimens.s16,
          ),
          border: const OutlineInputBorder(
            borderRadius: AppDimens.brControl,
            borderSide: BorderSide(color: AppColors.controlBorder),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: AppDimens.brControl,
            borderSide: BorderSide(color: AppColors.controlBorder),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: AppDimens.brControl,
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final gutter = AppDimens.pageGutterFor(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            gutter,
            AppDimens.s12,
            gutter,
            AppDimens.s12,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _AdaptiveActionPair extends StatelessWidget {
  const _AdaptiveActionPair({
    required this.secondaryLabel,
    required this.onSecondary,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryIcon,
    this.primaryIcon,
    this.secondaryEnabled = true,
    this.primaryLoading = false,
  });

  final String secondaryLabel;
  final VoidCallback onSecondary;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final IconData? secondaryIcon;
  final IconData? primaryIcon;
  final bool secondaryEnabled;
  final bool primaryLoading;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final stackActions = constraints.maxWidth < 330 || textScale > 1.3;

        final secondary = AppButton(
          label: secondaryLabel,
          full: stackActions,
          variant: AppButtonVariant.outline,
          size: AppButtonSize.lg,
          icon: secondaryIcon,
          enabled: secondaryEnabled,
          onPressed: onSecondary,
        );
        final primary = AppButton(
          label: primaryLabel,
          full: stackActions,
          size: AppButtonSize.lg,
          icon: primaryIcon,
          loading: primaryLoading,
          onPressed: onPrimary,
        );

        if (stackActions) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              primary,
              const SizedBox(height: AppDimens.s8),
              secondary,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: secondary),
            const SizedBox(width: AppDimens.s12),
            Expanded(child: primary),
          ],
        );
      },
    );
  }
}

class _ImageSourceSheet extends StatelessWidget {
  const _ImageSourceSheet();

  @override
  Widget build(BuildContext context) {
    final gutter = AppDimens.pageGutterFor(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.rDialog),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            gutter,
            AppDimens.s12,
            gutter,
            AppDimens.s16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: AppDimens.brFull,
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.s16),
              Text(
                'إضافة صورة',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppDimens.s4),
              Text(
                'اختر مصدر الصورة',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimens.s16),
              Row(
                children: [
                  Expanded(
                    child: _SourceButton(
                      icon: Icons.photo_camera_outlined,
                      label: 'الكاميرا',
                      onTap: () =>
                          Navigator.of(context).pop(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: AppDimens.s12),
                  Expanded(
                    child: _SourceButton(
                      icon: Icons.photo_library_outlined,
                      label: 'المعرض',
                      onTap: () =>
                          Navigator.of(context).pop(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.s12),
              AppButton(
                label: 'إلغاء',
                full: true,
                variant: AppButtonVariant.ghost,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      child: ExcludeSemantics(
        child: Material(
          color: AppColors.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimens.brCard,
            side: BorderSide(color: AppColors.divider),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimens.s16),
              child: Column(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: AppDimens.brControl,
                    ),
                    child: Icon(icon, size: 22, color: AppColors.primary),
                  ),
                  const SizedBox(height: AppDimens.s8),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.textPrimary,
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

class _SubmittingOverlay extends StatelessWidget {
  const _SubmittingOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AbsorbPointer(
        child: Semantics(
          container: true,
          liveRegion: true,
          label: 'جارٍ إرسال الاستشارة',
          child: ColoredBox(
            color: AppColors.textPrimary.withValues(alpha: 0.44),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.s16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimens.s24),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppDimens.brDialog,
                    ),
                    child: ExcludeSemantics(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            height: 40,
                            width: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: AppDimens.s16),
                          Text(
                            'جارٍ إرسال الاستشارة…',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: AppDimens.s4),
                          Text(
                            'قد يستغرق ذلك بضع ثوانٍ',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
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

class _ResultDialog extends StatelessWidget {
  const _ResultDialog({
    required this.icon,
    required this.accent,
    required this.accentSoft,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
    this.chipLabel,
  });

  final IconData icon;
  final Color accent;
  final Color accentSoft;
  final String title;
  final String message;
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;
  final String? chipLabel;

  @override
  Widget build(BuildContext context) {
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
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.s8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (chipLabel != null) ...[
                const SizedBox(height: AppDimens.s12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.s12,
                    vertical: AppDimens.s8,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: AppDimens.brControl,
                  ),
                  child: Text(
                    chipLabel!,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppDimens.s24),
              AppButton(
                label: primaryLabel,
                full: true,
                size: AppButtonSize.lg,
                onPressed: onPrimary,
              ),
              const SizedBox(height: AppDimens.s8),
              AppButton(
                label: secondaryLabel,
                full: true,
                variant: AppButtonVariant.ghost,
                onPressed: onSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
