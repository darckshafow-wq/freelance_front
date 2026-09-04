import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/models/common/conversation_model.dart';
import 'package:freelance_front/core/services/common/message_service.dart';
import 'package:go_router/go_router.dart';
import 'package:freelance_front/core/routes/route_names.dart';

class ClientChatListView extends StatefulWidget {
  const ClientChatListView({super.key});

  @override
  State<ClientChatListView> createState() => _ClientChatListViewState();
}

class _ClientChatListViewState extends State<ClientChatListView> {
  late Future<List<ConversationModel>> _conversationsFuture;

  @override
  void initState() {
    super.initState();
    _refreshConversations();
  }

  void _refreshConversations() {
    setState(() {
      _conversationsFuture = MessageService().getConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text(
          'Mes Messages', 
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: AppColors.deepBlack)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.deepBlack),
            onPressed: _refreshConversations,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshConversations(),
        child: FutureBuilder<List<ConversationModel>>(
          future: _conversationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Erreur: ${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _refreshConversations,
                      child: const Text('RÉESSAYER'),
                    )
                  ],
                ),
              );
            }

            final conversations = snapshot.data ?? [];
            if (conversations.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 150),
                  Center(
                    child: Text(
                      'Aucune conversation pour le moment.',
                      style: TextStyle(color: AppColors.neutralGray, fontSize: 16),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 120), // 120px pour libérer la barre flottante
              itemCount: conversations.length,
              itemBuilder: (context, index) => _buildChatItem(context, conversations[index]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, ConversationModel conversation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.pushNamed(
            RouteNames.clientConversationDetail, 
            pathParameters: {'id': conversation.id.toString()},
          ),
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.softWhite,
                      backgroundImage: const NetworkImage('https://i.pravatar.cc/150?u=chat'),
                      onBackgroundImageError: (e, s) => const Icon(Icons.person),
                    ),
                    if (conversation.isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
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
                              conversation.otherUserName.isEmpty ? 'Conversation' : conversation.otherUserName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppColors.deepBlack),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(conversation.lastMessageTime),
                            style: const TextStyle(color: AppColors.neutralGray, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        conversation.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.neutralGray, fontSize: 14, fontWeight: FontWeight.w500, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.05);
  }

  String _formatTime(DateTime date) => '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}