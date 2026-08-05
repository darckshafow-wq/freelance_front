enum ApiStatus { loading, success, error }

class ApiResponse<T> {
  final ApiStatus status;
  final T? data;
  final String? message;
  final int? statusCode;

  ApiResponse({required this.status, this.data, this.message, this.statusCode});

  factory ApiResponse.loading() {
    return ApiResponse(status: ApiStatus.loading);
  }

  factory ApiResponse.success(T data, {String? message, int? statusCode}) {
    return ApiResponse(
      status: ApiStatus.success,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse(
      status: ApiStatus.error,
      message: message,
      statusCode: statusCode,
    );
  }

  bool get isLoading => status == ApiStatus.loading;
  bool get isSuccess => status == ApiStatus.success;
  bool get isError => status == ApiStatus.error;

  @override
  String toString() {
    return 'ApiResponse(status: $status, message: $message, data: $data, statusCode: $statusCode)';
  }
}
