import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../shared/widgets/admin_desktop_scaffold.dart';

class AdminMessages extends StatefulWidget {
  const AdminMessages({super.key});

  @override
  State<AdminMessages> createState() => _AdminMessagesState();
}

class _AdminMessagesState extends State<AdminMessages> {
  @override
  Widget build(BuildContext context) {
    return AdminDesktopScaffold(
      selectedIndex: 4,
      title: 'Platform Messages',
      body: Row(
        children: [
          // Contacts List
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                ),
              ),
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) => _contactTile(index),
              ),
            ),
          ),
          // Chat View Placeholder
          Expanded(
            flex: 2,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 80,
                    color: Colors.white10,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select a conversation to moderate',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text(
                      'New Support Ticket',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
          ),
        ],
      ),
    );
  }

  Widget _contactTile(int index) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      leading: const CircleAvatar(
        backgroundColor: Colors.white10,
        child: Icon(Icons.person, color: Colors.grey),
      ),
      title: Text(
        'User Group #${index + 1}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: const Text(
        'Last message content goes here...',
        style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
      trailing: index % 3 == 0
          ? Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            )
          : null,
      onTap: () {},
    );
  }
}
