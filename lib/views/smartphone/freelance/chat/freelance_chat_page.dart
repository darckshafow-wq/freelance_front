import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import '../../../../services/api/api_core.dart';
import '../../../../services/api/api_endpoints.dart';

// ─── Modèle léger pour un message ────────────────────────────────────────────
class _MessageModel {
  final int id;
  final String content;
  final int senderId;
  final int receiverId;
  final DateTime timestamp;

  _MessageModel({
    required this.id,
    required this.content,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
  });

  factory _MessageModel.fromJson(Map<String, dynamic> json) {
    return _MessageModel(
      id: json['id'] as int? ?? 0,
      content: (json['content'] ?? json['message'] ?? '').toString(),
      senderId: json['sender_id'] as int? ?? 0,
      receiverId: json['receiver_id'] as int? ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

// ─── Page de chat ─────────────────────────────────────────────────────────────
class FreelanceChatPage extends StatefulWidget {
  final int otherUserId;
  final String? otherUserName;

  const FreelanceChatPage({
    super.key,
    this.otherUserId = 0,
    this.otherUserName,
  });

  @override
  State<FreelanceChatPage> createState() => _FreelanceChatPageState();
}

class _FreelanceChatPageState extends State<FreelanceChatPage> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<_MessageModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _error;

  // L'ID de l'utilisateur courant — résolu via /users/me
  int _currentUserId = 0;

  static const Color _kAmber = Color(0xFFFFB000);
  static const Color _kBg = Color(0xFFFDFBF7);

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

  /// Résout l'ID courant via /users/me (token déjà stocké dans ApiClient)
  Future<void> _resolveCurrentUser() async {
    final resp = await _apiClient.get<Map<String, dynamic>>(
      endpoint: ApiEndpoints.me,
      parser: (json) => json as Map<String, dynamic>,
    );
    if (resp.isSuccess && resp.data != null) {
      _currentUserId = resp.data!['id'] as int? ?? 0;
      dev.log('[FreelanceChatPage] currentUserId resolved: $_currentUserId');
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

    final resp = await _apiClient.get<List<_MessageModel>>(
      endpoint: ApiEndpoints.conversation(widget.otherUserId),
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
        // Le backend retourne du plus récent au plus ancien — on inverse
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

    final resp = await _apiClient.post<_MessageModel>(
      endpoint: ApiEndpoints.messages,
      body: {
        'receiver_id': widget.otherUserId,
        'content': text,
      },
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
          // ── Liste des messages ─────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _kAmber),
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
                            color: Colors.black26,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black45),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _fetchMessages,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Réessayer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kAmber,
                              foregroundColor: Colors.white,
                            ),
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

          // ── Barre de saisie ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                    child: _isSending
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
      ),
    );
  }
}

// ─── Bulle de message ─────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final _MessageModel message;
  final bool isMe;
  final String Function(DateTime) formatTime;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    const Color _kAmber = Color(0xFFFFB000);
    const Color _kAmberLight = Color(0xFFFFEDC1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: _kAmberLight,
              child: const Icon(Icons.person, size: 18, color: _kAmber),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? _kAmber : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: isMe ? Colors.white : const Color(0xFF2D2D2D),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }
}
