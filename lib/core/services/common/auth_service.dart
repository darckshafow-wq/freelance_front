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
      return Map<String, dynamic>.from(response.data);
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
    return Map<String, dynamic>.from(response.data);
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
    return UserModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  /// Récupération des informations de l'utilisateur connecté (/users/me)
  Future<UserModel> getCurrentUser() async {
    final response = await _dio.get(ApiEndpoints.usersMe);
    return UserModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  /// Demande de réinitialisation de mot de passe
  Future<bool> requestPasswordReset(String email) async {
    final response = await _dio.post(
      ApiEndpoints.authPwdResetReq,
      data: {'email': email},
    );
    return response.statusCode == 200;
  }

  /// Activation du 2FA
  Future<Map<String, dynamic>> enable2FA() async {
    final response = await _dio.post(ApiEndpoints.authEnable2FA);
    return Map<String, dynamic>.from(response.data);
  }

  /// Vérification du 2FA pour finaliser l'activation
  Future<bool> verify2FA(String code) async {
    final response = await _dio.post(
      ApiEndpoints.authVerify2FA,
      data: {'code': code},
    );
    return response.statusCode == 200;
  }
}
