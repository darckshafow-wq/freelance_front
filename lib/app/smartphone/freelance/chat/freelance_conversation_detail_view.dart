import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/models/common/message_model.dart';
import 'package:freelance_front/core/services/common/message_service.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class FreelanceConversationDetailView extends StatefulWidget {
  final String id;
  const FreelanceConversationDetailView({super.key, required this.id});

  @override
  State<FreelanceConversationDetailView> createState() => _FreelanceConversationDetailViewState();
}

class _FreelanceConversationDetailViewState extends State<FreelanceConversationDetailView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MessageService _messageService = MessageService();

  List<MessageModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  late int _projectId;

  @override
  void initState() {
    super.initState();
    _projectId = int.tryParse(widget.id) ?? 0;
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    try {
      final messages = await _messageService.getMessages(_projectId);
      await _messageService.markAsRead(_projectId);
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuart,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: AppColors.deepBlack,
        elevation: 0,
        leadingWidth: 40,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryGold, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5))),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white10,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=client_${widget.id}'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Client - Mission #${widget.id}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.pureWhite, letterSpacing: -0.3),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'En ligne',
                    style: TextStyle(fontSize: 11, color: AppColors.primaryGold, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam_rounded, color: AppColors.primaryGold, size: 22), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call_rounded, color: AppColors.primaryGold, size: 20), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
                : _messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
                      ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: AppColors.primaryGold.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.forum_rounded, color: AppColors.primaryGold, size: 50),
          ),
          const SizedBox(height: 24),
          const Text('Discutons !', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.deepBlack)),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 50),
            child: Text('Posez vos questions au client pour assurer la réussite de votre mission.', 
              textAlign: TextAlign.center, style: TextStyle(color: AppColors.neutralGray, fontSize: 14, height: 1.5)),
          ),
        ],
      ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
    );
  }

  Widget _buildMessageBubble(MessageModel message) {
    final isMe = message.senderId == 0 || message.senderId != _projectId; 

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.deepBlack : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: Radius.circular(isMe ? 24 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 24),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 6))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.deepBlack,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('HH:mm').format(message.createdAt),
                  style: TextStyle(
                    color: isMe ? AppColors.primaryGold.withValues(alpha: 0.6) : AppColors.neutralGray,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all_rounded : Icons.done_rounded,
                    size: 15,
                    color: AppColors.primaryGold,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05);
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.softWhite,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.emoji_emotions_outlined, color: AppColors.neutralGray, size: 24),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      maxLines: 4,
                      minLines: 1,
                      style: const TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(
                        hintText: 'Écrire un message...',
                        hintStyle: TextStyle(color: Colors.black26, fontWeight: FontWeight.bold),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file_rounded, color: AppColors.neutralGray, size: 22),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _isSending ? null : _sendMessage,
            child: AnimatedContainer(
              duration: 200.ms,
              width: 56, height: 56,
              decoration: const BoxDecoration(color: AppColors.deepBlack, shape: BoxShape.circle),
              child: _isSending
                  ? const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.primaryGold, strokeWidth: 3)))
                  : const Icon(Icons.send_rounded, color: AppColors.primaryGold, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    setState(() => _isSending = true);

    try {
      await _messageService.sendMessage(_projectId, text);
      if (mounted) {
        setState(() {
          _messages.add(
            MessageModel(
              id: DateTime.now().millisecondsSinceEpoch,
              senderId: 0,
              receiverId: _projectId,
              content: text,
              createdAt: DateTime.now(),
              isRead: false,
            ),
          );
        });
        _scrollToBottom();
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }
}
