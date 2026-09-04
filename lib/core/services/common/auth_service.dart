import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:freelance_front/core/constants/api_endpoints.dart';
import 'package:freelance_front/core/services/common/api_client.dart';
import 'package:freelance_front/core/models/common/user_model.dart';

class AuthService {
  final Dio _dio = ApiClient.instance;

  /// Connexion classique (email / mot de passe)
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    debugPrint('➡️ [AuthService] Demande de connexion pour: $email');
    
    try {
      final response = await _dio.post(
        ApiEndpoints.authLogin,
        data: {
          'username': email,
          'password': password,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      
      debugPrint('✅ [AuthService] Connexion réussie, status: ${response.statusCode}');
      debugPrint('📦 [AuthService] Payload reçu: ${response.data}');
      
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('❌ [AuthService] Erreur API lors de la connexion: ${e.response?.statusCode} - ${e.response?.data}');
      rethrow;
    }
  }

  /// Connexion sécurisée avec code 2FA / TOTP
  Future<Map<String, dynamic>> loginWithTotp({
    required String username,
    required String password,
    required String totpCode,
  }) async {

    final response = await _dio.post(
      ApiEndpoints.authLoginTOTP,
      data: {
        'username': username,
        'password': password,
        'totp_code': totpCode,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    return response.data as Map<String, dynamic>;
  }

  /// Inscription d'un nouvel utilisateur (Freelance / Client)
  Future<UserModel> register({
    required String email,
    required String fullName,
    required String password,
    required String role,
  }) async {

    final response = await _dio.post(
      ApiEndpoints.authRegister,
      data: {
        'email': email,
        'full_name': fullName,
        'password': password,
        'role': role,
      },
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Récupération des informations de l'utilisateur connecté (/users/me)
  Future<UserModel> getCurrentUser() async {

    final response = await _dio.get(ApiEndpoints.usersMe);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}
