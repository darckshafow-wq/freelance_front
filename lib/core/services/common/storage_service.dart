import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userRoleKey = 'user_role';

  static Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(key: accessTokenKey, value: token);
    } catch (e) {
      print('Erreur saveAccessToken: $e');
    }
  }

  static Future<String?> readAccessToken() async {
    try {
      return await _storage.read(key: accessTokenKey);
    } catch (e) {
      await clearTokens(); // Corrupted, clear it
      return null;
    }
  }

  static Future<void> saveUserRole(String role) async {
    await _storage.write(key: userRoleKey, value: role);
  }

  static Future<String?> readUserRole() async {
    return await _storage.read(key: userRoleKey);
  }

  static Future<void> clearTokens() async {
    try {
      await _storage.delete(key: accessTokenKey);
      await _storage.delete(key: refreshTokenKey);
      await _storage.delete(key: userRoleKey);
      await _storage.deleteAll();
    } catch (e) {
      print('Erreur lors de la suppression des tokens: $e');
    }
  }
}
