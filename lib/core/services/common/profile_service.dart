import 'package:dio/dio.dart';
import 'package:freelance_front/core/services/common/api_client.dart';
import 'package:freelance_front/core/constants/api_endpoints.dart';
import 'package:freelance_front/core/models/common/user_model.dart';
import 'package:freelance_front/core/models/common/profile_model.dart';

class ProfileService {
  final Dio _dio = ApiClient.instance;

  Future<ProfileModel> getProfile() async {
    final response = await _dio.get(ApiEndpoints.usersMeProfile);
    return ProfileModel.fromJson(response.data);
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _dio.get(ApiEndpoints.usersMe);
    return UserModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<UserModel> updateProfile({
    String? fullName,
    String? bio,
    List<String>? skills,
    String? avatarUrl,
  }) async {
    final response = await _dio.put(
      ApiEndpoints.usersMeProfile,
      data: {
        if (fullName != null) 'full_name': fullName,
        if (bio != null) 'bio': bio,
        if (skills != null) 'skills': skills,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      },
    );
    return UserModel.fromJson(response.data);
  }

  Future<UserModel> updatePersonalInfo({
    String? fullName,
    String? email,
  }) async {
    final response = await _dio.patch(
      ApiEndpoints.usersMePersonal,
      data: {
        if (fullName != null) 'full_name': fullName,
        if (email != null) 'email': email,
      },
    );
    return UserModel.fromJson(response.data);
  }
}
