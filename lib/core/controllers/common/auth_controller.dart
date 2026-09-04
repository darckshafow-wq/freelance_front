import 'package:flutter/material.dart';

import 'package:freelance_front/core/models/common/user_model.dart';
import 'package:freelance_front/core/services/common/auth_service.dart';
import 'package:freelance_front/core/services/common/storage_service.dart';
import 'package:freelance_front/core/services/common/api_client.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;
  UserModel? currentUser;

  Future<bool> login({required String email, required String password}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      debugPrint('➡️ [AuthController] Lancement de _authService.login');
      final data = await _authService.login(email: email, password: password);

      final token = data['access_token'];
      if (token is String && token.isNotEmpty) {
        debugPrint('✅ [AuthController] Sauvegarde du token JWT');
        await StorageService.saveAccessToken(token);
        ApiClient.setToken(token);
      } else {
        debugPrint('⚠️ [AuthController] Aucun token JWT trouvé dans la réponse');
      }

      if (data['user'] != null) {
        debugPrint('👤 [AuthController] Parsing de l\'utilisateur depuis le payload login');
        currentUser = UserModel.fromJson(Map<String, dynamic>.from(data['user']));
      } else {
        debugPrint('👤 [AuthController] Fetching getCurrentUser() en fallback');
        currentUser = await _authService.getCurrentUser();
      }
      
      debugPrint('✅ [AuthController] Utilisateur connecté : \${currentUser?.email} (Role: \${currentUser?.role})');

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ [AuthController] Erreur globale lors du login: $e');
      isLoading = false;
      errorMessage = 'Email ou mot de passe invalide.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.register(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
      );
      
      // Après l'inscription, on peut soit connecter automatiquement, soit renvoyer false pour forcer le login manuel.
      // Appelons login pour connecter automatiquement
      final loginSuccess = await login(email: email, password: password);
      return loginSuccess;
    } catch (e) {
      isLoading = false;
      errorMessage = 'Erreur lors de l\'inscription. Vérifiez vos données.';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await StorageService.clearTokens();
    ApiClient.clearToken();
    currentUser = null;
    notifyListeners();
  }
}
