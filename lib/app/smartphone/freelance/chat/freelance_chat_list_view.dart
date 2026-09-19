import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/routes/route_names.dart';
import 'package:freelance_front/core/services/common/message_service.dart';
import 'package:freelance_front/core/models/common/conversation_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class FreelanceChatListView extends StatefulWidget {
  const FreelanceChatListView({super.key});

  @override
  State<FreelanceChatListView> createState() => _FreelanceChatListViewState();
}

class _FreelanceChatListViewState extends State<FreelanceChatListView> {
  late Future<List<ConversationModel>> _conversationsFuture;

  @override
  void initState() {
    super.initState();
    _refreshConversations();
  }

  void _refreshConversations() {
    setState(() {
      _conversationsFuture = MessageService().getFreelanceConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('Discussions', 
          style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.deepBlack, fontSize: 26)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded, color: AppColors.deepBlack),
            onPressed: _refreshConversations,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshConversations(),
        color: AppColors.primaryGold,
        child: FutureBuilder<List<ConversationModel>>(
          future: _conversationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryGold));
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.errorRed),
                    ),
                    const SizedBox(height: 16),
                    Text('Erreur: ${snapshot.error}', textAlign: TextAlign.center, 
                      style: const TextStyle(color: AppColors.neutralGray, fontWeight: FontWeight.w600)),
                    TextButton(onPressed: _refreshConversations, child: const Text('Réessayer'))
                  ],
                ),
              );
            }

            final conversations = snapshot.data ?? [];
            if (conversations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded, size: 80, color: AppColors.neutralGray.withValues(alpha: 0.1)),
                    const SizedBox(height: 24),
                    const Text('Aucune conversation pour le moment', 
                      style: TextStyle(color: AppColors.neutralGray, fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
              itemCount: conversations.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final conv = conversations[index];
                return _buildConversationCard(conv, index);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildConversationCard(ConversationModel conv, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.pushNamed(RouteNames.freelanceConversationDetail, pathParameters: {'id': conv.id.toString()}),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3), width: 1.5),
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primaryGold.withValues(alpha: 0.1),
                        backgroundImage: conv.avatarUrl.isNotEmpty ? NetworkImage(conv.avatarUrl) : null,
                        child: conv.avatarUrl.isEmpty 
                          ? Text(conv.otherUserName[0], style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 22))
                          : null,
                      ),
                    ),
                    if (conv.isOnline)
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Container(
                          width: 14, height: 14,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
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
                          Text(
                            conv.otherUserName,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppColors.deepBlack, letterSpacing: -0.5),
                          ),
                          Text(
                            DateFormat('HH:mm').format(conv.lastMessageTime),
                            style: const TextStyle(color: Colors.black12, fontSize: 11, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conv.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: conv.unreadCount > 0 ? AppColors.deepBlack : AppColors.neutralGray,
                                fontWeight: conv.unreadCount > 0 ? FontWeight.w800 : FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (conv.unreadCount > 0)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGold, 
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: AppColors.primaryGold.withValues(alpha: 0.3), blurRadius: 8)]
                              ),
                              child: Text(
                                conv.unreadCount.toString(),
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 11),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 60).ms).slideX(begin: 0.05);
  }
}
