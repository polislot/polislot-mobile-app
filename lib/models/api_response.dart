// lib/models/api_response.dart (PERBAIKAN)

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
    final bool isSuccess = json['status'] == 'success' || json['success'] == true;
    
    // Perbaikan utama di sini:
    T? parsedData;
    if (json['data'] != null) {
      if (fromJsonT != null) {
        // Jika ada parser custom (misal: InfoBoard.fromJson)
        parsedData = fromJsonT(json['data']);
      } else {
        // Jika tidak ada parser custom, coba cast langsung.
        // Ini bekerja jika T adalah String, int, bool, atau dynamic.
        try {
          parsedData = json['data'] as T?;
        } catch (e) {
          // Jika gagal, set null atau biarkan kosong, tergantung kebutuhan error handling.
          // Untuk kasus ini, biarkan null jika gagal cast tipe kompleks tanpa parser.
        }
      }
    }

    return ApiResponse<T>(
      success: isSuccess,
      message: json['message'] ?? 'Unknown error',
      data: parsedData, // Menggunakan data yang sudah diparsing/dikonversi
      errors: json['errors'] as Map<String, dynamic>?,
      statusCode: statusCode,
    );
  }

  bool get isSuccess => success && statusCode >= 200 && statusCode < 300;
  bool get isError => !success || statusCode >= 400;
}