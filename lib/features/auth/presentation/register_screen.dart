import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skanskin_app/app/providers.dart';
import 'package:skanskin_app/core/network/api_exception.dart';
import 'package:skanskin_app/core/theme/app_colors.dart';
import 'package:skanskin_app/core/theme/app_dimens.dart';
import 'package:skanskin_app/core/utils/validators.dart';
import 'package:skanskin_app/shared/widgets/app_brand.dart';
import 'package:skanskin_app/shared/widgets/app_button.dart';
import 'package:skanskin_app/shared/widgets/app_text_field.dart';
import 'package:skanskin_app/shared/widgets/brand_sheet.dart';
import 'package:skanskin_app/shared/widgets/error_banner.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  final _fullNameFocus = FocusNode(debugLabel: 'register-full-name');
  final _emailFocus = FocusNode(debugLabel: 'register-email');
  final _passwordFocus = FocusNode(debugLabel: 'register-password');
  final _confirmFocus = FocusNode(debugLabel: 'register-confirm-password');
  final _termsFocus = FocusNode(debugLabel: 'register-terms');

  String? _fullNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;
  String? _termsError;
  String? _formError;
  bool _acceptedTerms = false;
  bool _submitting = false;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _fullNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _termsFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;

    FocusManager.instance.primaryFocus?.unfocus();
    final fullNameError = Validators.fullName(_fullName.text);
    final emailError = Validators.email(_email.text);
    final passwordError = Validators.password(_password.text);
    final confirmError = Validators.confirmPassword(
      _confirm.text,
      _password.text,
    );
    setState(() {
      _fullNameError = fullNameError;
      _emailError = emailError;
      _passwordError = passwordError;
      _confirmError = confirmError;
      _formError = null;
      if (_acceptedTerms) _termsError = null;
    });
    if (fullNameError != null ||
        emailError != null ||
        passwordError != null ||
        confirmError != null) {
      _focusFirstError();
      return;
    }
    if (!_acceptedTerms) {
      setState(() {
        _termsError = 'يجب الموافقة على الشروط والأحكام أولًا.';
      });
      _focusFirstError();
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .register(
            fullName: _fullName.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
          );
      // On success the router redirects to /home automatically.
    } on ApiException catch (error) {
      if (!mounted) return;
      final emailFromConflict = error.type == ApiErrorType.conflict
          ? 'هذا البريد الإلكتروني مسجّل بالفعل.'
          : null;
      setState(() {
        _fullNameError =
            error.fieldErrors['FullName'] ?? error.fieldErrors['fullName'];
        _emailError =
            error.fieldErrors['Email'] ??
            error.fieldErrors['email'] ??
            emailFromConflict;
        _passwordError =
            error.fieldErrors['Password'] ?? error.fieldErrors['password'];
        final anyField =
            _fullNameError != null ||
            _emailError != null ||
            _passwordError != null;
        _formError = anyField ? null : error.message;
      });
      _focusFirstError();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _focusFirstError() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_fullNameError != null) {
        _fullNameFocus.requestFocus();
      } else if (_emailError != null) {
        _emailFocus.requestFocus();
      } else if (_passwordError != null) {
        _passwordFocus.requestFocus();
      } else if (_confirmError != null) {
        _confirmFocus.requestFocus();
      } else if (_termsError != null) {
        _termsFocus.requestFocus();
      }
    });
  }

  void _onFullNameChanged(String _) {
    if (_fullNameError == null && _formError == null) return;
    setState(() {
      _fullNameError = null;
      _formError = null;
    });
  }

  void _onEmailChanged(String _) {
    if (_emailError == null && _formError == null) return;
    setState(() {
      _emailError = null;
      _formError = null;
    });
  }

  void _onPasswordChanged(String _) {
    if (_passwordError == null && _formError == null) return;
    setState(() {
      _passwordError = null;
      _formError = null;
    });
  }

  void _onConfirmChanged(String _) {
    if (_confirmError == null) return;
    setState(() => _confirmError = null);
  }

  void _onTermsChanged(bool value) {
    setState(() {
      _acceptedTerms = value;
      if (value) _termsError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gutter = AppDimens.pageGutterFor(context);

    return BrandSheetScaffold(
      headerExtent: 132,
      header: Stack(
        fit: StackFit.expand,
        children: [
          const Center(
            child: AppBrandLockup(logoSize: 48, compact: true, onBrand: true),
          ),
          PositionedDirectional(
            start: AppDimens.s8,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                onPressed: () => context.pop(),
                tooltip: 'رجوع',
                style: IconButton.styleFrom(
                  foregroundColor: AppColors.brandForeground,
                  backgroundColor: Colors.white.withValues(alpha: 0.14),
                ),
                icon: const Icon(Icons.chevron_right_rounded, size: 26),
              ),
            ),
          ),
        ],
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          gutter,
          AppDimens.s32,
          gutter,
          AppDimens.s24,
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    'إنشاء حساب',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.s8),
                Text(
                  'أدخل بياناتك للبدء في طلب استشاراتك الجلدية.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimens.s24),
                AutofillGroup(
                  child: Column(
                    children: [
                      AppTextField(
                        label: 'الاسم الكامل',
                        controller: _fullName,
                        focusNode: _fullNameFocus,
                        hint: 'مثال: سارة أحمد',
                        icon: Icons.person_outline_rounded,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        errorText: _fullNameError,
                        enabled: !_submitting,
                        onSubmitted: (_) => _emailFocus.requestFocus(),
                        onChanged: _onFullNameChanged,
                      ),
                      const SizedBox(height: AppDimens.s16),
                      AppTextField(
                        label: 'البريد الإلكتروني',
                        controller: _email,
                        focusNode: _emailFocus,
                        hint: 'name@example.com',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        textDirection: TextDirection.ltr,
                        autofillHints: const [AutofillHints.email],
                        errorText: _emailError,
                        enabled: !_submitting,
                        onSubmitted: (_) => _passwordFocus.requestFocus(),
                        onChanged: _onEmailChanged,
                      ),
                      const SizedBox(height: AppDimens.s16),
                      AppTextField(
                        label: 'كلمة المرور',
                        controller: _password,
                        focusNode: _passwordFocus,
                        hint: '٨ أحرف على الأقل',
                        icon: Icons.lock_outline_rounded,
                        obscure: true,
                        textInputAction: TextInputAction.next,
                        textDirection: TextDirection.ltr,
                        autofillHints: const [AutofillHints.newPassword],
                        errorText: _passwordError,
                        enabled: !_submitting,
                        onSubmitted: (_) => _confirmFocus.requestFocus(),
                        onChanged: _onPasswordChanged,
                      ),
                      const SizedBox(height: AppDimens.s16),
                      AppTextField(
                        label: 'تأكيد كلمة المرور',
                        controller: _confirm,
                        focusNode: _confirmFocus,
                        icon: Icons.lock_outline_rounded,
                        obscure: true,
                        textInputAction: TextInputAction.done,
                        textDirection: TextDirection.ltr,
                        autofillHints: const [AutofillHints.newPassword],
                        errorText: _confirmError,
                        enabled: !_submitting,
                        onSubmitted: (_) => _submit(),
                        onChanged: _onConfirmChanged,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.s16),
                _TermsCheckbox(
                  value: _acceptedTerms,
                  enabled: !_submitting,
                  focusNode: _termsFocus,
                  errorText: _termsError,
                  onChanged: _onTermsChanged,
                ),
                if (_formError != null) ...[
                  const SizedBox(height: AppDimens.s16),
                  Semantics(
                    container: true,
                    liveRegion: true,
                    label: 'خطأ: ${_formError!}',
                    child: ExcludeSemantics(
                      child: ErrorBanner(message: _formError!),
                    ),
                  ),
                ],
                const SizedBox(height: AppDimens.s24),
                AppButton(
                  label: 'إنشاء الحساب',
                  full: true,
                  size: AppButtonSize.lg,
                  loading: _submitting,
                  enabled: _acceptedTerms,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppDimens.s16),
                _AuthFooterLink(
                  prompt: 'لديك حساب؟',
                  action: 'تسجيل الدخول',
                  enabled: !_submitting,
                  onPressed: () => context.pop(),
                ),
                const SizedBox(height: AppDimens.s20),
                const AppTrustCue(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({
    required this.value,
    required this.onChanged,
    required this.enabled,
    required this.focusNode,
    this.errorText,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;
  final FocusNode focusNode;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = errorText?.isNotEmpty ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CheckboxListTile(
          value: value,
          onChanged: enabled ? (checked) => onChanged(checked ?? false) : null,
          focusNode: focusNode,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimens.s8,
            vertical: AppDimens.s4,
          ),
          activeColor: AppColors.primary,
          checkColor: AppColors.primaryForeground,
          tileColor: hasError ? AppColors.errorSoft : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimens.brControl,
            side: hasError
                ? const BorderSide(color: AppColors.error)
                : BorderSide.none,
          ),
          side: BorderSide(
            color: hasError ? AppColors.error : AppColors.controlBorder,
            width: 1.5,
          ),
          title: Text(
            'أوافق على شروط الاستخدام وسياسة الخصوصية',
            style: theme.textTheme.bodySmall?.copyWith(
              color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppDimens.s8),
          Semantics(
            liveRegion: true,
            label: 'خطأ: $errorText',
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
                      errorText!,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _AuthFooterLink extends StatelessWidget {
  const _AuthFooterLink({
    required this.prompt,
    required this.action,
    required this.enabled,
    required this.onPressed,
  });

  final String prompt;
  final String action;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: TextButton(
        onPressed: enabled ? onPressed : null,
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.s16,
            vertical: AppDimens.s12,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimens.brControl,
          ),
        ),
        child: Text.rich(
          TextSpan(
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            children: [
              TextSpan(text: '$prompt '),
              TextSpan(
                text: action,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize: 14,
                  color: enabled ? AppColors.primary : AppColors.controlBorder,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
