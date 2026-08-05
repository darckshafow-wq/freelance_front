import 'package:flutter/material.dart';
import 'admin_sidebar.dart';
import '../../../../constants/app_colors.dart';

class AdminDesktopScaffold extends StatelessWidget {
  final Widget body;
  final int selectedIndex;
  final String title;
  final List<Widget>? actions;

  const AdminDesktopScaffold({
    super.key,
    required this.body,
    required this.selectedIndex,
    this.title = '',
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1F),
      body: Row(
        children: [
          AdminSidebar(selectedIndex: selectedIndex),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D1F),
        border: Border(bottom: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      child: Row(
        children: [
          if (title.isNotEmpty)
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          const Spacer(),
          ...?actions,
          const SizedBox(width: 20),
          const VerticalDivider(
            color: Colors.white10,
            indent: 10,
            endIndent: 10,
          ),
          const SizedBox(width: 20),
          const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Admin User',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Super Admin',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
