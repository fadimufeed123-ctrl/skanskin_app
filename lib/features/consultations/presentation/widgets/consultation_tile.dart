import 'package:flutter/material.dart';
import 'package:skanskin_app/core/theme/app_colors.dart';
import 'package:skanskin_app/core/theme/app_dimens.dart';
import 'package:skanskin_app/core/utils/formatters.dart';
import 'package:skanskin_app/features/consultations/data/models/consultation.dart';
import 'package:skanskin_app/shared/widgets/app_skeleton.dart';
import 'package:skanskin_app/shared/widgets/skin_image.dart';
import 'package:skanskin_app/shared/widgets/status_pill.dart';

/// A calm, scan-friendly consultation row shared by Home and the full list.
class ConsultationTile extends StatelessWidget {
  const ConsultationTile({
    super.key,
    required this.consultation,
    this.onTap,
    this.showSymptoms = true,
  });

  final ConsultationSummary consultation;
  final VoidCallback? onTap;
  final bool showSymptoms;

  @override
  Widget build(BuildContext context) {
    final doctor =
        (consultation.doctorName == null ||
            consultation.doctorName!.trim().isEmpty)
        ? 'لم يُسنَد بعد'
        : consultation.doctorName!.trim();
    final idText = Formatters.toArabicDigits('${consultation.id}');
    final relativeDate = Formatters.relative(consultation.createdAt);

    final row = Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        overlayColor: WidgetStatePropertyAll(
          AppColors.primary.withValues(alpha: 0.08),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.s16,
            vertical: AppDimens.s16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MonogramAvatar(monogram: _monogramFor(doctor), size: 40),
                  const SizedBox(width: AppDimens.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: AppDimens.s4),
                        Text(
                          'استشارة #$idText',
                          textDirection: TextDirection.rtl,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.s8),
                  Flexible(
                    child: Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: StatusPill(consultation.status),
                    ),
                  ),
                ],
              ),
              if (showSymptoms && consultation.symptoms.trim().isNotEmpty) ...[
                const SizedBox(height: AppDimens.s12),
                Text(
                  consultation.symptoms.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: AppDimens.s12),
              Wrap(
                spacing: AppDimens.s16,
                runSpacing: AppDimens.s4,
                children: [
                  _Metadata(icon: Icons.schedule_rounded, label: relativeDate),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (onTap == null) return row;

    return Semantics(
      container: true,
      button: true,
      onTap: onTap,
      label:
          'فتح تفاصيل الاستشارة رقم $idText، الطبيب $doctor، الحالة ${consultation.status.label}، $relativeDate',
      child: ExcludeSemantics(child: row),
    );
  }
}

String _monogramFor(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty || trimmed == 'لم يُسنَد بعد') return '؟';
  final parts = trimmed.split(RegExp(r'\s+'));
  final meaningful = parts.where((part) => !part.contains('.')).toList();
  final source = meaningful.isEmpty ? parts : meaningful;
  return source.take(2).map((part) => part.substring(0, 1)).join();
}

class _Metadata extends StatelessWidget {
  const _Metadata({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Icon(icon, size: 16, color: AppColors.textSecondary),
          ),
          TextSpan(text: '  $label'),
        ],
      ),
      style: Theme.of(
        context,
      ).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
    );
  }
}

/// Loading placeholder with the same visual footprint as [ConsultationTile].
class ConsultationTileSkeleton extends StatelessWidget {
  const ConsultationTileSkeleton({super.key, this.showSymptoms = true});

  final bool showSymptoms;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: _ConsultationTileSkeletonContent(showSymptoms: showSymptoms),
    );
  }
}

class _ConsultationTileSkeletonContent extends StatelessWidget {
  const _ConsultationTileSkeletonContent({required this.showSymptoms});

  final bool showSymptoms;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.s16,
        vertical: AppDimens.s16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Skeleton(
                height: 40,
                width: 40,
                borderRadius: AppDimens.brControl,
              ),
              SizedBox(width: AppDimens.s12),
              Expanded(child: Skeleton(height: 16, width: 144)),
              SizedBox(width: AppDimens.s12),
              Skeleton(height: 28, width: 104, borderRadius: AppDimens.brFull),
            ],
          ),
          if (showSymptoms) ...[
            const SizedBox(height: AppDimens.s12),
            const Skeleton(height: 13, width: double.infinity),
            const SizedBox(height: AppDimens.s4),
            const Skeleton(height: 13, width: 168),
          ],
          const SizedBox(height: AppDimens.s12),
          const Skeleton(height: 12, width: 120),
        ],
      ),
    );
  }
}
