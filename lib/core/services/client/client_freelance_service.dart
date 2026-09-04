import 'package:dio/dio.dart';
import 'package:freelance_front/core/constants/api_endpoints.dart';
import 'package:freelance_front/core/services/common/api_client.dart';
import 'package:freelance_front/core/models/common/user_model.dart';

class ClientFreelanceService {
  final Dio _dio = ApiClient.instance;

  Future<List<UserModel>> getFreelancers() async {
    try {
      final response = await _dio.get(ApiEndpoints.clientFreelancers);
      final data = response.data;
      if (data is List) {
        return data.map((json) => UserModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      // Si l'endpoint n'existe pas encore côté backend, on peut renvoyer une liste vide ou relancer l'erreur
      rethrow;
    }
  }

  Future<UserModel> getFreelanceDetail(int id) async {
    final response = await _dio.get(ApiEndpoints.clientFreelanceDetail(id));
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}

