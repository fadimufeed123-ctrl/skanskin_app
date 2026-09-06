import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skanskin_app/core/theme/app_colors.dart';
import 'package:skanskin_app/core/theme/app_dimens.dart';

/// Mobile counterpart of the MVC sidebar: white surface, teal active item,
/// compact line icons, and the same Almarai label hierarchy.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabs = <_TabSpec>[
    _TabSpec(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'الرئيسية',
    ),
    _TabSpec(
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment_rounded,
      label: 'استشاراتي',
    ),
    _TabSpec(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'حسابي',
    ),
  ];

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      // Re-tapping the active tab returns it to that branch's initial route.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final navigationHeight = textScale > 1.5
        ? 80.0
        : textScale > 1.2
        ? 72.0
        : 68.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimens.rDialog),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.panelShadow,
              blurRadius: 20,
              offset: Offset(0, -3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: navigationHeight,
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  Expanded(
                    child: _NavItem(
                      spec: _tabs[i],
                      selected: navigationShell.currentIndex == i,
                      onTap: () => _onTap(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.spec,
    required this.selected,
    required this.onTap,
  });

  final _TabSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = selected ? AppColors.primary : AppColors.textSecondary;
    final labelColor = selected
        ? AppColors.onPrimarySoft
        : AppColors.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      label: spec.label,
      onTap: onTap,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 160),
                width: 48,
                height: 30,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primarySoft : Colors.transparent,
                  borderRadius: AppDimens.brFull,
                ),
                child: Icon(
                  selected ? spec.activeIcon : spec.icon,
                  size: 21,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                spec.label,
                style: TextStyle(
                  fontSize: 12,
                  height: 18 / 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: labelColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
