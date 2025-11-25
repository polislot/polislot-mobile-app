import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/info_board.dart';
import '../models/tier_model.dart';
import '../models/leaderboard_user.dart';
import '../models/reward_model.dart';
import '../models/user_reward_model.dart';
import '../models/feedback_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    //  PERBAIKAN: Support format 'status' dan 'success'
    bool isSuccess = false;
    
    // Cek apakah ada field 'status' dengan value 'success'
    if (json.containsKey('status') && json['status'] == 'success') {
      isSuccess = true;
    }
    // Atau cek apakah ada field 'success' dengan value true
    else if (json.containsKey('success') && json['success'] == true) {
      isSuccess = true;
    }
    
    return ApiResponse<T>(
      success: isSuccess,
      message: json['message'] ?? 'Unknown error',
      data: fromJsonT != null && json['data'] != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      errors: json['errors'] as Map<String, dynamic>?,
      statusCode: statusCode,
    );
  }

  bool get isSuccess => success && statusCode >= 200 && statusCode < 300;
  bool get isError => !isSuccess;

  // Helper untuk ambil pesan error lengkap
  String get fullErrorMessage {
    if (errors != null && errors!.isNotEmpty) {
      return errors!.values
          .expand((e) => e is List ? e : [e])
          .join('\n');
    }
    return message;
  }
}

class ApiService {
  static const String baseUrl = "http://192.168.137.1:8000/api";

