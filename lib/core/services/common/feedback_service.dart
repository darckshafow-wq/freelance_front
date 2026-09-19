import 'package:dio/dio.dart';
import 'package:freelance_front/core/constants/api_endpoints.dart';
import 'package:freelance_front/core/models/admin/feedback_model.dart';
import 'package:freelance_front/core/services/common/api_client.dart';

import 'package:freelance_front/core/services/common/storage_service.dart';

class FeedbackService {
  final Dio _dio = ApiClient.instance;

  Future<List<FeedbackModel>> getMyTickets() async {
    final String? role = await StorageService.readUserRole();
    final String endpoint = role == 'FREELANCE' 
        ? ApiEndpoints.freelanceFeedbackMyTickets 
        : ApiEndpoints.clientFeedbackMyTickets;
        
    final response = await _dio.get(endpoint);
    return (response.data as List).map((json) => FeedbackModel.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  Future<FeedbackModel> createTicket({required String subject, required String content}) async {
    final String? role = await StorageService.readUserRole();
    final String endpoint = role == 'FREELANCE' 
        ? ApiEndpoints.freelanceFeedback 
        : ApiEndpoints.clientFeedback;

    final response = await _dio.post(endpoint, data: {'subject': subject, 'content': content});
    return FeedbackModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<List<FeedbackModel>> getPendingTickets() async {
    final response = await _dio.get(ApiEndpoints.adminFeedbacksPending);
    return (response.data as List).map((json) => FeedbackModel.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  Future<FeedbackModel> replyToTicket(int id, String reply) async {
    final response = await _dio.post(ApiEndpoints.adminFeedbackReply(id), data: {'reply': reply});
    return FeedbackModel.fromJson(Map<String, dynamic>.from(response.data));
  }
}
