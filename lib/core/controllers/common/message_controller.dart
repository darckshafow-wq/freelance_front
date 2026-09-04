import 'package:flutter/material.dart';

import 'package:freelance_front/core/models/common/message_model.dart';
import 'package:freelance_front/core/services/common/message_service.dart';

class MessageController extends ChangeNotifier {
  final MessageService _messageService = MessageService();

  List<MessageModel> messages = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchMessages(int projectId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      messages = await _messageService.getMessages(projectId);
    } catch (e) {
      errorMessage = 'Erreur lors du chargement des messages.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
