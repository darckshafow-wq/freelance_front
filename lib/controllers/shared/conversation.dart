import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import '../../services/api/api_core.dart';
import '../../services/api/api_endpoints.dart';
import '../../models/shared/conversation_model.dart';

class ChatListController extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<ConversationContact> _contacts = [];
  bool _isLoading = false;
  String? _error;

  List<ConversationContact> get conversations => _contacts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? msg) {
    _error = msg;
    notifyListeners();
  }

  /// Récupère la liste globale des conversations de l'utilisateur connecté.
  /// Le paramètre currentUserId est conservé pour les logs, mais n'est plus passé
  /// à l'URL car l'API FastAPI identifie l'utilisateur via son token Bearer.
  Future<void> fetchConversations(int currentUserId) async {
    dev.log(
      '[ChatListController] fetchConversations() started for user $currentUserId',
    );
    _setLoading(true);
    _setError(null);

    // Utilise l'endpoint des conversations présent dans l'OpenAPI backend.
    final resp = await _apiClient.get<List<ConversationContact>>(
      endpoint: ApiEndpoints.freelanceConversations,
      parser: (json) {
        final list = json as List<dynamic>;
        return list
            .map((e) => ConversationContact.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );

    if (resp.isSuccess && resp.data != null) {
      _contacts = resp.data!;

      // Tri sécurisé par date de dernier message (plus récent au plus ancien)
      _contacts.sort((a, b) => b.lastTimestamp.compareTo(a.lastTimestamp));

      _isLoading = false;
      notifyListeners();
    } else {
      _error = resp.message ?? 'Erreur lors du chargement des discussions.';
      _isLoading = false;
      notifyListeners();
    }
  }

  String formatTime(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inDays == 0 && now.day == dt.day) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } else if (difference.inDays < 7) {
      final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      return days[dt.weekday - 1];
    } else {
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
    }
  }
}
