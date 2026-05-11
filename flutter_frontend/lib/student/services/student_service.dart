import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api_config.dart';

class StudentService {
  static final String _baseUrl = ApiConfig.baseUrl;

  // ── Auth ──────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/student/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'phone': phone, 'password': password}),
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);
      debugPrint('Student Login Status: ${response.statusCode}');
      debugPrint('Student Login Response: $data');
      if (response.statusCode == 200 && data['success'] == true) {
        await _saveToken(data['token']);
        await _saveStudentId(data['student']['_id'] ?? data['student']['id']);
        return {'success': true, 'student': data['student']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error'};
    }
  }

  Future<Map<String, dynamic>> registerStudent(Map<String, dynamic> studentData) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/student/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(studentData),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ── Profile ───────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getProfile() async {
    final response = await _authGet('/student/profile');
    if (response != null && response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // ── Attendance ────────────────────────────────────────────────────────────
  Future<List<dynamic>> getAttendance() async {
    final response = await _authGet('/student/attendance');
    if (response != null && response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  // ── Mark Attendance (QR scan) ─────────────────────────────────────────────
  Future<Map<String, dynamic>> markAttendance(String qrToken) async {
    try {
      final studentId = await getStudentId();
      if (studentId == null) {
        return {'success': false, 'message': 'Not logged in'};
      }

      final response = await http
          .post(
            Uri.parse('$_baseUrl/attendance/mark'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'token': qrToken, 'studentId': studentId}),
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to mark attendance'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error'};
    }
  }

  // ── Notifications ─────────────────────────────────────────────────────────
  Future<List<dynamic>> getNotifications() async {
    final response = await _authGet('/student/notifications');
    if (response != null && response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Future<http.Response?> _authGet(String path) async {
    try {
      final token = await getToken();
      if (token == null) return null;
      return await http
          .get(
            Uri.parse('$_baseUrl$path'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('student_jwt_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('student_jwt_token');
  }

  Future<void> _saveStudentId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('student_id', id);
  }

  Future<String?> getStudentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('student_id');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('student_jwt_token');
    await prefs.remove('student_id');
  }
}
