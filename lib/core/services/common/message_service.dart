import 'package:dio/dio.dart';

import 'package:freelance_front/core/services/common/api_client.dart';
import 'package:freelance_front/core/models/common/message_model.dart';
import 'package:freelance_front/core/models/common/conversation_model.dart';
import 'package:freelance_front/core/constants/api_endpoints.dart';

class MessageService {
  final Dio _dio = ApiClient.instance;

  Future<List<MessageModel>> getMessages(int projectId) async {
    final response = await _dio.get(ApiEndpoints.projectMessages(projectId));

    if (response.statusCode != 200) {
      throw Exception('Erreur de chargement des messages');
    }

    final data = response.data as List;
    return data
        .map((json) => MessageModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<void> markAsRead(int projectId) async {
    await _dio.patch(ApiEndpoints.projectMessagesRead(projectId));
  }

  Future<List<ConversationModel>> getConversations() async {
    final response = await _dio.get(ApiEndpoints.clientConversations);
    if (response.statusCode != 200) throw Exception('Erreur de chargement des conversations');
    return (response.data as List).map((json) => ConversationModel.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  Future<MessageModel> sendMessage(int projectId, String content) async {
    final response = await _dio.post(ApiEndpoints.projectMessages(projectId), data: {'content': content});
    return MessageModel.fromJson(Map<String, dynamic>.from(response.data));
  }
}