  // 🟢 REGISTER
  static Future<ApiResponse> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    return _postRequest(
      endpoint: "/register",
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
      },
    );
  }

  // 🟣 VERIFY OTP (Register)
  static Future<ApiResponse> verifyOtp({
    required String email,
    required String otp,
  }) async {
    return _postRequest(
      endpoint: "/verify-register-otp",
      body: {'email': email, 'otp': otp},
    );
  }

  // 🟠 RESEND OTP
  static Future<ApiResponse> resendOtp({
    required String email,
  }) async {
    return _postRequest(
      endpoint: "/resend-register-otp",
      body: {'email': email},
    );
  }

  // 🔴 LOGIN
  static Future<ApiResponse> login({
    required String email,
    required String password,
  }) async {
    return _postRequest(
      endpoint: "/login",
      body: {'email': email, 'password': password},
    );
  }

  // 🟡 SEND RESET OTP (Lupa Password)
  static Future<ApiResponse> sendResetOtp({
    required String email,
  }) async {
    return _postRequest(
      endpoint: "/password/send-reset-otp",
      body: {'email': email},
    );
  }

  // 🟤 RESEND RESET OTP
  static Future<ApiResponse> resendResetOtp({
    required String email,
  }) async {
    return _postRequest(
      endpoint: "/password/resend-reset-otp",
      body: {'email': email},
    );
  }

  // 🟦 VERIFY RESET OTP
  static Future<ApiResponse> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    return _postRequest(
      endpoint: "/password/verify-reset-otp",
      body: {'email': email, 'otp': otp},
    );
  }

  // 🟣 RESET PASSWORD
  static Future<ApiResponse> resetPassword({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    return _postRequest(
      endpoint: "/password/reset",
      body: {
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
      },
    );
  }

  // 🔵 LOGOUT
  static Future<ApiResponse> logout(String accessToken) async {
    return _postRequest(
      endpoint: "/logout",
      headers: {'Authorization': 'Bearer $accessToken'},
      body: {},
    );
  }

  // -----------------------------------------------------------
  //  PROFILE METHODS
  // -----------------------------------------------------------

  // 🟢 GET PROFILE
  static Future<ApiResponse> getProfile(String accessToken) async {
    return _getRequest(
      endpoint: "/profile",
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }

  // -----------------------------------------------------------
  //  INFO BOARD METHODS
  // -----------------------------------------------------------

// 🟦 GET HOME / INFOBOARD
static Future<ApiResponse<InfoBoard>> getHome(String accessToken) async {
  return _getRequest<InfoBoard>(
    endpoint: "/info-board/latest",
    headers: {'Authorization': 'Bearer $accessToken'},
    fromJson: (data) => InfoBoard.fromJson(data),
  );
}


  // 🟡 UPDATE PROFILE (dengan atau tanpa avatar & password)
static Future<ApiResponse> updateProfile({
  required String accessToken,
  required String name,
  File? avatarFile,
  String? currentPassword,
  String? newPassword,
  String? confirmPassword,
}) async {
  return _multipartRequest(
    endpoint: "/profile",
    method: "POST", // ✅ Ubah dari PUT ke POST
    headers: {'Authorization': 'Bearer $accessToken'},
    fields: {
      '_method': 'PUT', // ✅ Tambahkan ini untuk Laravel method spoofing
      'name': name,
      if (currentPassword != null && currentPassword.isNotEmpty)
        'current_password': currentPassword,
      if (newPassword != null && newPassword.isNotEmpty)
        'new_password': newPassword,
      if (confirmPassword != null && confirmPassword.isNotEmpty)
        'new_password_confirmation': confirmPassword,
    },
    file: avatarFile != null ? {'avatar': avatarFile} : null,
  );
}

// -----------------------------------------------------------
//  USER TIER METHODS
// -----------------------------------------------------------

// 🟢 GET USER TIER
static Future<ApiResponse<UserTier>> getUserTier(String accessToken) async {
  return _getRequest<UserTier>(
    endpoint: "/user/tier",
    headers: {'Authorization': 'Bearer $accessToken'},
    fromJson: (data) => UserTier.fromJson(data),
  );
}

// 🟡 UPDATE USER TIER (cek & naikkan tier otomatis)
static Future<ApiResponse> updateUserTier(String accessToken) async {
  return _postRequest(
    endpoint: "/user/tier/update",
    headers: {'Authorization': 'Bearer $accessToken'},
    // Tidak pakai body → Laravel tetap menangkapnya
    body: {}, 
  );
}

// -----------------------------------------------------------
//  LEADERBOARD METHODS
// -----------------------------------------------------------

// 🟢 GET LEADERBOARD (urut lifetime_points)
static Future<ApiResponse<List<LeaderboardUser>>> getLeaderboard(
    String accessToken) async {
  return _getRequest<List<LeaderboardUser>>(
    endpoint: "/user/leaderboard",
    headers: {'Authorization': 'Bearer $accessToken'},
    fromJson: (data) => (data as List)
        .map((item) => LeaderboardUser.fromJson(item))
        .toList(),
  );
}

// -----------------------------------------------------------
//  REWARD METHODS
// -----------------------------------------------------------

// 🟢 GET REWARD CATALOG (katalog + poin user)
static Future<ApiResponse<RewardCatalogResponse>> getRewardCatalog(
    String accessToken) async {
  return _getRequest<RewardCatalogResponse>(
    endpoint: "/rewards",
    headers: {'Authorization': 'Bearer $accessToken'},
    fromJson: (data) => RewardCatalogResponse.fromJson(data),
  );
}

// 🟡 EXCHANGE REWARD (tukar poin dengan reward)
static Future<ApiResponse<ExchangeRewardResponse>> exchangeReward({
  required String accessToken,
  required int rewardId,
}) async {
  return _postRequest<ExchangeRewardResponse>(
    endpoint: "/rewards/exchange",
    headers: {'Authorization': 'Bearer $accessToken'},
    body: {'reward_id': rewardId},
    fromJson: (data) => ExchangeRewardResponse.fromJson(data),
  );
}

// 🟣 GET MY REWARDS (riwayat penukaran user)
static Future<ApiResponse<List<UserReward>>> getMyRewards(
    String accessToken) async {
  return _getRequest<List<UserReward>>(
    endpoint: "/rewards/my-rewards",
    headers: {'Authorization': 'Bearer $accessToken'},
    fromJson: (data) => (data as List)
        .map((item) => UserReward.fromJson(item))
        .toList(),
  );
}

// 🔵 CHECK VOUCHER (cek detail voucher berdasarkan kode)
static Future<ApiResponse> checkVoucher({
  required String accessToken,
  required String voucherCode,
}) async {
  return _postRequest(
    endpoint: "/rewards/check-voucher",
    headers: {'Authorization': 'Bearer $accessToken'},
    body: {'voucher_code': voucherCode},
  );
}

 
static Future<ApiResponse<T>> _postRequest<T>({
  required String endpoint,
  required Map<String, dynamic> body,
  Map<String, String>? headers,
  T Function(dynamic)? fromJson,
}) async {
  final defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    ...?headers,
  };

  try {
    final response = await http
        .post(
          Uri.parse("$baseUrl$endpoint"),
          headers: defaultHeaders,
          body: jsonEncode(body),
        )
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception('Connection timeout'),
        );

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

    return ApiResponse<T>.fromJson(
      responseBody,
      response.statusCode,
      fromJsonT: fromJson,
    );
  } catch (e) {
    print('API Error ($endpoint): $e');
    return ApiResponse<T>(
      success: false,
      message: _getErrorMessage(e),
      statusCode: 0,
    );
  }
}

