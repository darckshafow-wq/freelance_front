import 'package:dio/dio.dart';
import 'package:freelance_front/core/services/common/api_client.dart';
import 'package:freelance_front/core/constants/api_endpoints.dart';
import 'package:freelance_front/core/models/common/user_model.dart';
import 'package:freelance_front/core/models/common/project_model.dart';
import 'package:freelance_front/core/models/admin/category_model.dart';

class AdminService {
  final Dio _dio = ApiClient.instance;

  Future<Map<String, dynamic>> getOverview() async {
    final response = await _dio.get(ApiEndpoints.adminOverview);
    return Map<String, dynamic>.from(response.data);
  }

  Future<List<UserModel>> getUsers() async {
    final response = await _dio.get(ApiEndpoints.adminUsers);
    final List data = response.data is List ? response.data : [];
    return data.map((json) => UserModel.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  Future<bool> suspendUser(int userId) async {
    final response = await _dio.post(ApiEndpoints.adminUserSuspend(userId));
    return response.statusCode == 200;
  }

  Future<bool> activateUser(int userId) async {
    final response = await _dio.post(ApiEndpoints.adminUserActivate(userId));
    return response.statusCode == 200;
  }

  Future<bool> verifyIdentity(int userId) async {
    final response = await _dio.put(ApiEndpoints.adminUserVerifyIdentity(userId));
    return response.statusCode == 200;
  }

  Future<List<ProjectModel>> getProjects() async {
    final response = await _dio.get(ApiEndpoints.adminProjects);
    final List data = response.data is List ? response.data : [];
    return data.map((json) => ProjectModel.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  Future<bool> deleteProject(int projectId) async {
    final response = await _dio.delete(ApiEndpoints.adminProjectDelete(projectId));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<List<dynamic>> getReports() async {
    final response = await _dio.get(ApiEndpoints.adminReports);
    return response.data is List ? response.data : [];
  }

  Future<bool> resolveReport(int reportId) async {
    final response = await _dio.post(ApiEndpoints.adminReportResolve(reportId));
    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>> getStats() async {
    final response = await _dio.get(ApiEndpoints.adminStats);
    return Map<String, dynamic>.from(response.data);
  }

  Future<List<dynamic>> getAuditLogs() async {
    final response = await _dio.get(ApiEndpoints.adminAuditLogs);
    return response.data is List ? response.data : [];
  }

  Future<List<dynamic>> getSystemWarnings() async {
    final response = await _dio.get(ApiEndpoints.adminSystemWarnings);
    return response.data is List ? response.data : [];
  }

  Future<bool> resolveSystemWarning(int warningId) async {
    final response = await _dio.put(ApiEndpoints.adminSystemWarningResolve(warningId));
    return response.statusCode == 200;
  }

  Future<List<dynamic>> getPendingFeedbacks() async {
    final response = await _dio.get(ApiEndpoints.adminFeedbacksPending);
    return response.data is List ? response.data : [];
  }

  Future<bool> replyToFeedback(int feedbackId, String reply) async {
    final response = await _dio.post(ApiEndpoints.adminFeedbackReply(feedbackId), data: {'reply': reply});
    return response.statusCode == 200;
  }

  Future<List<CategoryModel>> getCategories() async {
    final response = await _dio.get(ApiEndpoints.adminCategories);
    final List data = response.data is List ? response.data : [];
    return data.map((json) => CategoryModel.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  Future<CategoryModel> createCategory(String name, String description) async {
    final response = await _dio.post(ApiEndpoints.adminCategories, data: {
      'name': name,
      'description': description,
    });
    return CategoryModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<bool> updateCategory(int categoryId, String name, String description) async {
    final response = await _dio.put(ApiEndpoints.adminCategoryUpdate(categoryId), data: {
      'name': name,
      'description': description,
    });
    return response.statusCode == 200;
  }

  Future<bool> sendBroadcast(String title, String message, {String? target}) async {
    final response = await _dio.post(ApiEndpoints.adminBroadcast, data: {
      'title': title,
      'content': message,
      if (target != null) 'target': target,
    });
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // ==========================================
  // LOCATIONS
  // ==========================================
  Future<List<dynamic>> getCountries() async {
    final response = await _dio.get(ApiEndpoints.locationsCountries);
    return response.data is List ? response.data : [];
  }

  Future<List<dynamic>> getCities(int countryId) async {
    final response = await _dio.get(ApiEndpoints.locationsCities(countryId));
    return response.data is List ? response.data : [];
  }

  Future<List<dynamic>> getDistricts(int cityId) async {
    final response = await _dio.get(ApiEndpoints.locationsDistricts(cityId));
    return response.data is List ? response.data : [];
  }

  Future<Map<String, dynamic>> getCountryFull(int countryId) async {
    final response = await _dio.get(ApiEndpoints.locationCountryFull(countryId));
    return Map<String, dynamic>.from(response.data);
  }

  Future<bool> createCountry(String name, String code) async {
    final response = await _dio.post(ApiEndpoints.adminLocationsCountries, data: {
      'name': name,
      'code': code,
    });
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> updateCountry(int countryId, String name, String code) async {
    final response = await _dio.put('${ApiEndpoints.adminLocationsCountries}/$countryId', data: {
      'name': name,
      'code': code,
    });
    return response.statusCode == 200;
  }

  Future<bool> deleteCountry(int countryId) async {
    final response = await _dio.delete(ApiEndpoints.adminLocationCountryDelete(countryId));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<bool> createCity(int countryId, String name, double latitude, double longitude) async {
    final response = await _dio.post(ApiEndpoints.adminLocationsCities, data: {
      'country_id': countryId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    });
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> updateCity(int cityId, String name, double latitude, double longitude) async {
    final response = await _dio.put('${ApiEndpoints.adminLocationsCities}/$cityId', data: {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    });
    return response.statusCode == 200;
  }

  Future<bool> deleteCity(int cityId) async {
    final response = await _dio.delete(ApiEndpoints.adminLocationCityDelete(cityId));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<bool> createDistrict(int cityId, String name, double latitude, double longitude) async {
    final response = await _dio.post(ApiEndpoints.adminLocationsDistricts, data: {
      'city_id': cityId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    });
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> deleteDistrict(int districtId) async {
    final response = await _dio.delete(ApiEndpoints.adminLocationDistrictDelete(districtId));
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
