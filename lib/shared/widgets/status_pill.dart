import 'package:flutter/material.dart';
import 'package:skanskin_app/core/theme/app_dimens.dart';
import 'package:skanskin_app/features/consultations/data/models/consultation_status.dart';

/// MVC badge treatment: soft status fill, compact dot, and a textual label.
class StatusPill extends StatelessWidget {
  const StatusPill(this.status, {super.key});

  final ConsultationStatus status;

  @override
  Widget build(BuildContext context) {
    final c = status.colors;
    return Semantics(
      container: true,
      label: 'حالة الاستشارة: ${status.label}',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.s8,
            vertical: AppDimens.s4,
          ),
          decoration: BoxDecoration(
            color: c.bg,
            borderRadius: AppDimens.brFull,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: c.fg, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppDimens.s4),
              Text(
                status.label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontSize: 12,
                  height: 18 / 12,
                  color: c.fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
