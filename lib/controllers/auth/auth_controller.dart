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

  Future<void> restoreSession() async {
    _setLoading(true);
    _setError(null);
    final storedToken = await ApiClient.getStoredToken();

    if (storedToken == null || storedToken.isEmpty) {
      _currentUser = null;
      _setLoading(false);
      return;
    }

    ApiClient.setToken(storedToken);

    if (ApiClient.mockMode) {
      _currentUser = UserModel(
        id: 1,
        email: 'client@mock.com',
        fullName: 'Client Test',
        role: UserRole.client,
        isClient: true,
      );
      _setLoading(false);
      return;
    }

    final response = await _apiClient.get<UserModel>(
      endpoint: ApiEndpoints.meProfile,
      parser: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );

    if (response.isSuccess && response.data != null) {
      final restoredUser = response.data!;
      if (restoredUser.id <= 0 || restoredUser.email.isEmpty) {
        await ApiClient.clearToken();
        _currentUser = null;
        _setError('Session invalide, veuillez vous reconnecter.');
      } else {
        _currentUser = restoredUser;
        notifyListeners();
      }
    } else {
      await ApiClient.clearToken();
      _currentUser = null;
      _setError('Session expirée, veuillez vous reconnecter.');
    }

    _setLoading(false);
  }

  // Login using FastAPI OAuth2 standard password flow (form URL encoded)
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      _currentUser = UserModel(
        id: 1,
        email: email,
        fullName: 'Client Mock',
        role: UserRole.client,
        isClient: true,
      );
      _setLoading(false);
      return true;
    }

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
      endpoint: ApiEndpoints.meProfile,
      parser: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );

    if (response.isSuccess && response.data != null) {
      final user = response.data!;
      if (user.id <= 0 || user.email.isEmpty) {
        _setError('Profil utilisateur invalide');
        logout();
        return false;
      }

      _currentUser = user;
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
    String? location,
  }) async {
    _setLoading(true);
    _setError(null);

    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(milliseconds: 1000));
      _currentUser = UserModel(
        id: 2,
        email: email,
        fullName: fullName,
        role: UserRole.client,
        isClient: true,
        isFreelancer: false,
      );
      _setLoading(false);
      return true;
    }

    final body = {
      'email': email,
      'password': password,
      'full_name': fullName,
      'is_client': role == UserRole.client,
      'is_freelancer': role == UserRole.freelancer,
      'is_admin': role == UserRole.admin,
      'phone_number': phoneNumber,
      'location': location,
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
      endpoint: ApiEndpoints.userProfileById(userId),
      parser: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );

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

    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(milliseconds: 800));
      _setLoading(false);
      return true;
    }

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

    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (_currentUser != null) {
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
      }
      _setLoading(false);
      return true;
    }

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
