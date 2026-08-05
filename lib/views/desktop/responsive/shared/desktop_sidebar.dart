import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';

class DesktopSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final bool isClient;
  final bool isCollapsed;
  final VoidCallback onToggle;

  const DesktopSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.isCollapsed,
    required this.onToggle,
    this.isClient = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isCollapsed ? 80 : 250,
      color: Colors.black,
      child: Column(
        children: [
          _buildLogo(),
          const SizedBox(height: 20),
          _buildToggleBtn(),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: isClient ? _buildClientItems() : _buildFreelanceItems(),
            ),
          ),
          _buildLogout(context),
        ],
      ),
    );
  }

  Widget _buildToggleBtn() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: isCollapsed ? Alignment.center : Alignment.centerRight,
        child: IconButton(
          onPressed: onToggle,
          icon: Icon(
            isCollapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
            color: AppColors.primary,
          ),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bolt_rounded, color: Colors.black, size: 24),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 12),
            const Flexible(
              child: Text(
                'FREELANCE',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildClientItems() {
    return [
      _SidebarItem(
        icon: Icons.home_filled,
        label: 'Tableau de bord',
        isSelected: selectedIndex == 0,
        isCollapsed: isCollapsed,
        onTap: () => onItemSelected(0),
      ),
      _SidebarItem(
        icon: Icons.explore_rounded,
        label: 'Mes Missions',
        isSelected: selectedIndex == 1,
        isCollapsed: isCollapsed,
        onTap: () => onItemSelected(1),
      ),
      _SidebarItem(
        icon: Icons.assignment_ind_rounded,
        label: 'Candidatures',
        isSelected: selectedIndex == 2,
        isCollapsed: isCollapsed,
        onTap: () => onItemSelected(2),
      ),
      _SidebarItem(
        icon: Icons.chat_bubble_rounded,
        label: 'Messages',
        isSelected: selectedIndex == 3,
        isCollapsed: isCollapsed,
        onTap: () => onItemSelected(3),
      ),
      _SidebarItem(
        icon: Icons.person_rounded,
        label: 'Profil',
        isSelected: selectedIndex == 4,
        isCollapsed: isCollapsed,
        onTap: () => onItemSelected(4),
      ),
    ];
  }

  List<Widget> _buildFreelanceItems() {
    return [
      _SidebarItem(
        icon: Icons.home_filled,
        label: 'Missions',
        isSelected: selectedIndex == 0,
        isCollapsed: isCollapsed,
        onTap: () => onItemSelected(0),
      ),
      _SidebarItem(
        icon: Icons.assignment_turned_in_outlined,
        label: 'Mes Demandes',
        isSelected: selectedIndex == 1,
        isCollapsed: isCollapsed,
        onTap: () => onItemSelected(1),
      ),
      _SidebarItem(
        icon: Icons.chat_bubble_rounded,
        label: 'Messages',
        isSelected: selectedIndex == 2,
        isCollapsed: isCollapsed,
        onTap: () => onItemSelected(2),
      ),
      _SidebarItem(
        icon: Icons.person_rounded,
        label: 'Mon Profil',
        isSelected: selectedIndex == 3,
        isCollapsed: isCollapsed,
        onTap: () => onItemSelected(3),
      ),
    ];
  }

  Widget _buildLogout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: _SidebarItem(
        icon: Icons.logout_rounded,
        label: 'Déconnexion',
        isSelected: false,
        isCollapsed: isCollapsed,
        onTap: () {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        },
        color: Colors.redAccent,
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback onTap;
  final Color? color;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isCollapsed,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primary;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 0 : 16, 
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: isSelected ? activeColor : (color ?? Colors.grey[500]),
                size: 24,
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? Colors.white : (color ?? Colors.grey[400]),
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                      fontSize: 14,
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
