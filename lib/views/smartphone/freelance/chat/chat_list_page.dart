import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../constants/app_colors.dart';
import '../../../../routes/freelance_routes.dart';
import '../../../../controllers/shared/conversation.dart';
import '../../../../services/api/api_endpoints.dart';

class ChatListPage extends StatefulWidget {
  final int currentUserId;
  final Function(dynamic contact)? onContactSelected;

  const ChatListPage({
    super.key,
    required this.currentUserId,
    this.onContactSelected,
  });

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatListController>().fetchConversations(
            widget.currentUserId,
            conversationsEndpoint: ApiEndpoints.freelanceConversations,
          );
    });
  }

  Future<void> _refreshConversations() async {
    if (!mounted) return;
    await context.read<ChatListController>().fetchConversations(
          widget.currentUserId,
          conversationsEndpoint: ApiEndpoints.freelanceConversations,
        );
  }

  @override
  Widget build(BuildContext context) {
    final chatListController = context.watch<ChatListController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        title: const Text(
          'Mes conversations',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: Colors.black87,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: const Color(0xFFFDFBF7),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refreshConversations,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: RefreshIndicator(
        // ✅ Ajout du geste Swipe-to-Refresh
        color: AppColors.primary,
        backgroundColor: Colors.white,
        onRefresh: _refreshConversations,
        child: Builder(
          builder: (context) {
            final conversations = chatListController.conversations;

            // 1. Premier chargement (avec liste vide)
            if (chatListController.isLoading && conversations.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
              );
            }

            // 2. Gestion des erreurs
            if (chatListController.error != null && conversations.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 40,
                                color: Colors.redAccent,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              chatListController.error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _refreshConversations,
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text('Réessayer'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            // 3. Liste vide
            if (conversations.isEmpty) {
              return ListView(
                // ✅ Utilisation d'une ListView scrollable pour permettre le Pull-to-refresh
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.03),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.mail_outline_rounded,
                              size: 48,
                              color: Colors.black.withValues(alpha: 0.25),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucune conversation pour le moment.',
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            // 4. Affichage de la liste des conversations
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              itemCount: conversations.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final contact = conversations[index];
                final bool isNoMessage =
                    contact.lastMessage == "Aucun message pour le moment";

                return Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Colors.black.withValues(alpha: 0.04),
                      width: 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      if (widget.onContactSelected != null) {
                        widget.onContactSelected!(contact);
                      } else {
                        dev.log(
                          'Navigation vers chatDetail -> otherUserId: ${contact.userId}, otherUserName: ${contact.userName}, taskId: ${contact.taskId}',
                        );

                        Navigator.pushNamed(
                          context,
                          FreelanceRouteNames.chatDetail,
                          arguments: {
                            'otherUserId': contact.userId,
                            'otherUserName': contact.userName,
                            'taskId': contact.taskId,
                            'applicationId': contact.applicationId,
                            'initialStatus': contact.applicationStatus,
                          },
                        ).then((_) {
                          _refreshConversations();
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.12,
                            ),
                            child: Text(
                              contact.userName.isNotEmpty
                                  ? contact.userName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        contact.userName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      chatListController.formatTime(
                                        contact.lastTimestamp,
                                      ),
                                      style: TextStyle(
                                        color: Colors.black.withValues(
                                          alpha: 0.35,
                                        ),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                if (contact.taskTitle.isNotEmpty) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      contact.taskTitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black.withValues(
                                          alpha: 0.55,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                                Text(
                                  contact.lastMessage,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isNoMessage
                                        ? Colors.black.withValues(alpha: 0.3)
                                        : Colors.black.withValues(alpha: 0.55),
                                    fontSize: 14,
                                    fontStyle: isNoMessage
                                        ? FontStyle.italic
                                        : FontStyle.normal,
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
              },
            );
          },
        ),
      ),
    );
  }
}
