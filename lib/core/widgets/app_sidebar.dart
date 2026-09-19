import 'package:flutter/material.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SidebarItem {
  final IconData icon;
  final String label;
  final String routeName; // We'll keep this as path for isActive check
  final String? name;     // Optional GoRouter name

  SidebarItem({
    required this.icon,
    required this.label,
    required this.routeName,
    this.name,
  });
}

class AppSidebar extends StatefulWidget {
  final List<SidebarItem> items;
  final VoidCallback? onLogout;
  final String? headerTitle;
  final IconData? headerIcon;

  const AppSidebar({
    super.key,
    required this.items,
    this.onLogout,
    this.headerTitle,
    this.headerIcon,
  });

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutQuart,
      width: _isExpanded ? 260 : 80,
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          // Header / Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: _isExpanded ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
              children: [
                if (_isExpanded)
                  Expanded(
                    child: Text(
                      widget.headerTitle ?? 'FreeFlow',
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                  ),
                IconButton(
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  icon: Icon(
                    _isExpanded ? Icons.menu_open_rounded : Icons.menu_rounded,
                    color: Colors.white54,
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          
          // Search Widget
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search_rounded, color: Colors.white24, size: 18),
                    SizedBox(width: 12),
                    Expanded(child: Text('Search', style: TextStyle(color: Colors.white24, fontSize: 13, fontWeight: FontWeight.bold))),
                    Text('/', style: TextStyle(color: Colors.white12, fontSize: 13)),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 300.ms),
            
          const SizedBox(height: 32),

          // Menu Items
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              itemCount: widget.items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                return _buildMenuItem(widget.items[index]);
              },
            ),
          ),
          
          // Footer / Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 32),
            child: _buildLogoutButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(SidebarItem item) {
    final state = GoRouterState.of(context);
    final String location = state.matchedLocation;
    final bool isActive = location == item.routeName || (item.routeName != '/' && location.startsWith(item.routeName));

    return InkWell(
      onTap: () {
        if (item.name != null) {
          context.goNamed(item.name!);
        } else {
          context.go(item.routeName);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRect(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                item.icon,
                color: isActive ? AppColors.primaryGold : Colors.white54,
                size: 22,
              ),
              if (_isExpanded) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white54,
                      fontSize: 15,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: widget.onLogout,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: ClipRect(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Icon(Icons.logout_rounded, color: Colors.white54, size: 22),
              if (_isExpanded) ...[
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Log Out',
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
