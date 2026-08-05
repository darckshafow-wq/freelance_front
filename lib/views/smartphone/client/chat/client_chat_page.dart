import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../constants/app_colors.dart';
import '../../../../controllers/shared/chat_controller.dart';
import '../../../../models/shared/message_model.dart';
import '../../../../controllers/client/application_controller.dart';
import '../../../../models/freelance/application_model.dart';
import '../../../../utils/ui/ui_utils.dart';

class ClientChatPage extends StatefulWidget {
  final int otherUserId;
  final String? otherUserName;
  final int taskId;
  final int applicationId;
  final String? initialStatus;

  const ClientChatPage({
    super.key,
    this.otherUserId = 0,
    this.otherUserName,
    required this.taskId,
    this.applicationId = 0,
    this.initialStatus,
  });

  @override
  State<ClientChatPage> createState() => _ClientChatPageState();
}

class _ClientChatPageState extends State<ClientChatPage> {
  final ChatController _chatController = ChatController();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  ApplicationStatus? _currentStatus;

  @override
  void initState() {
    super.initState();
    if (widget.initialStatus != null) {
      _currentStatus = ApplicationStatus.fromString(widget.initialStatus!);
    }
    
    _chatController.init(
      taskId: widget.taskId,
      otherUserId: widget.otherUserId,
      isClient: true,
    );
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
      if (_currentStatus == ApplicationStatus.pending) {
        setState(() => _currentStatus = ApplicationStatus.interview);
      }
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

  Widget _buildActionHeader(ClientApplicationController appController) {
    if (widget.applicationId == 0) return const SizedBox.shrink();

    final bool isAccepted = _currentStatus == ApplicationStatus.accepted;
    final bool isRejected = _currentStatus == ApplicationStatus.rejected;

    if (isRejected) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isAccepted ? AppColors.success : Colors.black,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: (isAccepted ? AppColors.success : Colors.black).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAccepted ? Icons.verified_rounded : Icons.work_outline_rounded,
              color: isAccepted ? Colors.white : AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isAccepted ? 'Mission attribuée' : 'Candidature',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                Text(
                  isAccepted
                      ? 'Freelance en mission'
                      : 'Prêt à commencer ?',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (!isAccepted) ...[
            if (appController.isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            else ...[
              // Bouton Refuser
              TextButton(
                onPressed: () async {
                  final confirm = await UIUtils.showConfirm(
                    context,
                    title: 'Refuser ?',
                    message: 'Souhaitez-vous écarter cette candidature ?',
                    confirmLabel: 'Refuser',
                    isDestructive: true,
                  );
                  if (confirm == true && mounted) {
                    final success = await appController.rejectApplication(widget.applicationId);
                    if (!mounted) return;
                    if (success) {
                      setState(() => _currentStatus = ApplicationStatus.rejected);
                      UIUtils.showInfo(context, 'Candidature refusée');
                    } else {
                      UIUtils.showError(context, appController.errorMessage ?? 'Erreur');
                    }
                  }
                },
                child: const Text('Décliner', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 4),
              // Bouton Attribuer
              ElevatedButton(
                onPressed: () async {
                  final confirm = await UIUtils.showConfirm(
                    context,
                    title: 'Attribuer la mission',
                    message: 'Confirmer le choix de ce freelance pour votre projet ?',
                    confirmLabel: 'Confirmer',
                  );
                  if (confirm == true && mounted) {
                    final success = await appController.acceptApplication(widget.applicationId);
                    if (!mounted) return;
                    if (success) {
                      setState(() => _currentStatus = ApplicationStatus.accepted);
                      UIUtils.showSuccess(context, 'Mission attribuée avec succès !');
                    } else {
                      UIUtils.showError(context, appController.errorMessage ?? 'Erreur');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.secondary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  minimumSize: const Size(0, 40),
                ),
                child: const Text('Attribuer', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
              ),
            ],
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.otherUserName ?? 'Conversation';
    final appController = context.watch<ClientApplicationController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.black,
              child: Text(
                title.isNotEmpty ? title[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const Text(
                  'Freelance',
                  style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.black),
            onPressed: () async {
              await _chatController.fetchMessages(
                otherUserId: widget.otherUserId,
                taskId: widget.taskId,
              );
              _scrollToBottom();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
        ),
      ),
      body: ListenableBuilder(
        listenable: _chatController,
        builder: (context, child) {
          return Column(
            children: [
              _buildActionHeader(appController), 
              Expanded(
                child: _chatController.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.black,
                        ),
                      )
                    : _chatController.error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                size: 48,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _chatController.error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () async {
                                  await _chatController.fetchMessages(
                                    otherUserId: widget.otherUserId,
                                    taskId: widget.taskId,
                                  );
                                  _scrollToBottom();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
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
                              color: Colors.black.withValues(alpha: 0.05),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Démarrer la discussion...',
                              style: TextStyle(
                                color: Colors.black26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                        itemCount: _chatController.messages.length,
                        itemBuilder: (context, index) {
                          final msg = _chatController.messages[index];
                          final isMe = msg.senderId == _chatController.currentUserId;
                          return _MessageBubble(
                            message: msg,
                            isMe: isMe,
                            formatTime: _formatTime,
                          );
                        },
                      ),
              ),
              _buildInputArea(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 34),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.add_rounded, color: Colors.black54, size: 28),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              ),
              child: TextField(
                controller: _inputController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 5,
                minLines: 1,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                decoration: const InputDecoration(
                  hintText: 'Message...',
                  hintStyle: TextStyle(color: Colors.black38, fontSize: 15),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: _chatController.isSending
                  ? const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      ),
                    )
                  : const Icon(Icons.arrow_upward_rounded, color: AppColors.primary, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.formatTime,
  });

  final MessageModel message;
  final bool isMe;
  final String Function(DateTime) formatTime;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isMe ? Colors.black : const Color(0xFFF2F2F7);
    final textColor = isMe ? Colors.white : Colors.black;
    final alignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: Radius.circular(isMe ? 20 : 4),
      bottomRight: Radius.circular(isMe ? 4 : 20),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: borderRadius,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
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
                        color: isMe ? Colors.white54 : Colors.black38,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.done_all_rounded, size: 12, color: AppColors.primary),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
