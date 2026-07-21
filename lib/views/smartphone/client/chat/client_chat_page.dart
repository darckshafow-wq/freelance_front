import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import '../../../../services/api/api_core.dart';
import '../../../../services/api/api_endpoints.dart';
import '../../../../constants/app_colors.dart';

class ClientChatPage extends StatefulWidget {
  final int otherUserId;
  final String? otherUserName;
  final int? taskId;

  const ClientChatPage({
    super.key,
    this.otherUserId = 0,
    this.otherUserName,
    this.taskId,
  });

  @override
  State<ClientChatPage> createState() => _ClientChatPageState();
}

class _MessageModel {
  final int id;
  final String content;
  final int senderId;
  final int receiverId;
  final int? taskId;
  final DateTime timestamp;

  _MessageModel({
    required this.id,
    required this.content,
    required this.senderId,
    required this.receiverId,
    this.taskId,
    required this.timestamp,
  });

  factory _MessageModel.fromJson(Map<String, dynamic> json) {
    return _MessageModel(
      id: json['id'] as int? ?? 0,
      content: (json['content'] ?? json['message'] ?? '').toString(),
      senderId: json['sender_id'] as int? ?? 0,
      receiverId: json['receiver_id'] as int? ?? 0,
      taskId: json['task_id'] as int?,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class _ClientChatPageState extends State<ClientChatPage> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<_MessageModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _error;
  int _currentUserId = 1;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await _resolveCurrentUser();
    await _fetchMessages();
  }

  Future<void> _resolveCurrentUser() async {
    try {
      final resp = await _apiClient.get<Map<String, dynamic>>(
        endpoint: ApiEndpoints.me,
        parser: (json) => json as Map<String, dynamic>,
      );
      if (resp.isSuccess && resp.data != null) {
        setState(() {
          _currentUserId = resp.data!['id'] as int? ?? 0;
        });
        dev.log('[ClientChatPage] currentUserId résolu : $_currentUserId');
      }
    } catch (e) {
      dev.log('Erreur lors de la résolution de l\'utilisateur courant : $e');
    }
  }

  Future<void> _fetchMessages() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    if (widget.otherUserId <= 0) {
      setState(() {
        _isLoading = false;
        _error = 'Aucun contact sélectionné.';
      });
      return;
    }

    final String targetEndpoint = ApiEndpoints.freelanceMessages(
      widget.otherUserId,
    );
    final resp = await _apiClient.get<List<_MessageModel>>(
      endpoint: targetEndpoint,
      parser: (json) {
        final list = json as List<dynamic>;
        return list
            .map((e) => _MessageModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );

    if (!mounted) return;
    if (resp.isSuccess && resp.data != null) {
      setState(() {
        _messages = resp.data!.reversed.toList();
        _isLoading = false;
        _error = null;
      });
      _scrollToBottom();
    } else {
      setState(() {
        _isLoading = false;
        _error = resp.message ?? 'Erreur lors du chargement des messages.';
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isSending || widget.otherUserId <= 0) return;

    setState(() => _isSending = true);
    _inputController.clear();

    final Map<String, dynamic> requestBody = {
      'content': text,
      'receiver_id': widget.otherUserId,
      'task_id': widget.taskId,
    };

    final resp = await _apiClient.post<_MessageModel>(
      endpoint: ApiEndpoints.freelanceMessagesPost,
      body: requestBody,
      parser: (json) => _MessageModel.fromJson(json as Map<String, dynamic>),
    );

    if (!mounted) return;
    if (resp.isSuccess && resp.data != null) {
      setState(() {
        _messages.add(resp.data!);
        _isSending = false;
      });
      _scrollToBottom();
    } else {
      setState(() => _isSending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resp.message ?? 'Échec de l\'envoi'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
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

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.otherUserName ?? 'Conversation';

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.accent,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMessages,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  )
                : _error != null
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
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black45),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _fetchMessages,
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _messages.isEmpty
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
                          style: TextStyle(color: Colors.black38, fontSize: 14),
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
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg.senderId == _currentUserId;
                      return _MessageBubble(
                        message: msg,
                        isMe: isMe,
                        formatTime: _formatTime,
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
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
                    child: _isSending
                        ? const SizedBox(
                            width: 44,
                            height: 44,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.accent,
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: _sendMessage,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: AppColors.accent,
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

  final _MessageModel message;
  final bool isMe;
  final String Function(DateTime) formatTime;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isMe
        ? const Color(0xFFFFE7B8)
        : const Color(0xFFFFFFFF);
    final textColor = isMe ? Colors.black87 : Colors.black87;
    final alignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isMe ? 18 : 6),
      bottomRight: Radius.circular(isMe ? 6 : 18),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: TextStyle(color: textColor, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 6),
                Text(
                  formatTime(message.timestamp),
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.45),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
