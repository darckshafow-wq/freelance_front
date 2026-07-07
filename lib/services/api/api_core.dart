import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'api_response.dart';
import 'mock_data.dart';

class ApiClient {
  static String? _authToken;

  // Getter public pour permettre au routeur de vérifier l'authentification
  static String? get currentToken => _authToken;

  // Set the token globally after a successful login
  static void setToken(String token) {
    _authToken = token;
  }

  // Clear token on logout
  static void clearToken() {
    _authToken = null;
    MockData.logout(); // Reset mock session
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
    dev.log('API Response: [${response.request?.method}] ${response.request?.url} -> Status $statusCode');
    
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
      return ApiResponse.error('Erreur lors du décodage de la réponse: $e', statusCode: statusCode);
    }
  }

  ApiResponse<T> _handleError<T>(dynamic error) {
    dev.log('API Error: $error');
    String message = 'Une erreur réseau est survenue. Veuillez vérifier votre connexion.';
    return ApiResponse.error(message);
  }

  // Handle mock API responses in-memory
  Future<ApiResponse<T>> _handleMockRequest<T>({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    required T Function(dynamic json) parser,
  }) async {
    dev.log('API Mock Intercept [$method] to: $endpoint');
    dynamic mockResponse;
    
    if (endpoint.endsWith('/login/access-token')) {
      final email = body?['username'] as String? ?? '';
      final password = body?['password'] as String? ?? '';
      mockResponse = await MockData.login(email, password);
    } else if (endpoint.endsWith('/users/open')) {
      mockResponse = await MockData.register(body ?? {});
    } else if (endpoint.endsWith('/users/me')) {
      mockResponse = await MockData.getMe(_authToken);
    } else if (endpoint.endsWith('/tasks')) {
      if (method == 'GET') {
        mockResponse = await MockData.getTasks();
      } else if (method == 'POST') {
        mockResponse = await MockData.createTask(body ?? {});
      }
    } else if (endpoint.contains('/tasks/')) {
      final uriParts = endpoint.split('/');
      final id = int.tryParse(uriParts.last) ?? 0;
      if (method == 'PUT') {
        mockResponse = await MockData.updateTask(id, body ?? {});
      } else if (method == 'DELETE') {
        mockResponse = await MockData.deleteTask(id);
      }
    }

    if (mockResponse != null) {
      return mockResponse as ApiResponse<T>;
    }
    
    return ApiResponse.error('Endpoint mock non implémenté pour $method $endpoint');
  }

  // GET Request
  Future<ApiResponse<T>> get<T>({
    required String endpoint,
    required T Function(dynamic json) parser,
    bool requiresAuth = true,
  }) async {
    if (MockData.useMock) {
      return _handleMockRequest<T>(
        method: 'GET',
        endpoint: endpoint,
        parser: parser,
      );
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
    bool isFormUrlEncoded = false, // FastAPI /token login requires formUrlEncoded
  }) async {
    if (MockData.useMock) {
      return _handleMockRequest<T>(
        method: 'POST',
        endpoint: endpoint,
        body: body,
        parser: parser,
      );
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
    if (MockData.useMock) {
      return _handleMockRequest<T>(
        method: 'PUT',
        endpoint: endpoint,
        body: body,
        parser: parser,
      );
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
    if (MockData.useMock) {
      return _handleMockRequest<T>(
        method: 'DELETE',
        endpoint: endpoint,
        parser: parser,
      );
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
