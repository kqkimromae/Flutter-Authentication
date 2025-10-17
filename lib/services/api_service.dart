// lib/services/api_service.dart

import 'dart:convert';
import 'dart:io'; // ใช้สำหรับดักจับ SocketException (ไม่มีเน็ต, เชื่อมต่อไม่ได้)
import 'dart:async'; // ใช้สำหรับดักจับ TimeoutException (เซิร์ฟเวอร์ไม่ตอบสนอง)
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // **** ตรวจสอบ IP Address ตรงนี้ให้ถูกต้อง ****
  // Android Emulator: 'http://10.0.2.2:3000/api'
  // อุปกรณ์จริง/iOS: 'http://<YOUR_COMPUTER_IP>:3000/api'
  static const String _baseUrl = 'http://10.0.2.2:3000/api';

  // ===============================================
  // AUTHENTICATION FUNCTIONS (ปรับปรุงเล็กน้อย)
  // ===============================================

  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception(responseBody['message'] ?? 'Failed to login');
      }
    } on TimeoutException {
      throw Exception('Connection timed out. Please try again.');
    } on SocketException {
      throw Exception('Connection failed. Please check your IP and that the server is running.');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }
  
  Future<Map<String, dynamic>> register(String username, String password) async {
    final url = Uri.parse('$_baseUrl/auth/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return responseBody;
      } else {
        throw Exception(responseBody['message'] ?? 'Failed to register');
      }
    } on TimeoutException {
      throw Exception('Connection timed out. Please try again.');
    } on SocketException {
      throw Exception('Connection failed. Please check your IP and that the server is running.');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  // ===============================================
  // HELPER FUNCTION (เหมือนเดิม)
  // ===============================================

  Future<Map<String, String>> _getAuthenticatedHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) {
      throw Exception('Authentication token not found. Please log in again.');
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  // ===============================================
  // PRODUCT CRUD FUNCTIONS (**** ปรับปรุงใหม่ทั้งหมด ****)
  // ===============================================

  Future<List<dynamic>> getProducts() async {
    final url = Uri.parse('$_baseUrl/products');
    try {
      final headers = await _getAuthenticatedHeaders();
      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load products. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Connection timed out.');
    } on SocketException {
      throw Exception('Connection failed. Could not fetch products.');
    } catch (e) {
      throw Exception('Error fetching products: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<Map<String, dynamic>> addProduct(Map<String, dynamic> productData) async {
    final url = Uri.parse('$_baseUrl/products');
    try {
      final headers = await _getAuthenticatedHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(productData),
      ).timeout(const Duration(seconds: 10));
      
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return responseBody;
      } else {
        throw Exception(responseBody['message'] ?? 'Failed to add product');
      }
    } on TimeoutException {
      throw Exception('Connection timed out. Could not save product.');
    } on SocketException {
      throw Exception('Connection failed. Please check your IP and that the server is running.');
    } catch (e) {
      throw Exception('Error adding product: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<Map<String, dynamic>> updateProduct(int id, Map<String, dynamic> productData) async {
    final url = Uri.parse('$_baseUrl/products/$id');
    try {
      final headers = await _getAuthenticatedHeaders();
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(productData),
      ).timeout(const Duration(seconds: 10));

      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception(responseBody['message'] ?? 'Failed to update product. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Connection timed out. Could not update product.');
    } on SocketException {
      throw Exception('Connection failed. Could not update product.');
    } catch (e) {
      throw Exception('Error updating product: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<void> deleteProduct(int id) async {
    final url = Uri.parse('$_baseUrl/products/$id');
    try {
      final headers = await _getAuthenticatedHeaders();
      final response = await http.delete(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete product. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Connection timed out. Could not delete product.');
    } on SocketException {
      throw Exception('Connection failed. Could not delete product.');
    } catch (e) {
      throw Exception('Error deleting product: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }
}