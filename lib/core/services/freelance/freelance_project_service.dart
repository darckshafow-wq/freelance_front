import 'package:dio/dio.dart';
import 'package:freelance_front/core/constants/api_endpoints.dart';
import 'package:freelance_front/core/services/common/api_client.dart';
import 'package:freelance_front/core/services/common/mock_data.dart';
import 'package:freelance_front/core/models/common/project_model.dart';
import 'package:freelance_front/core/models/common/proposal_model.dart';

class FreelanceProjectService {
  final Dio _dio = ApiClient.instance;

  Future<List<ProjectModel>> getNearbyProjects({String? categoryId, double? lat, double? lng}) async {
    if (MockData.useFreelanceMock) {
      return MockData.mockProjects.map((json) => ProjectModel.fromJson(json)).toList();
    }
    final response = await _dio.get(
      ApiEndpoints.freelanceProjectsNearby,
      queryParameters: {
        if (categoryId != null) 'category_id': categoryId,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
      },
    );
    return (response.data as List).map((json) => ProjectModel.fromJson(json)).toList();
  }

  Future<ProjectModel> getProjectDetail(int projectId) async {
    final response = await _dio.get(ApiEndpoints.projectDetail(projectId));
    return ProjectModel.fromJson(response.data);
  }

  Future<bool> submitProposal(int projectId, double proposedPrice, String message) async {
    final response = await _dio.post(
      ApiEndpoints.freelanceProjectProposals(projectId),
      data: {
        'proposed_price': proposedPrice.toInt(),
        'message': message,
      },
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> markAsArrived(int projectId) async {
    final response = await _dio.post(ApiEndpoints.freelanceProjectArrived(projectId));
    return response.statusCode == 200;
  }

  Future<bool> markAsFinished(int projectId) async {
    final response = await _dio.post(ApiEndpoints.freelanceProjectFinished(projectId));
    return response.statusCode == 200;
  }

  // ==========================================
  // DIRECT OFFERS
  // ==========================================
  Future<List<ProposalModel>> getDirectOffers() async {
    final response = await _dio.get(ApiEndpoints.freelanceDirectOffers);
    final List data = response.data is List ? response.data : [];
    return data.map((json) => ProposalModel.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  Future<bool> acceptDirectOffer(int proposalId) async {
    final response = await _dio.post(ApiEndpoints.freelanceDirectOfferAccept(proposalId));
    return response.statusCode == 200;
  }

  Future<bool> rejectDirectOffer(int proposalId) async {
    final response = await _dio.post(ApiEndpoints.freelanceDirectOfferReject(proposalId));
    return response.statusCode == 200;
  }

  Future<bool> submitReview(int targetId, String role, int rating, String comment) async {
    final response = await _dio.post(
      ApiEndpoints.reviews,
      data: {
        'target_id': targetId,
        'role': role,
        'rating': rating,
        'comment': comment,
      },
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }
}
