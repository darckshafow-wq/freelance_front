import 'dart:io';
import 'package:dio/dio.dart';
import 'package:freelance_front/core/constants/api_endpoints.dart';
import 'package:freelance_front/core/services/common/api_client.dart';

class UploadService {
  final Dio _dio = ApiClient.instance;

  /// Upload an image file and return its URL on the server.
  Future<String> uploadImage(File imageFile) async {
    final fileName = imageFile.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
    });

    final response = await _dio.post(
      ApiEndpoints.uploadImage,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur lors de l\'upload de l\'image');
    }

    // The backend returns {"url": "/uploads/xxx.jpg"}
    final url = response.data['url'] as String;

    // Build the full URL for display
    final baseUrl = ApiEndpoints.activeBaseUrl;
    final serverBase = baseUrl.replaceAll('/api/v1', '');
    return '$serverBase$url';
  }
}
