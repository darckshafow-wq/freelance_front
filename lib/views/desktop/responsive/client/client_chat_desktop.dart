import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/auth/auth_controller.dart';
import '../../../smartphone/client/chat/client_chat_list_page.dart';
import '../../../smartphone/client/chat/client_chat_page.dart';
import '../shared/chat_split_view.dart';

class ClientChatDesktop extends StatefulWidget {
  const ClientChatDesktop({super.key});

  @override
  State<ClientChatDesktop> createState() => _ClientChatDesktopState();
}

class _ClientChatDesktopState extends State<ClientChatDesktop> {
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
        : ClientChatPage(
            key: ValueKey(_selectedContact.userId), // Force rebuild on change
            otherUserId: _selectedContact.userId,
            otherUserName: _selectedContact.userName,
            taskId: _selectedContact.taskId,
            applicationId: _selectedContact.applicationId,
            initialStatus: _selectedContact.applicationStatus,
          ),
    );
  }

  Widget _buildModifiedList(AuthController auth) {
    return ClientChatListPage(
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
