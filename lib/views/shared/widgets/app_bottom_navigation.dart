import 'dart:async';
import 'package:flutter/material.dart';
import 'package:freelance_front/controllers/auth/auth_controller.dart';
import '../../../constants/app_colors.dart';

/// Bottom navigation avec un bouton flottant central qui s'étire
/// pour révéler les autres icônes. Se referme automatiquement après
/// [_autoCollapseDelay] secondes d'inactivité.
class AppBottomNavigation extends StatefulWidget {
  final AuthController authController;
  final String currentRoute;
  final Function(String routeName)? onRouteSelected;

  const AppBottomNavigation({
    super.key,
    required this.authController,
    required this.currentRoute,
    this.onRouteSelected,
  });

  @override
  State<AppBottomNavigation> createState() => _AppBottomNavigationState();
}

class _AppBottomNavigationState extends State<AppBottomNavigation>
    with TickerProviderStateMixin {
  bool _expanded = false;
  Timer? _collapseTimer;

  static const _autoCollapseDelay = Duration(seconds: 2);

  static const _menuItems = [
    _NavItem(route: '/dashboard', label: 'Accueil', icon: Icons.home_rounded),
    _NavItem(
      route: '/tasks',
      label: 'Missions',
      icon: Icons.assignment_rounded,
    ),
    _NavItem(route: '/profile', label: 'Profil', icon: Icons.person_rounded),
  ];

  late final AnimationController _animCtrl;
  late final Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _expandAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _collapseTimer?.cancel();
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _animCtrl.forward();
      _resetCollapseTimer();
    } else {
      _animCtrl.reverse();
      _collapseTimer?.cancel();
    }
  }

  void _resetCollapseTimer() {
    _collapseTimer?.cancel();
    _collapseTimer = Timer(_autoCollapseDelay, () {
      if (mounted && _expanded) {
        setState(() => _expanded = false);
        _animCtrl.reverse();
      }
    });
  }

  void _navigate(String route) {
    // Collapse immédiatement
    setState(() => _expanded = false);
    _animCtrl.reverse();
    _collapseTimer?.cancel();

    if (widget.onRouteSelected != null) {
      widget.onRouteSelected!(route);
    } else if (widget.currentRoute != route) {
      Navigator.pushReplacementNamed(
        context,
        route,
        arguments: widget.authController,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Center(
          child: AnimatedBuilder(
            animation: _expandAnim,
            builder: (context, child) {
              return _ExpandingPill(
                expandAnim: _expandAnim,
                expanded: _expanded,
                currentRoute: widget.currentRoute,
                menuItems: _menuItems,
                onToggle: _toggle,
                onNavigate: _navigate,
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── Pill expandable ─────────────────────────────────────────────────────────

class _ExpandingPill extends StatelessWidget {
  final Animation<double> expandAnim;
  final bool expanded;
  final String currentRoute;
  final List<_NavItem> menuItems;
  final VoidCallback onToggle;
  final void Function(String) onNavigate;

  const _ExpandingPill({
    required this.expandAnim,
    required this.expanded,
    required this.currentRoute,
    required this.menuItems,
    required this.onToggle,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    // Largeur du bouton collapsed → width de la pill expanded
    const collapsedSize = 56.0;
    // Largeur cible en pleine expansion (bouton × items + espacement)
    const expandedWidth = 56.0 * 3 + 16.0 * 2 + 20.0;

    final width =
        collapsedSize + (expandedWidth - collapsedSize) * expandAnim.value;

    return Container(
      height: collapsedSize,
      width: width,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ── Icônes de navigation (visibles quand étendu) ───────────────
            if (expandAnim.value > 0.1)
              Opacity(
                opacity: expandAnim.value.clamp(0.0, 1.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(width: 4),
                    ...menuItems.map((item) {
                      final isActive = currentRoute == item.route;
                      return _NavIconBtn(
                        item: item,
                        isActive: isActive,
                        onTap: () => onNavigate(item.route),
                      );
                    }),
                    const SizedBox(width: 4),
                  ],
                ),
              ),

            // ── Bouton central (collapsed state) ──────────────────────────
            if (expandAnim.value < 0.5)
              Opacity(
                opacity: (1 - expandAnim.value * 2).clamp(0.0, 1.0),
                child: GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    width: collapsedSize,
                    height: collapsedSize,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.apps_rounded,
                      color: Colors.black,
                      size: 26,
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

// ─── Bouton d'icône individuel ───────────────────────────────────────────────

class _NavIconBtn extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavIconBtn({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: 22,
              color: isActive ? AppColors.primary : Colors.white60,
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: isActive ? AppColors.primary : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Modèle de données ───────────────────────────────────────────────────────

class _NavItem {
  final String route;
  final String label;
  final IconData icon;
  const _NavItem({
    required this.route,
    required this.label,
    required this.icon,
  });
}
