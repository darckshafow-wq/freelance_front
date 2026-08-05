import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../constants/app_colors.dart';
import '../../../../controllers/shared/conversation.dart';
import '../../../../routes/client_routes.dart';
import '../../../../services/api/api_endpoints.dart';

class ClientChatListPage extends StatefulWidget {
  final int currentUserId;
  final Function(dynamic contact)? onContactSelected;

  const ClientChatListPage({
    super.key,
    required this.currentUserId,
    this.onContactSelected,
  });

  @override
  State<ClientChatListPage> createState() => _ClientChatListPageState();
}

class _ClientChatListPageState extends State<ClientChatListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatListController>().fetchConversations(
            widget.currentUserId,
            conversationsEndpoint: ApiEndpoints.clientConversations,
          );
    });
  }

  Future<void> _refreshConversations() async {
    if (!mounted) return;
    await context.read<ChatListController>().fetchConversations(
          widget.currentUserId,
          conversationsEndpoint: ApiEndpoints.clientConversations,
        );
  }

  @override
  Widget build(BuildContext context) {
    final chatListController = context.watch<ChatListController>();

    return RefreshIndicator(
      color: Colors.black,
      backgroundColor: AppColors.primary,
      onRefresh: _refreshConversations,
      child: Builder(
        builder: (context) {
          final conversations = chatListController.conversations;
          if (chatListController.isLoading && conversations.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }

          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 80,
                    color: Colors.grey[200],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Aucun message pour le moment',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final contact = conversations[index];
              return _buildConversationCard(context, contact, chatListController);
            },
          );
        },
      ),
    );
  }

  Widget _buildConversationCard(BuildContext context, dynamic contact, ChatListController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (widget.onContactSelected != null) {
            widget.onContactSelected!(contact);
          } else {
            Navigator.pushNamed(
              context,
              ClientRouteNames.chatDetail,
              arguments: {
                'otherUserId': contact.userId,
                'otherUserName': contact.userName,
                'taskId': contact.taskId,
                'applicationId': contact.applicationId,
                'initialStatus': contact.applicationStatus,
              },
            );
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildAvatar(contact.userName),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            contact.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          controller.formatTime(contact.lastTimestamp),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _buildStatusBadge(contact.applicationStatus),
                    const SizedBox(height: 6),
                    Text(
                      contact.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String name) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: Text(
        name[0].toUpperCase(),
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w900,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    if (status == null) return const SizedBox.shrink();

    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'accepted':
      case 'validated':
        color = AppColors.success;
        label = 'Accepté';
        break;
      case 'interview':
        color = AppColors.primary;
        label = 'Entretien';
        break;
      case 'rejected':
        color = AppColors.error;
        label = 'Refusé';
        break;
      default:
        color = Colors.grey;
        label = 'En attente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
