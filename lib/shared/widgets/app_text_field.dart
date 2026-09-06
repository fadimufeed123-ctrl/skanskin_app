import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';

/// Mobile counterpart of the MVC `form-control bg-body-tertiary` treatment.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.hint,
    this.helperText,
    this.errorText,
    this.icon,
    this.obscure = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.autofillHints,
    this.textDirection,
  });

  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final IconData? icon;
  final bool obscure;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLength;
  final int maxLines;
  final int? minLines;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final List<String>? autofillHints;
  final TextDirection? textDirection;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscure;

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscure != widget.obscure) {
      _obscured = widget.obscure;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasError = widget.errorText?.isNotEmpty ?? false;

    final fillColor = switch ((hasError, widget.enabled)) {
      (true, _) => AppColors.errorSoft,
      (false, false) => AppColors.surfaceSubtle,
      _ => AppColors.surfaceSubtle,
    };
    final borderColor = switch ((hasError, widget.enabled)) {
      (true, _) => AppColors.error,
      (false, false) => AppColors.divider,
      _ => AppColors.controlBorder,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: widget.enabled
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimens.s8),
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          obscureText: _obscured,
          autocorrect: !widget.obscure,
          enableSuggestions: !widget.obscure,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          maxLength: widget.maxLength,
          maxLines: _obscured ? 1 : widget.maxLines,
          minLines: widget.minLines,
          inputFormatters: widget.inputFormatters,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          autofillHints: widget.autofillHints,
          textDirection: widget.textDirection,
          cursorColor: AppColors.primary,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 15,
            height: 23 / 15,
            color: widget.enabled
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: widget.hint,
            filled: true,
            fillColor: fillColor,
            prefixIcon: widget.icon == null
                ? null
                : Icon(widget.icon, size: 20, color: AppColors.textSecondary),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
            suffixIcon: widget.obscure
                ? IconButton(
                    tooltip: _obscured
                        ? 'إظهار كلمة المرور'
                        : 'إخفاء كلمة المرور',
                    icon: Icon(
                      _obscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: widget.enabled
                        ? () => setState(() => _obscured = !_obscured)
                        : null,
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimens.s16,
              vertical: AppDimens.s16,
            ),
            border: OutlineInputBorder(
              borderRadius: AppDimens.brControl,
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppDimens.brControl,
              borderSide: BorderSide(color: borderColor),
            ),
            disabledBorder: const OutlineInputBorder(
              borderRadius: AppDimens.brControl,
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppDimens.brControl,
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppDimens.s8),
          Semantics(
            liveRegion: true,
            label: 'خطأ في ${widget.label}: ${widget.errorText!}',
            child: ExcludeSemantics(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 16,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(width: AppDimens.s8),
                  Expanded(
                    child: Text(
                      widget.errorText!,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else if (widget.helperText != null) ...[
          const SizedBox(height: AppDimens.s8),
          Text(
            widget.helperText!,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
