import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard_stats_model.dart';
import '../../core/app_constants.dart';
import '../../../services/auth_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final _authService = AuthService();
  DashboardStats? _stats;
  bool _isLoading = false;
  String? _errorMessage;

  DashboardStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  DashboardViewModel() {
    loadStats();
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> loadStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final headers = await _getHeaders();

      // Fetch main dashboard stats
      final statsRes = await http
          .get(Uri.parse(AppConstants.dashboardStats), headers: headers)
          .timeout(const Duration(seconds: 60));

      // Fetch courses count
      final coursesRes = await http
          .get(Uri.parse(AppConstants.coursesEndpoint), headers: headers)
          .timeout(const Duration(seconds: 60));

      // Fetch subjects count
      final subjectsRes = await http
          .get(Uri.parse(AppConstants.subjectsEndpoint), headers: headers)
          .timeout(const Duration(seconds: 60));

      // Fetch pending students
      final pendingRes = await http
          .get(Uri.parse('${AppConstants.studentsEndpoint}?status=pending'), headers: headers)
          .timeout(const Duration(seconds: 60));

      // Fetch active students count
      final activeRes = await http
          .get(Uri.parse('${AppConstants.studentsEndpoint}?status=active'), headers: headers)
          .timeout(const Duration(seconds: 60));

      if (statsRes.statusCode == 200) {
        final json = jsonDecode(statsRes.body) as Map<String, dynamic>;

        // Augment with extra data
        int totalCourses = 0;
        int totalSubjects = 0;
        List<dynamic> pendingList = [];
        int activeCount = json['totalStudents'] ?? 0;

        if (coursesRes.statusCode == 200) {
          final courses = jsonDecode(coursesRes.body) as List;
          totalCourses = courses.length;
        }
        if (subjectsRes.statusCode == 200) {
          final subjects = jsonDecode(subjectsRes.body) as List;
          totalSubjects = subjects.length;
        }
        if (pendingRes.statusCode == 200) {
          pendingList = jsonDecode(pendingRes.body) as List;
        }
        if (activeRes.statusCode == 200) {
          final active = jsonDecode(activeRes.body) as List;
          activeCount = active.length;
        }

        json['totalCourses'] = totalCourses;
        json['totalSubjects'] = totalSubjects;
        json['pendingStudents'] = pendingList.length;
        json['activeStudents'] = activeCount;
        json['pendingRequests'] = pendingList.take(3).toList();

        // Build default recent activities if backend doesn't provide them
        if (json['recentActivities'] == null || (json['recentActivities'] as List).isEmpty) {
          json['recentActivities'] = _buildDefaultActivities(pendingList);
        }

        _stats = DashboardStats.fromJson(json);
      } else {
        _errorMessage = 'Stats load failed: ${statsRes.statusCode}';
        debugPrint('Stats Error: ${statsRes.body}');
      }
    } catch (e) {
      _errorMessage = 'Connection error. Check backend.';
      debugPrint('Stats Exception: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  List<Map<String, dynamic>> _buildDefaultActivities(List<dynamic> pending) {
    final activities = <Map<String, dynamic>>[];
    if (pending.isNotEmpty) {
      activities.add({
        'title': 'New student registration',
        'subtitle': '${pending.first['fullName'] ?? 'A student'} requested for admission',
        'time': '10 min ago',
        'type': 'student',
      });
    }
    activities.addAll([
      {'title': 'Attendance marked', 'subtitle': 'Attendance marked for today', 'time': '1 hour ago', 'type': 'attendance'},
      {'title': 'New course added', 'subtitle': 'A new course was added', 'time': '3 hours ago', 'type': 'course'},
      {'title': 'Teacher joined', 'subtitle': 'A new teacher joined the department', 'time': '5 hours ago', 'type': 'teacher'},
    ]);
    return activities;
  }

  Future<void> refresh() => loadStats();
}
