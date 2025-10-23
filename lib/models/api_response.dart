// lib/models/api_response.dart
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;
  final int statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    required this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    int statusCode, {
    T Function(dynamic)? fromJsonT,
  }) {
    return ApiResponse<T>(
      success: json['status'] == 'success',
      message: json['message'] ?? '',
      data: fromJsonT != null && json['data'] != null 
          ? fromJsonT(json['data']) 
          : json['data'],
      errors: json['errors'],
      statusCode: statusCode,
    );
  }

  bool get isSuccess => success && statusCode >= 200 && statusCode < 300;
  bool get isError => !success || statusCode >= 400;
}