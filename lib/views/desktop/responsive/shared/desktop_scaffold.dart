import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'desktop_sidebar.dart';
import '../../../../constants/app_colors.dart';
import '../../../../controllers/auth/auth_controller.dart';
import '../../../../models/auth/user_model.dart';

class DesktopScaffold extends StatefulWidget {
  final Widget body;
  final int selectedIndex;
  final Function(int) onItemSelected;
  final String title;
  final bool isClient;
  final List<Widget>? actions;

  const DesktopScaffold({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onItemSelected,
    this.title = '',
    this.isClient = true,
    this.actions,
  });

  @override
  State<DesktopScaffold> createState() => _DesktopScaffoldState();
}

class _DesktopScaffoldState extends State<DesktopScaffold> {
  bool _isCollapsed = false;

  void _toggleSidebar() {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          DesktopSidebar(
            selectedIndex: widget.selectedIndex,
            onItemSelected: widget.onItemSelected,
            isClient: widget.isClient,
            isCollapsed: _isCollapsed,
            onToggle: _toggleSidebar,
          ),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: widget.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: Row(
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          ...?widget.actions,
          const SizedBox(width: 20),
          const VerticalDivider(width: 1, indent: 20, endIndent: 20),
          const SizedBox(width: 20),
          _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    final user = context.watch<AuthController>().currentUser;
    final name = user?.fullName ?? 'Utilisateur';
    final role = user?.role == UserRole.client ? 'Compte Client' : 'Compte Freelance';

    return Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            Text(
              role,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.black,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
