import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import '../../models/auth/user_model.dart';
import '../../services/api/api_core.dart';
import '../../services/api/api_endpoints.dart';

class AuthController extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Login using FastAPI OAuth2 standard password flow (form URL encoded)
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    dev.log('[AuthController] login() start email=$email');

    final response = await _apiClient.post<Map<String, dynamic>>(
      endpoint: ApiEndpoints.login,
      body: {'username': email, 'password': password},
      parser: (json) => json as Map<String, dynamic>,
      requiresAuth: false,
      isFormUrlEncoded: true, // FastAPI OAuth2 standard uses formUrlEncoded
    );

    if (response.isSuccess && response.data != null) {
      final token = response.data!['access_token'] as String;
      ApiClient.setToken(token);
      dev.log('[AuthController] login() success token=${token.isNotEmpty}');

      // Standard OAuth2 ne retourne pas user_id — on récupère le profil via /users/me
      final userId = response.data!['user_id'] as int?;
      dev.log('[AuthController] login() response userId=$userId');

      if (userId != null && userId > 0) {
        return await fetchCurrentUserProfile(userId);
      } else {
        // Fallback : GET /users/me avec le token fraîchement obtenu
        return await fetchCurrentUserViaMe();
      }
    } else {
      dev.log('[AuthController] login() failed message=${response.message}');
      _setError(response.message ?? 'Connexion échouée');
      _setLoading(false);
      return false;
    }
  }

  // Récupère le profil via /users/me (quand user_id absent du token response)
  Future<bool> fetchCurrentUserViaMe() async {
    final response = await _apiClient.get<UserModel>(
      endpoint: ApiEndpoints.me,
      parser: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );

    _setLoading(false);

    if (response.isSuccess && response.data != null) {
      _currentUser = response.data;
      notifyListeners();
      return true;
    } else {
      _setError(
        response.message ?? 'Impossible de récupérer le profil utilisateur',
      );
      logout();
      return false;
    }
  }

  // Register a new user
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? phoneNumber,
  }) async {
    _setLoading(true);
    _setError(null);

    final body = {
      'email': email,
      'password': password,
      'full_name': fullName,
      'is_client': role == UserRole.client,
      'is_freelancer': role == UserRole.freelancer,
      'is_admin': role == UserRole.admin,
      'phone_number': phoneNumber,
    };

    final response = await _apiClient.post<UserModel>(
      endpoint: ApiEndpoints.register,
      body: body,
      parser: (json) => UserModel.fromJson(json as Map<String, dynamic>),
      requiresAuth: false,
    );

    _setLoading(false);

    if (response.isSuccess) {
      return true;
    } else {
      _setError(response.message ?? 'Inscription échouée');
      return false;
    }
  }

  // Fetch the current user profile from `/users/{id}`
  Future<bool> fetchCurrentUserProfile(int userId) async {
    final response = await _apiClient.get<UserModel>(
      endpoint: ApiEndpoints.userById(userId),
      parser: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );

    _setLoading(false);

    if (response.isSuccess) {
      _currentUser = response.data;
      notifyListeners();
      return true;
    } else {
      _setError(
        response.message ?? 'Impossible de récupérer le profil utilisateur',
      );
      logout();
      return false;
    }
  }

  Future<bool> sendOtp(String email) async {
    _setLoading(true);
    _setError(null);
    dev.log('[AuthController] sendOtp() start email=$email');

    final response = await _apiClient.post<Map<String, dynamic>>(
      endpoint: ApiEndpoints.sendOtp,
      body: {'email': email},
      parser: (json) => json as Map<String, dynamic>,
      requiresAuth: false,
    );

    _setLoading(false);
    dev.log(
      '[AuthController] sendOtp() result success=${response.isSuccess} message=${response.message}',
    );

    if (response.isSuccess) {
      return true;
    } else {
      _setError(response.message ?? "Échec de l'envoi du code");
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String code) async {
    _setLoading(true);
    _setError(null);
    dev.log('[AuthController] verifyOtp() start email=$email code=$code');

    final response = await _apiClient.post<Map<String, dynamic>>(
      endpoint: ApiEndpoints.verifyOtp,
      body: {'email': email, 'code': code},
      parser: (json) => json as Map<String, dynamic>,
      requiresAuth: false,
    );

    _setLoading(false);
    dev.log(
      '[AuthController] verifyOtp() result success=${response.isSuccess} message=${response.message}',
    );

    if (response.isSuccess) {
      if (_currentUser != null) {
        dev.log(
          '[AuthController] verifyOtp() marking current user verified id=${_currentUser!.id}',
        );
        _currentUser = UserModel(
          id: _currentUser!.id,
          email: _currentUser!.email,
          fullName: _currentUser!.fullName,
          role: _currentUser!.role,
          phoneNumber: _currentUser!.phoneNumber,
          createdAt: _currentUser!.createdAt,
          isActive: _currentUser!.isActive,
          isClient: _currentUser!.isClient,
          isFreelancer: _currentUser!.isFreelancer,
          isAdmin: _currentUser!.isAdmin,
          isVerified: true,
        );
        notifyListeners();
        return true;
      }

      dev.log(
        '[AuthController] verifyOtp() currentUser is null after successful OTP, fetching profile via /users/me',
      );
      final recovered = await fetchCurrentUserViaMe();
      if (!recovered) {
        _setError(
          'Impossible de récupérer le profil utilisateur après vérification',
        );
        return false;
      }
      return true;
    } else {
      _setError(response.message ?? 'Code invalide ou expiré');
      return false;
    }
  }

  // Logout the user
  void logout() {
    _currentUser = null;
    ApiClient.clearToken();
    notifyListeners();
  }
}
