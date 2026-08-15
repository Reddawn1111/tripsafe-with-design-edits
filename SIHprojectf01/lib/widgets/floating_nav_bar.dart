import 'package:flutter/material.dart';
import '../app/routes.dart';
import '../utils/app_theme.dart';

/// Floating pill navigation bar (design 1a).
///
/// Charcoal pill that hovers above the content; the active destination is a
/// solid rust circle, the rest are muted glyphs. A hairline divider separates
/// trip destinations from account/settings.
///
/// Usage — wrap any screen body:
///
/// ```dart
/// Scaffold(
///   extendBody: true,
///   body: …,
///   bottomNavigationBar: const FloatingNavBar(current: NavDestination.home),
/// )
/// ```
///
/// `extendBody: true` matters: it lets the page scroll under the pill. Give
/// scrolling content bottom padding of about 96 so the last item clears it.
enum NavDestination { home, explore, journey, group, privacy }

class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({super.key, required this.current});

  final NavDestination current;

  static const _items = <NavDestination, ({IconData icon, String route, String label})>{
    NavDestination.home: (
      icon: Icons.home_outlined,
      route: AppRoutes.home,
      label: 'Home',
    ),
    NavDestination.explore: (
      icon: Icons.search,
      route: AppRoutes.discover,
      label: 'Explore',
    ),
    NavDestination.journey: (
      icon: Icons.monitor_heart_outlined,
      route: AppRoutes.journey,
      label: 'Journey',
    ),
    NavDestination.group: (
      icon: Icons.person_outline,
      route: AppRoutes.group,
      label: 'Group',
    ),
    NavDestination.privacy: (
      icon: Icons.blur_on,
      route: AppRoutes.privacy,
      label: 'Privacy',
    ),
  };

  void _go(BuildContext context, NavDestination dest) {
    if (dest == current) return;
    final route = _items[dest]!.route;
    if (route == AppRoutes.home) {
      Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
    } else {
      Navigator.pushNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Order matches the design: home · explore | journey · group · privacy
    const before = [NavDestination.home, NavDestination.explore];
    const after = [
      NavDestination.journey,
      NavDestination.group,
      NavDestination.privacy,
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, 12),
        child: Container(
          height: 66,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: AppSpacing.pill,
            border: Border.all(color: AppTheme.borderDark),
          ),
          child: Row(
            children: [
              for (final d in before) Expanded(child: _slot(context, d)),
              Container(
                width: 1,
                height: 22,
                color: const Color(0x1FFFFFFF),
              ),
              for (final d in after) Expanded(child: _slot(context, d)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _slot(BuildContext context, NavDestination dest) {
    final item = _items[dest]!;
    final isActive = dest == current;

    return Semantics(
      button: true,
      selected: isActive,
      label: item.label,
      child: InkWell(
        onTap: () => _go(context, dest),
        customBorder: const CircleBorder(),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primary : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              size: 21,
              color: isActive ? AppTheme.onPrimary : AppTheme.mutedDark,
            ),
          ),
        ),
      ),
    );
  }
}
