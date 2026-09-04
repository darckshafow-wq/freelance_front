import 'package:dio/dio.dart';

import 'package:freelance_front/core/services/common/api_client.dart';
import 'package:freelance_front/core/models/common/project_model.dart';
import 'package:freelance_front/core/models/common/proposal_model.dart';
import 'package:freelance_front/core/models/common/review_model.dart';
import 'package:freelance_front/core/constants/api_endpoints.dart';
import 'package:freelance_front/core/models/admin/category_model.dart';

class ProjectService {
  final Dio _dio = ApiClient.instance;

  Future<List<ProjectModel>> getProjects() async {
    final response = await _dio.get(ApiEndpoints.freelanceProjects);

    if (response.statusCode != 200) {
      throw Exception('Erreur de chargement des projets');
    }

    final data = response.data as List;
    return data.map((json) => ProjectModel.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  Future<List<ProjectModel>> getClientProjects({String? status}) async {
    final Map<String, dynamic> params = {};
    if (status != null) params['status'] = status;

    final response = await _dio.get(ApiEndpoints.clientProjects, queryParameters: params);

    if (response.statusCode != 200) {
      throw Exception('Erreur de chargement de vos projets');
    }

    final data = response.data as List;
    return data.map((json) => ProjectModel.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  Future<List<ProjectModel>> getPublicProjects({String? categoryId}) async {
    final response = await _dio.get(ApiEndpoints.clientPublicProjects, queryParameters: {if (categoryId != null) 'category_id': categoryId});
    if (response.statusCode != 200) throw Exception('Erreur de chargement des missions publiques');
    return (response.data as List).map((json) => ProjectModel.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  Future<List<CategoryModel>> getClientCategories() async {
    final response = await _dio.get(ApiEndpoints.clientCategories);
    if (response.statusCode != 200) throw Exception('Erreur de chargement des catégories');
    return (response.data as List).map((json) => CategoryModel.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  Future<Map<String, dynamic>> getProposalFreelanceProfile(int proposalId) async {
    final response = await _dio.get(ApiEndpoints.clientProposalFreelanceProfile(proposalId));
    return Map<String, dynamic>.from(response.data);
  }

  Future<List<Map<String, dynamic>>> getProposalTimeline(int proposalId) async {
    final response = await _dio.get(ApiEndpoints.clientProposalTimeline(proposalId));
    return (response.data as List).map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<ProjectModel> getProjectById(int projectId) async {
    final projects = await getClientProjects();
    return projects.firstWhere((project) => project.id == projectId, orElse: () => throw Exception('Mission introuvable'));
  }

  Future<List<ReviewModel>> getClientReviews() async {
    final response = await _dio.get(ApiEndpoints.reviews);
    if (response.statusCode != 200) throw Exception('Erreur de chargement des avis');
    return (response.data as List).map((json) => ReviewModel.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  Future<ProjectModel> createProject(ProjectModel project) async {
    final response = await _dio.post(ApiEndpoints.clientProjects, data: project.toJson());

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Erreur lors de la création du projet');
    }

    return ProjectModel.fromJson(response.data);
  }

  Future<List<ProposalModel>> getProjectProposals(int projectId) async {
    final response = await _dio.get(ApiEndpoints.clientProposals);

    if (response.statusCode != 200) {
      throw Exception('Erreur de chargement des propositions');
    }

    final data = response.data as List;
    return data.map((json) => ProposalModel.fromJson(Map<String, dynamic>.from(json))).where((proposal) => proposal.projectId == projectId).toList();
  }

  Future<List<ProposalModel>> getClientProposals() async {
    final response = await _dio.get(ApiEndpoints.clientProposals);
    if (response.statusCode != 200) throw Exception('Erreur de chargement des propositions');
    return (response.data as List)
        .map((json) => ProposalModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<bool> cancelProject(int projectId) async => (await _dio.post(ApiEndpoints.clientProjectCancel(projectId))).statusCode == 200;

  Future<bool> validateProject(int projectId) async => (await _dio.post(ApiEndpoints.clientProjectValidate(projectId))).statusCode == 200;

  Future<bool> acceptProposal(int proposalId) async => (await _dio.post(ApiEndpoints.clientProposalAccept(proposalId))).statusCode == 200;

  Future<bool> submitReview({required int targetId, required int rating, required String comment}) async {
    final response = await _dio.post(ApiEndpoints.reviews, data: {
      'target_id': targetId,
      'role': 'FREELANCE',
      'rating': rating,
      'comment': comment,
    });
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> sendDirectOffer({required int projectId, required int freelanceId, required double proposedPrice, String? message}) async {
    final response = await _dio.post(ApiEndpoints.clientProjectDirectOffer(projectId), data: {
      'freelance_id': freelanceId,
      'message': message,
      'proposed_price': proposedPrice,
    });
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<Map<String, dynamic>> getClientStats() async {
    final response = await _dio.get(ApiEndpoints.clientStats);
    return Map<String, dynamic>.from(response.data);
  }

  Future<bool> createReport({required String reason, int? targetId, int? projectId}) async {
    final response = await _dio.post(ApiEndpoints.clientReports, data: {
      'reason': reason,
      if (targetId != null) 'target_id': targetId,
      if (projectId != null) 'project_id': projectId,
    });
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<List<dynamic>> getFiledReports() async {
    final response = await _dio.get(ApiEndpoints.clientReportsFiled);
    return response.data as List<dynamic>;
  }
}
