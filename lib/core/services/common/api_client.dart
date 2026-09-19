import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:freelance_front/core/routes/app_router.dart';
import 'package:freelance_front/core/constants/app_colors.dart';


import 'package:freelance_front/core/constants/api_endpoints.dart';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.activeBaseUrl,
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
          
          _showErrorPopup(e);
          
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


  static bool _isShowingError = false;

  static void _showErrorPopup(DioException e) {
    if (_isShowingError) return;
    
    final context = AppRouter.rootNavigatorKey.currentContext;
    if (context == null) return;
    
    _isShowingError = true;
    
    String errorMessage = "Une erreur de connexion est survenue.";
    if (e.response != null && e.response?.data != null) {
      final data = e.response?.data;
      if (data is Map && data.containsKey('detail')) {
        errorMessage = data['detail'].toString();
      }
    } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      errorMessage = "Le serveur ne répond pas. Vérifiez votre connexion internet.";
    } else if (e.type == DioExceptionType.connectionError) {
      errorMessage = "Impossible de se connecter au serveur.";
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.anthracite,
          title: Row(
            children: const [
              Icon(Icons.error_outline, color: AppColors.errorRed),
              SizedBox(width: 8),
              Text('Erreur', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Text(errorMessage, style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _isShowingError = false;
              },
              child: const Text('OK', style: TextStyle(color: AppColors.primaryGold)),
            ),
          ],
        );
      },
    ).then((_) {
      _isShowingError = false;
    });
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
