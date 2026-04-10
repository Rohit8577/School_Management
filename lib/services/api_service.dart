import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Dhyan de: Agar tu Android Emulator use kar raha hai, toh localhost ki jagah 10.0.2.2 use hota hai.
  // Agar real phone pe hai, toh apne laptop ka IP address daalna padega (e.g., 192.168.1.X)
  static const String baseUrl = 'http://localhost:3000/api'; 
  
  static String _token = '';

  static void setToken(String token) {
    _token = token;
  }
  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
    required String role,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/auth/login'); // Tera Node.js endpoint
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identifier': identifier,
          'password': password,
          'role': role,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {

        // print(responseData['message']);
        // Token save karna class variable mei
        if (responseData['token'] != null) {
          setToken(responseData['token']);
        }
        
        return {
          'success': true,
          'data': {
            'user': responseData['user'],
            'token': responseData['token'] // Token bhi return le liya
          }
        };
      } else {
        return {
          'success': false, 
          'data': {'message': responseData['message'] ?? 'Login failed bro 💀'}
        };
      }
    } catch (e) {
      print("API Error: $e");
      return {
        'success': false, 
        'data': {'message': 'Server down hai ya network issue hai 😭'}
      };
    }
  }

  static Future<Map<String, dynamic>> getDashboard(String role) async {
    try {
      final url = Uri.parse('$baseUrl/dashboard/$role');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false, 
          'data': {'message': responseData['message'] ?? 'Failed to load dashboard'}
        };
      }
    } catch (e) {
      print("API Error: $e");
      return {
        'success': false, 
        'data': {'message': 'Dashboard fetch failed'}
      };
    }
  }
}