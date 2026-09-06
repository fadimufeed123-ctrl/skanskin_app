import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skanskin_app/app/providers.dart';
import 'package:skanskin_app/app/routes.dart';
import 'package:skanskin_app/core/network/api_exception.dart';
import 'package:skanskin_app/core/theme/app_colors.dart';
import 'package:skanskin_app/core/theme/app_dimens.dart';
import 'package:skanskin_app/core/utils/validators.dart';
import 'package:skanskin_app/shared/widgets/app_brand.dart';
import 'package:skanskin_app/shared/widgets/app_button.dart';
import 'package:skanskin_app/shared/widgets/app_text_field.dart';
import 'package:skanskin_app/shared/widgets/brand_sheet.dart';
import 'package:skanskin_app/shared/widgets/error_banner.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _emailFocus = FocusNode(debugLabel: 'login-email');
  final _passwordFocus = FocusNode(debugLabel: 'login-password');

  String? _emailError;
  String? _passwordError;
  String? _formError;
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;

    FocusManager.instance.primaryFocus?.unfocus();
    final emailError = Validators.email(_email.text);
    final passwordError = Validators.loginPassword(_password.text);
    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      _formError = null;
    });
    if (emailError != null || passwordError != null) {
      _focusFirstError();
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .login(email: _email.text.trim(), password: _password.text);
      // On success the router redirects to /home automatically.
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _emailError = error.fieldErrors['Email'] ?? error.fieldErrors['email'];
        _passwordError =
            error.fieldErrors['Password'] ?? error.fieldErrors['password'];
        _formError = _emailError == null && _passwordError == null
            ? error.message
            : null;
      });
      _focusFirstError();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _focusFirstError() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_emailError != null) {
        _emailFocus.requestFocus();
      } else if (_passwordError != null) {
        _passwordFocus.requestFocus();
      }
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

  @override
  Widget build(BuildContext context) {
    final gutter = AppDimens.pageGutterFor(context);

    return BrandSheetScaffold(
      headerExtent: 188,
      header: const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDimens.s20),
        child: AppBrandLockup(
          logoSize: 72,
          subtitle: 'رعاية جلدية موثوقة أينما كنت',
          onBrand: true,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            gutter,
            AppDimens.s32,
            gutter,
            AppDimens.s24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight > 56
                  ? constraints.maxHeight - 56
                  : 0,
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
                        'مرحبًا بعودتك',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: AppDimens.s8),
                    Text(
                      'سجّل الدخول لمتابعة استشاراتك ونتائجك الطبية.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimens.s24),
                    AutofillGroup(
                      child: Column(
                        children: [
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
                            icon: Icons.lock_outline_rounded,
                            obscure: true,
                            textInputAction: TextInputAction.done,
                            textDirection: TextDirection.ltr,
                            autofillHints: const [AutofillHints.password],
                            errorText: _passwordError,
                            enabled: !_submitting,
                            onSubmitted: (_) => _submit(),
                            onChanged: _onPasswordChanged,
                          ),
                        ],
                      ),
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
                      label: 'تسجيل الدخول',
                      full: true,
                      size: AppButtonSize.lg,
                      loading: _submitting,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: AppDimens.s8),
                    _AuthFooterLink(
                      prompt: 'ليس لديك حساب؟',
                      action: 'إنشاء حساب',
                      enabled: !_submitting,
                      onPressed: () => context.push(Routes.register),
                    ),
                    const SizedBox(height: AppDimens.s20),
                    const AppTrustCue(),
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
