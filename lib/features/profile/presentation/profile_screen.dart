import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skanskin_app/app/providers.dart';
import 'package:skanskin_app/app/routes.dart';
import 'package:skanskin_app/core/theme/app_colors.dart';
import 'package:skanskin_app/core/theme/app_dimens.dart';
import 'package:skanskin_app/shared/widgets/app_dialogs.dart';
import 'package:skanskin_app/shared/widgets/skin_image.dart';

/// Profile tab: the signed-in patient's identity, existing account links, and
/// the existing confirmed logout action.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'تسجيل الخروج؟',
      message: 'سيلزم تسجيل الدخول مجددًا للوصول إلى استشاراتك.',
      confirmLabel: 'تسجيل الخروج',
      cancelLabel: 'تراجع',
      destructive: true,
      icon: Icons.logout_rounded,
    );
    if (confirmed) {
      // The router redirects to login automatically once the session clears.
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider.select((s) => s.session));
    final name = session?.fullName.trim() ?? '';
    final email = session?.email.trim() ?? '';
    final displayName = name.isEmpty ? 'مستخدم' : name;
    final monogram = name.isEmpty ? '؟' : name.substring(0, 1);
    final gutter = AppDimens.pageGutterFor(context);

    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _ProfileHeader(
              monogram: monogram,
              name: displayName,
              email: email,
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
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
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.s24),
                  child: Column(
                    children: [
                      const SizedBox(height: AppDimens.s32),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: AppDimens.maxContentWidth,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: gutter),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Semantics(
                                  header: true,
                                  child: Text(
                                    'الحساب',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          color: AppColors.textPrimary,
                                        ),
                                  ),
                                ),
                                const SizedBox(height: AppDimens.s12),
                                _AccountGroup(
                                  children: [
                                    _AccountRow(
                                      icon: Icons.person_outline_rounded,
                                      label: 'معلوماتي الشخصية',
                                      onTap: () =>
                                          context.push(Routes.personalInfo),
                                    ),
                                    _AccountRow(
                                      icon: Icons.assignment_outlined,
                                      label: 'استشاراتي',
                                      onTap: () =>
                                          context.go(Routes.consultations),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppDimens.s24),
                                _LogoutAction(
                                  onTap: () => _confirmLogout(context, ref),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Padding(
                        padding: EdgeInsets.only(top: AppDimens.s32),
                        child: Text(
                          'SkanSkin · الإصدار ١.٠.٠',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.monogram,
    required this.name,
    required this.email,
  });

  final String monogram;
  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    final gutter = AppDimens.pageGutterFor(context);

    return Container(
      width: double.infinity,
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
                AppDimens.s16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'حسابي',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.brandForeground,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.s16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Semantics(
                        image: true,
                        label: 'الصورة الرمزية للمستخدم $name',
                        child: ExcludeSemantics(
                          child: MonogramAvatar(
                            monogram: monogram,
                            size: 56,
                            background: AppColors.surface,
                            foreground: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimens.s16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Semantics(
                              header: true,
                              child: Text(
                                name,
                                softWrap: true,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontSize: 20,
                                      height: 1.5,
                                      color: AppColors.brandForeground,
                                    ),
                              ),
                            ),
                            if (email.isNotEmpty) ...[
                              const SizedBox(height: AppDimens.s4),
                              Text(
                                email,
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.right,
                                softWrap: true,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.brandForeground
                                          .withValues(alpha: 0.82),
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
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

class _AccountGroup extends StatelessWidget {
  const _AccountGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: AppDimens.brCard,
        side: BorderSide(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
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

class _AccountRow extends StatelessWidget {
  const _AccountRow({
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
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.s16,
                vertical: AppDimens.s8,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: AppDimens.brControl,
                    ),
                    child: Icon(icon, size: 20, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppDimens.s12),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.s8),
                  const Icon(
                    Icons.chevron_left_rounded,
                    size: 22,
                    color: AppColors.textSecondary,
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

class _LogoutAction extends StatelessWidget {
  const _LogoutAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'تسجيل الخروج',
      onTap: onTap,
      child: ExcludeSemantics(
        child: Material(
          color: AppColors.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimens.brControl,
            side: BorderSide(color: AppColors.error),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 52),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.s16,
                  vertical: AppDimens.s8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      size: 20,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: AppDimens.s8),
                    Text(
                      'تسجيل الخروج',
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(color: AppColors.error),
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
