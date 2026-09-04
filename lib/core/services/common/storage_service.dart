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

  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: accessTokenKey, value: token);
  }

  static Future<String?> readAccessToken() async {
    return _storage.read(key: accessTokenKey);
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: accessTokenKey);
    await _storage.delete(key: refreshTokenKey);
  }
}
