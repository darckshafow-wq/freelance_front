import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/auth/auth_controller.dart';
import '../../../smartphone/freelance/chat/chat_list_page.dart';
import '../../../smartphone/freelance/chat/freelance_chat_page.dart';
import '../shared/chat_split_view.dart';

class FreelanceChatDesktop extends StatefulWidget {
  const FreelanceChatDesktop({super.key});

  @override
  State<FreelanceChatDesktop> createState() => _FreelanceChatDesktopState();
}

class _FreelanceChatDesktopState extends State<FreelanceChatDesktop> {
  dynamic _selectedContact;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    
    return ChatSplitView(
      isContactSelected: _selectedContact != null,
      listWidget: _buildModifiedList(auth),
      detailPlaceholder: _buildPlaceholder(),
      activeChatWidget: _selectedContact == null 
        ? const SizedBox.shrink() 
        : FreelanceChatPage(
            key: ValueKey(_selectedContact.userId), // Force rebuild
            otherUserId: _selectedContact.userId,
            otherUserName: _selectedContact.userName,
            taskId: _selectedContact.taskId,
            applicationId: _selectedContact.applicationId,
            initialStatus: _selectedContact.applicationStatus,
          ),
    );
  }

  Widget _buildModifiedList(AuthController auth) {
    return ChatListPage(
      currentUserId: auth.currentUser?.id ?? 0,
      onContactSelected: (contact) {
        setState(() => _selectedContact = contact);
      },
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 80, color: Colors.black12),
          SizedBox(height: 20),
          Text(
            'Sélectionnez une discussion pour commencer',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
