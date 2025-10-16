import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // URL ของ Backend
  // ใช้ 10.0.2.2 สำหรับ Android Emulator เพื่อเชื่อมต่อไปยัง localhost ของคอมพิวเตอร์
  static const String _baseUrl = 'http://10.0.2.2:3000/api/auth/';

  /// ฟังก์ชันสำหรับล็อกอิน
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('${_baseUrl}login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Failed to login: ${error['message']}');
      }
    } catch (e) {
      throw Exception('Could not connect to the server: $e');
    }
  }

  /// ฟังก์ชันสำหรับสมัครสมาชิก (รับแค่ username และ password)
  Future<Map<String, dynamic>> register(String username, String password) async {
    final url = Uri.parse('${_baseUrl}register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        // ส่งแค่ username และ password ตามที่แก้ไข
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Failed to register: ${error['message'] ?? response.body}');
      }
    } catch (e) {
      throw Exception('Could not connect to the server: $e');
    }
  }
}