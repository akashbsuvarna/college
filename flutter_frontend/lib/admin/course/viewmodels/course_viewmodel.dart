import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';
import '../../core/app_constants.dart';
import '../../../services/auth_service.dart';

class CourseViewModel extends ChangeNotifier {
  final _authService = AuthService();

  List<Course> _allCourses = [];
  List<Course> _filteredCourses = [];

  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<Course> get courses => _filteredCourses;
  List<Course> get allCourses => _allCourses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  CourseViewModel() {
    loadCourses();
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> loadCourses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse(AppConstants.coursesEndpoint), headers: headers)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        _allCourses = data.map((e) => Course.fromJson(e)).toList();
      } else {
        _errorMessage = 'Failed: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Connection error';
    }

    _applyFilters();
    _isLoading = false;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredCourses = _allCourses.where((c) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return c.title.toLowerCase().contains(q) ||
          c.code.toLowerCase().contains(q) ||
          c.description.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> addCourse(Course course) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse(AppConstants.coursesEndpoint),
            headers: headers,
            body: jsonEncode(course.toJson()),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final created = Course.fromJson(jsonDecode(response.body));
        _allCourses.insert(0, created);
      } else {
        _errorMessage = 'Add failed: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Connection error';
    }
    _applyFilters();
    notifyListeners();
  }

  Future<void> updateCourse(Course course) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .put(
            Uri.parse('${AppConstants.coursesEndpoint}/${course.id}'),
            headers: headers,
            body: jsonEncode(course.toJson()),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final updated = Course.fromJson(jsonDecode(response.body));
        final index = _allCourses.indexWhere((c) => c.id == course.id);
        if (index != -1) _allCourses[index] = updated;
      } else {
        _errorMessage = 'Update failed';
      }
    } catch (e) {
      _errorMessage = 'Connection error';
    }
    _applyFilters();
    notifyListeners();
  }

  Future<void> deleteCourse(String id) async {
    try {
      final headers = await _getHeaders();
      await http
          .delete(
            Uri.parse('${AppConstants.coursesEndpoint}/$id'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 8));

      _allCourses.removeWhere((c) => c.id == id);
    } catch (e) {
      _errorMessage = 'Delete failed';
    }
    _applyFilters();
    notifyListeners();
  }

  Future<void> refresh() => loadCourses();
}
