import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'api_response.dart';
import 'api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static String? _authToken;
  static bool mockMode = true; // Activer pour tester le design sans backend

  // Getter public pour permettre au routeur de vérifier l'authentification
  static String? get currentToken => _authToken;

  static Future<void> init() async {
    try {
      if (!mockMode) {
        await ApiEndpoints.resolveBackendHost();
      }
      _authToken = await getStoredToken();
      if (_authToken != null) {
        dev.log('[ApiClient] token restored from storage');
      }
    } catch (e) {
      dev.log('[ApiClient] imposible decharger le token stoker: $e');
    }
  }

  static Future<String?> getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      dev.log('errreur de lecture du token depuis la mémoire: $e');
      return null;
    }
  }

  static Future<void> setToken(String token) async {
    _authToken = token;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
    } catch (e) {
      dev.log('errreur de sauvegarde du token dasn la memoire: $e');
    }
  }

  static Future<void> clearToken() async {
    _authToken = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    } catch (e) {
      dev.log('errreur de supression du token dasn la memoire: $e');
    }
  }

  Map<String, String> _getHeaders({bool requiresAuth = true}) {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requiresAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic json) parser,
  ) {
    final int statusCode = response.statusCode;
    if (!mockMode) {
      dev.log(
        'API Response: [${response.request?.method}] ${response.request?.url} -> Status $statusCode',
      );
    }

    try {
      final decodedJson = jsonDecode(response.body);

      if (statusCode >= 200 && statusCode < 300) {
        final parsedData = parser(decodedJson);
        return ApiResponse.success(parsedData, statusCode: statusCode);
      } else {
        // Handle API level error messages (FastAPI standard: { "detail": "error message" })
        final String message = decodedJson['detail'] is String
            ? decodedJson['detail']
            : 'Une erreur est survenue (Statut $statusCode)';
        return ApiResponse.error(message, statusCode: statusCode);
      }
    } catch (e) {
      return ApiResponse.error(
        'Erreur lors du décodage de la réponse: $e',
        statusCode: statusCode,
      );
    }
  }

  ApiResponse<T> _handleError<T>(dynamic error) {
    dev.log('API Error: $error');
    String message =
        'Une erreur réseau est survenue. Veuillez vérifier votre connexion.';
    return ApiResponse.error(message);
  }

  // GET Request
  Future<ApiResponse<T>> get<T>({
    required String endpoint,
    required T Function(dynamic json) parser,
    bool requiresAuth = true,
  }) async {
    if (mockMode) {
      await Future.delayed(const Duration(milliseconds: 800));
      // Guessing based on common return types: List or Object
      final dynamic mockJson = endpoint.contains('list') || endpoint.endsWith('s') ? [] : <String, dynamic>{};
      return ApiResponse.success(parser(mockJson));
    }
    try {
      dev.log('API GET Request to: $endpoint');
      final response = await http.get(
        Uri.parse(endpoint),
        headers: _getHeaders(requiresAuth: requiresAuth),
      );
      return _handleResponse<T>(response, parser);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // POST Request
  Future<ApiResponse<T>> post<T>({
    required String endpoint,
    required Map<String, dynamic> body,
    required T Function(dynamic json) parser,
    bool requiresAuth = true,
    bool isFormUrlEncoded =
        false, // FastAPI /token login requires formUrlEncoded
  }) async {
    if (mockMode) {
      await Future.delayed(const Duration(milliseconds: 800));
      return ApiResponse.success(parser(<String, dynamic>{}));
    }
    try {
      dev.log('API POST Request to: $endpoint with body: $body');

      final headers = _getHeaders(requiresAuth: requiresAuth);
      dynamic requestBody;

      if (isFormUrlEncoded) {
        headers['Content-Type'] = 'application/x-www-form-urlencoded';
        requestBody = body.map((key, value) => MapEntry(key, value.toString()));
      } else {
        requestBody = jsonEncode(body);
      }

      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: requestBody,
      );
      return _handleResponse<T>(response, parser);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // PUT Request
  Future<ApiResponse<T>> put<T>({
    required String endpoint,
    required Map<String, dynamic> body,
    required T Function(dynamic json) parser,
    bool requiresAuth = true,
  }) async {
    if (mockMode) {
      await Future.delayed(const Duration(milliseconds: 800));
      return ApiResponse.success(parser(<String, dynamic>{}));
    }
    try {
      dev.log('API PUT Request to: $endpoint with body: $body');
      final response = await http.put(
        Uri.parse(endpoint),
        headers: _getHeaders(requiresAuth: requiresAuth),
        body: jsonEncode(body),
      );
      return _handleResponse<T>(response, parser);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // DELETE Request
  Future<ApiResponse<T>> delete<T>({
    required String endpoint,
    required T Function(dynamic json) parser,
    bool requiresAuth = true,
  }) async {
    if (mockMode) {
      await Future.delayed(const Duration(milliseconds: 800));
      return ApiResponse.success(parser(<String, dynamic>{}));
    }
    try {
      dev.log('API DELETE Request to: $endpoint');
      final response = await http.delete(
        Uri.parse(endpoint),
        headers: _getHeaders(requiresAuth: requiresAuth),
      );
      return _handleResponse<T>(response, parser);
    } catch (e) {
      return _handleError<T>(e);
    }
  }
}
