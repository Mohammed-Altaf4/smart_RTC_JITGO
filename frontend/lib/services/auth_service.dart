import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const String baseUrl = "http://192.168.68.103:8000";

  static Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl/register');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      print('Register Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "message": "User registered successfully"
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          "success": false,
          "message": data["detail"] ?? "Registration failed"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Connection error: $e"
      };
    }
  }

  static Future<String?> login(String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      print('Login Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["access_token"];
      } else {
        return null;
      }
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }
}
