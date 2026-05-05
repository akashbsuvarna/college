import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../admin/teacher/models/teacher_model.dart';
import '../../admin/student/models/student_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TeacherService {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String phone, String dob) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/teacher/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'dob': dob}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        await _storage.write(key: 'teacher_token', value: data['token']);
        final teacher = TeacherModel.fromJson(data['teacher']);
        return {'success': true, 'teacher': teacher};
      }
      return {'success': false, 'message': data['message'] ?? 'Login failed'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'teacher_token');
  }

  Future<List<StudentModel>> fetchStudents() async {
    try {
      final token = await _storage.read(key: 'teacher_token');
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/teacher/students'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => StudentModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load students');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<dynamic>> fetchStudentAttendance(String studentId) async {
    try {
      final token = await _storage.read(key: 'teacher_token');
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/teacher/attendance/$studentId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to load attendance');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<dynamic>> fetchNotifications() async {
    try {
      final token = await _storage.read(key: 'teacher_token');
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/teacher/notifications'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to load notifications');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