// -----------------------------------------------------------
//  FEEDBACK METHODS
// -----------------------------------------------------------

// 🟢 SUBMIT FEEDBACK (kirim masukan/saran)
static Future<ApiResponse<FeedbackResponse>> submitFeedback({
  required String accessToken,
  required String category,
  required String feedbackType,
  required String title,
  String? description,
}) async {
  return _postRequest<FeedbackResponse>(
    endpoint: "/user/feedback",
    headers: {'Authorization': 'Bearer $accessToken'},
    body: {
      'category': category,
      'feedback_type': feedbackType,
      'title': title,
      if (description != null && description.isNotEmpty) 
        'description': description,
    },
    fromJson: (data) => FeedbackResponse.fromJson(data as Map<String, dynamic>),
  );
}

  // -----------------------------------------------------------
  // 🧩 REUSABLE GET REQUEST
  // -----------------------------------------------------------
  static Future<ApiResponse<T>> _getRequest<T>({
    required String endpoint,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    final defaultHeaders = {
      'Accept': 'application/json',
      ...?headers,
    };

    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl$endpoint"),
            headers: defaultHeaders,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Connection timeout'),
          );

      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

      return ApiResponse<T>.fromJson(
        responseBody,
        response.statusCode,
        fromJsonT: fromJson,
      );
    } catch (e) {
      print('API Error ($endpoint): $e');
      return ApiResponse<T>(
        success: false,
        message: _getErrorMessage(e),
        statusCode: 0,
      );
    }
  }

  // -----------------------------------------------------------
  // 🧩 REUSABLE MULTIPART REQUEST (untuk upload file)
  // -----------------------------------------------------------
  static Future<ApiResponse> _multipartRequest({
    required String endpoint,
    required String method, // POST, PUT, PATCH
    required Map<String, String> fields,
    Map<String, File>? file,
    Map<String, String>? headers,
  }) async {
    final defaultHeaders = {
      'Accept': 'application/json',
      ...?headers,
    };

    try {
      final request = http.MultipartRequest(
        method,
        Uri.parse("$baseUrl$endpoint"),
      );

      // Add headers
      request.headers.addAll(defaultHeaders);

      // Add text fields
      request.fields.addAll(fields);

      // Add file (jika ada)
      if (file != null) {
        for (var entry in file.entries) {
          final fileStream = http.ByteStream(entry.value.openRead());
          final fileLength = await entry.value.length();
          final multipartFile = http.MultipartFile(
            entry.key,
            fileStream,
            fileLength,
            filename: entry.value.path.split('/').last,
          );
          request.files.add(multipartFile);
        }
      }

      // Send request
      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Connection timeout'),
          );

      // Get response
      final response = await http.Response.fromStream(streamedResponse);
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

      return ApiResponse.fromJson(responseBody, response.statusCode);
    } catch (e) {
      print('API Error ($endpoint): $e');
      return ApiResponse(
        success: false,
        message: _getErrorMessage(e),
        statusCode: 0,
      );
    }
  }

  // -----------------------------------------------------------
// TOKEN STORAGE
// -----------------------------------------------------------
static Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("access_token");
}


  // -----------------------------------------------------------
  // 🧩 ERROR MESSAGE HELPER
  // -----------------------------------------------------------
  static String _getErrorMessage(dynamic error) {
    if (error.toString().contains('timeout')) {
      return 'Koneksi timeout. Periksa internet Anda.';
    } else if (error.toString().contains('SocketException')) {
      return 'Tidak dapat terhubung ke server.';
    } else if (error.toString().contains('FormatException')) {
      return 'Format response tidak valid.';
    }
    return 'Gagal terhubung ke server.';
  }
}