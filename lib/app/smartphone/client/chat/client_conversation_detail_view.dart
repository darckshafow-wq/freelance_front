import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/models/common/message_model.dart';
import 'package:freelance_front/core/services/common/message_service.dart';
import 'package:go_router/go_router.dart';
import 'package:freelance_front/core/routes/route_names.dart';

class ClientConversationDetailView extends StatefulWidget {
  final String id;
  const ClientConversationDetailView({super.key, required this.id});

  @override
  State<ClientConversationDetailView> createState() => _ClientConversationDetailViewState();
}

class _ClientConversationDetailViewState extends State<ClientConversationDetailView> {
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
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
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
      backgroundColor: AppColors.softWhite, // Remplacé le fond beige WhatsApp par la couleur de l'app
      appBar: AppBar(
        backgroundColor: AppColors.deepBlack, // Remplacé le vert WhatsApp par le noir profond de l'app
        elevation: 0,
        leadingWidth: 30,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryGold, size: 20),
          onPressed: () => context.goNamed(RouteNames.clientChat),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.neutralGray,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${widget.id}'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Projet #${widget.id}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.pureWhite),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'En ligne',
                    style: TextStyle(fontSize: 12, color: AppColors.primaryGold, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam_rounded, color: AppColors.primaryGold), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call_rounded, color: AppColors.primaryGold), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert_rounded, color: AppColors.primaryGold), onPressed: () {}),
        ],
      ),
      body: Container(
        // Motif de fond subtil si désiré, ou simple couleur unie
        decoration: const BoxDecoration(
          color: AppColors.softWhite,
        ),
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
                  : _messages.isEmpty
                      ? Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Les messages sont chiffrés de bout en bout.',
                              style: TextStyle(color: AppColors.deepBlack, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) => _buildWhatsAppBubble(_messages[index]),
                        ),
            ),
            _buildWhatsAppInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsAppBubble(MessageModel message) {
    final isMe = message.senderId != _projectId;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
        decoration: BoxDecoration(
          color: isMe ? AppColors.deepBlack : Colors.white, // Bulle client sombre / freelance blanche
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isMe ? 12 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.deepBlack,
                fontSize: 14.5,
                height: 1.3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: isMe ? AppColors.primaryGold : AppColors.neutralGray,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 3),
                    Icon(
                      message.isRead ? Icons.done_all_rounded : Icons.check_rounded,
                      size: 14,
                      color: AppColors.primaryGold,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 80.ms).slideY(begin: 0.03),
    );
  }

  Widget _buildWhatsAppInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Zone de saisie arrondie WhatsApp
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
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
                        minLines: 1,
                        maxLines: 5,
                        style: const TextStyle(fontSize: 15, color: AppColors.deepBlack),
                        decoration: const InputDecoration(
                          hintText: 'Message',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: AppColors.neutralGray, fontSize: 15),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.attach_file, color: AppColors.neutralGray, size: 22),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: AppColors.neutralGray, size: 22),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Bouton envoi circulaire externe
            GestureDetector(
              onTap: _isSending ? null : _sendMessage,
              child: CircleAvatar(
                radius: 23,
                backgroundColor: AppColors.deepBlack,
                child: _isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: AppColors.primaryGold, strokeWidth: 2),
                      )
                    : const Icon(Icons.send, color: AppColors.primaryGold, size: 20),
              ),
            ),
          ],
        ),
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