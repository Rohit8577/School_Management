import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Change this to your computer's IP if running on a physical device
  // For Android emulator use 10.0.2.2, for iOS simulator use localhost
  static const String baseUrl = 'http://localhost:3000/api';

  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static String? getToken() {
    return _token;
  }

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ==================== AUTH ====================

  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'identifier': identifier,
        'password': password,
        'role': role,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      _token = data['token'];
    }

    return {
      'success': response.statusCode == 200,
      'data': data,
      'statusCode': response.statusCode,
    };
  }

  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String role,
    String? roleId,
    String? department,
    String? phone,
    int? classId,
    String? rollNumber,
    String? parentName,
    String? parentPhone,
    String? dateOfBirth,
  }) async {
    final body = {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      if (roleId != null) 'roleId': roleId,
      if (department != null) 'department': department,
      if (phone != null) 'phone': phone,
      if (classId != null) 'classId': classId,
      if (rollNumber != null) 'rollNumber': rollNumber,
      if (parentName != null) 'parentName': parentName,
      if (parentPhone != null) 'parentPhone': parentPhone,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      _token = data['token'];
    }

    return {
      'success': response.statusCode == 201,
      'data': data,
      'statusCode': response.statusCode,
    };
  }

  // ==================== DASHBOARDS ====================

  static Future<Map<String, dynamic>> getDashboard(String role) async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/$role'),
      headers: _headers,
    );

    return {
      'success': response.statusCode == 200,
      'data': jsonDecode(response.body),
      'statusCode': response.statusCode,
    };
  }
}
