import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ✅ TAMBAHKAN PORT 8000
  static const String baseUrl = "http://10.170.8.220:8000/api"; 

  // 🟢 REGISTER
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // Tambahkan ini
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': confirmPassword,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      return {
        'statusCode': response.statusCode,
        'body': jsonDecode(response.body)
      };
    } catch (e) {
      print('Register Error: $e');
      return {
        'statusCode': 0,
        'body': {'status': 'error', 'message': 'Gagal terhubung ke server: $e'}
      };
    }
  }

  // 🔴 LOGIN
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // Tambahkan ini
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      return {
        'statusCode': response.statusCode,
        'body': jsonDecode(response.body)
      };
    } catch (e) {
      print('Login Error: $e');
      return {
        'statusCode': 0,
        'body': {'status': 'error', 'message': 'Gagal terhubung ke server: $e'}
      };
    }
  }

  // 🟣 VERIFY OTP
  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/verify-register-otp"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      return {
        'statusCode': response.statusCode,
        'body': jsonDecode(response.body)
      };
    } catch (e) {
      print('Verify OTP Error: $e');
      return {
        'statusCode': 0,
        'body': {'status': 'error', 'message': 'Gagal terhubung ke server: $e'}
      };
    }
  }

  // 🟠 RESEND OTP
  static Future<Map<String, dynamic>> resendOtp({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/resend-register-otp"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      return {
        'statusCode': response.statusCode,
        'body': jsonDecode(response.body)
      };
    } catch (e) {
      print('Resend OTP Error: $e');
      return {
        'statusCode': 0,
        'body': {'status': 'error', 'message': 'Gagal terhubung ke server: $e'}
      };
    }
  }

  // 🔵 LOGOUT
  static Future<Map<String, dynamic>> logout(String accessToken) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/logout"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({}),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      return {
        'statusCode': response.statusCode,
        'body': jsonDecode(response.body)
      };
    } catch (e) {
      print('Logout Error: $e');
      return {
        'statusCode': 0,
        'body': {'status': 'error', 'message': 'Gagal terhubung ke server: $e'}
      };
    }
  }
}