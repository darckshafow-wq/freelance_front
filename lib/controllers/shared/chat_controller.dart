import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import '../../services/api/api_core.dart';
import '../../services/api/api_endpoints.dart';
import '../../models/shared/message_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class ChatController extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<MessageModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _error;
  int _currentUserId = 0;
  bool _isClientRole = false;
  WebSocketChannel? _wsChannel;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;
  int get currentUserId => _currentUserId;
  bool get isClientRole => _isClientRole;

  /// Initialise l'utilisateur et charge la conversation
  Future<void> init({
    required int otherUserId,
    required int taskId,
    bool? isClient,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. On attend la fin de la résolution du rôle
      await resolveCurrentUser();

      // 2. Si un rôle est forcé, on l'utilise
      if (isClient != null) {
        _isClientRole = isClient;
      }

      // 3. On charge ensuite les messages
      await fetchMessages(otherUserId: otherUserId, taskId: taskId);

      // 4. Initialisation du WebSocket
      _initWebSocket();
    } catch (e) {
      _error = 'Erreur lors de l\'initialisation : $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Résout l'utilisateur courant et identifie son rôle (Client vs Freelance)
  Future<void> resolveCurrentUser() async {
    try {
      final resp = await _apiClient.get<Map<String, dynamic>>(
        endpoint: ApiEndpoints.meProfile,
        parser: (json) => json as Map<String, dynamic>,
      );
      if (resp.isSuccess && resp.data != null) {
        final data = resp.data!;
        // Sécurisation du cast
        _currentUserId = int.tryParse(data['id']?.toString() ?? '0') ?? 0;

        // 🔹 Vérification dynamique du rôle
        final String role = (data['role'] as String? ?? '').toLowerCase();
        final bool isClientFlag = data['is_client'] as bool? ?? false;

        _isClientRole = role == 'client' || isClientFlag;

        dev.log(
          '[ChatController] currentUserId : $_currentUserId | isClientRole : $_isClientRole',
        );
      }
    } catch (e) {
      dev.log('Erreur lors de la résolution de l\'utilisateur courant : $e');
    }
  }

  /// Récupère la liste des messages en fonction de l'interlocuteur (otherUserId)
  Future<void> fetchMessages({required int otherUserId, int? taskId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (otherUserId <= 0) {
      _isLoading = false;
      _error = 'Destinataire invalide.';
      notifyListeners();
      return;
    }

    try {
      // 🔀 Choix dynamique de la route selon le rôle
      final String targetEndpoint = _isClientRole
          ? ApiEndpoints.clientMessages(otherUserId)
          : ApiEndpoints.freelanceMessages(otherUserId);

      dev.log(
        '[ChatController] GET Request to: $targetEndpoint (isClient: $_isClientRole)',
      );

      final resp = await _apiClient.get<List<MessageModel>>(
        endpoint: targetEndpoint,
        parser: (json) {
          final list = json as List<dynamic>;
          return list
              .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );

      if (resp.isSuccess && resp.data != null) {
        // Inverser pour avoir le plus récent en bas
        _messages = resp.data!.reversed.toList();
        _isLoading = false;
        _error = null;
      } else {
        _isLoading = false;
        _error = resp.message ?? 'Erreur lors du chargement des messages.';
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Erreur réseau : $e';
    }
    notifyListeners();
  }

  /// Envoie un nouveau message
  Future<bool> sendMessage({
    required String text,
    required int otherUserId,
    required int? taskId,
  }) async {
    if (text.isEmpty || _isSending || otherUserId <= 0) return false;

    _isSending = true;
    notifyListeners();

    final Map<String, dynamic> requestBody = {
      'content': text,
      'receiver_id': otherUserId,
      if (taskId != null && taskId > 0) 'task_id': taskId,
    };

    // 🔀 Choix dynamique du POST selon le rôle
    final String targetEndpoint = _isClientRole
        ? ApiEndpoints.clientMessagesPost
        : ApiEndpoints.freelanceMessagesPost;

    dev.log('[ChatController] POST Request to: $targetEndpoint');

    final resp = await _apiClient.post<MessageModel>(
      endpoint: targetEndpoint,
      body: requestBody,
      parser: (json) => MessageModel.fromJson(json as Map<String, dynamic>),
    );

    if (resp.isSuccess && resp.data != null) {
      _messages.add(resp.data!);
      _isSending = false;
      notifyListeners();
      return true;
    } else {
      _isSending = false;
      _error = resp.message ?? 'Échec de l\'envoi';
      notifyListeners();
      return false;
    }
  }

  /// Initialise la connexion WebSocket
  void _initWebSocket() {
    try {
      if (_currentUserId <= 0) return;

      final wsUrl = ApiEndpoints.ws(_currentUserId.toString());
      dev.log('[ChatController] Connecting to WS: $wsUrl');

      // Ferme l'ancienne connexion s'il y en a une
      _wsChannel?.sink.close();

      _wsChannel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _wsChannel!.stream.listen(
        (data) {
          try {
            final Map<String, dynamic> payload = jsonDecode(data);
            if (payload['type'] == 'new_message' &&
                payload['message'] != null) {
              final newMsg = MessageModel.fromJson(payload['message']);
              // On vérifie si on n'a pas déjà ce message (pour éviter les doublons avec le propre envoi)
              if (!_messages.any((m) => m.id == newMsg.id)) {
                _messages.insert(0, newMsg); // on ajoute en haut (car inversé)
                notifyListeners();
              }
            }
          } catch (e) {
            dev.log('[ChatController] Erreur parsing WS data : $e');
          }
        },
        onError: (error) => dev.log('[ChatController] WS Error: $error'),
        onDone: () => dev.log('[ChatController] WS Connection closed'),
      );
    } catch (e) {
      dev.log('[ChatController] Exception lors de l\'init du WS : $e');
    }
  }

  @override
  void dispose() {
    _wsChannel?.sink.close();
    super.dispose();
  }
}
