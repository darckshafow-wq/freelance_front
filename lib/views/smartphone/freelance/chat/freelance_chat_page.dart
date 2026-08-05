import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../constants/app_colors.dart';
import '../../../../controllers/shared/chat_controller.dart';
import '../../../../models/shared/message_model.dart';
import '../../../../models/freelance/application_model.dart';
import '../../../../utils/ui/ui_utils.dart';

class FreelanceChatPage extends StatefulWidget {
  final int otherUserId;
  final String? otherUserName;
  final int taskId;
  final int applicationId;
  final String? initialStatus;

  const FreelanceChatPage({
    super.key,
    this.otherUserId = 0,
    this.otherUserName,
    required this.taskId,
    this.applicationId = 0,
    this.initialStatus,
  });

  @override
  State<FreelanceChatPage> createState() => _FreelanceChatPageState();
}

class _FreelanceChatPageState extends State<FreelanceChatPage> {
  final ChatController _chatController = ChatController();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  ApplicationStatus? _currentStatus;

  static const Color _kAmber = Color(0xFFFFB000);
  static const Color _kBg = Color(0xFFFDFBF7);

  @override
  void initState() {
    super.initState();
    if (widget.initialStatus != null) {
      _currentStatus = ApplicationStatus.fromString(widget.initialStatus!);
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _chatController.init(
          otherUserId: widget.otherUserId,
          taskId: widget.taskId,
          isClient: false,
        );
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    _inputController.clear();
    final success = await _chatController.sendMessage(
      text: text,
      otherUserId: widget.otherUserId,
      taskId: widget.taskId,
    );

    if (success) {
      _scrollToBottom();
    } else if (mounted) {
      UIUtils.showError(context, _chatController.error ?? 'Échec de l\'envoi');
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Widget _buildStatusHeader() {
    if (_currentStatus == null) return const SizedBox.shrink();

    String label = "";
    Color color = Colors.grey;
    IconData icon = Icons.info_outline_rounded;

    switch (_currentStatus!) {
      case ApplicationStatus.pending:
        label = "Candidature en attente de lecture";
        color = Colors.orange;
        icon = Icons.access_time_rounded;
        break;
      case ApplicationStatus.interview:
        label = "Entretien en cours avec le client";
        color = AppColors.accent;
        icon = Icons.chat_bubble_outline_rounded;
        break;
      case ApplicationStatus.accepted:
        label = "Félicitations ! Mission attribuée";
        color = Colors.green;
        icon = Icons.check_circle_outline_rounded;
        break;
      case ApplicationStatus.rejected:
        label = "Candidature non retenue";
        color = Colors.redAccent;
        icon = Icons.error_outline_rounded;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: color.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.otherUserName ?? 'Conversation';

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kAmber,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              child: Text(
                title.isNotEmpty ? title[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'En ligne',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _chatController.fetchMessages(
                otherUserId: widget.otherUserId,
                taskId: widget.taskId,
              );
              _scrollToBottom();
            },
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _chatController,
        builder: (context, child) {
          return Column(
            children: [
              _buildStatusHeader(), // 👈 Bannière de statut pour le freelance
              Expanded(
                child: _chatController.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: _kAmber),
                      )
                    : _chatController.error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline,
                                size: 48,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _chatController.error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.black45),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () async {
                                  await _chatController.fetchMessages(
                                    otherUserId: widget.otherUserId,
                                    taskId: widget.taskId,
                                  );
                                  _scrollToBottom();
                                },
                                child: const Text('Réessayer'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _chatController.messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 56,
                              color: Colors.black.withValues(alpha: 0.15),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Aucun message pour le moment.\nCommencez la conversation !',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black38,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        itemCount: _chatController.messages.length,
                        itemBuilder: (context, index) {
                          final msg = _chatController.messages[index];
                          final isMe =
                              msg.senderId == _chatController.currentUserId;
                          return _MessageBubble(
                            message: msg,
                            isMe: isMe,
                            formatTime: _formatTime,
                          );
                        },
                      ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: Colors.black.withValues(alpha: 0.08),
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: 'Votre message...',
                            hintStyle: const TextStyle(color: Colors.black38),
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: _chatController.isSending
                            ? const SizedBox(
                                width: 44,
                                height: 44,
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: _kAmber,
                                  ),
                                ),
                              )
                            : GestureDetector(
                                onTap: _sendMessage,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    color: _kAmber,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final String Function(DateTime) formatTime;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    final Color bubbleColor = isMe ? const Color(0xFFFFB000) : Colors.white;
    final Color textColor = isMe ? Colors.white : const Color(0xFF2D2D2D);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 2),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.person, size: 16, color: AppColors.secondary),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                      height: 1.4,
                      fontWeight: isMe ? FontWeight.w500 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: isMe ? Colors.white70 : Colors.black26,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.done_all_rounded, size: 12, color: Colors.white70),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
