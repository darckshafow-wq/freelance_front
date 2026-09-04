import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:freelance_front/core/constants/api_endpoints.dart';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (kDebugMode) {
            debugPrint('[API] ${options.method} ${options.uri}');
            if (options.data != null) {
              debugPrint('[API] request body: ${_sanitize(options.data)}');
            }
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint('[API] ${response.statusCode} ${response.requestOptions.uri}');
            debugPrint('[API] response body: ${_sanitize(response.data)}');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            debugPrint('[API] ERROR ${e.requestOptions.method} ${e.requestOptions.uri}');
            debugPrint('[API] status: ${e.response?.statusCode ?? 'network'}');
            debugPrint('[API] message: ${e.message}');
            if (e.response?.data != null) {
              debugPrint('[API] error body: ${_sanitize(e.response!.data)}');
            }
          }
          if (e.response?.statusCode == 401) {
            clearToken();
          }
          return handler.next(e);
        },
      ),
    );

  static Dio get instance => _dio;

  static void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static void clearToken() {
    _dio.options.headers.remove('Authorization');
  }

  static Object? _sanitize(Object? value) {
    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(
          key,
          _isSensitiveKey(key.toString()) ? '***' : _sanitize(item),
        ),
      );
    }
    if (value is Iterable) {
      return value.map(_sanitize).toList();
    }
    return value;
  }

  static bool _isSensitiveKey(String key) {
    final normalized = key.toLowerCase();
    return normalized.contains('password') ||
        normalized.contains('token') ||
        normalized == 'authorization';
  }
}
