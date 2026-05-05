import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/teacher_model.dart';
import '../../core/app_constants.dart';
import '../../../services/auth_service.dart';

enum TeacherFilter { all, active, onLeave, inactive }

class TeacherViewModel extends ChangeNotifier {
  final _authService = AuthService();
  List<TeacherModel> _allTeachers = [];
  List<TeacherModel> _filteredTeachers = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  TeacherFilter _filter = TeacherFilter.all;
  String? _selectedDepartment;

  List<TeacherModel> get teachers => _filteredTeachers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  TeacherFilter get filter => _filter;
  String? get selectedDepartment => _selectedDepartment;

  List<String> get departments {
    final depts = _allTeachers.map((t) => t.department).toSet().toList();
    depts.sort();
    return depts;
  }

  int get activeCount =>
      _allTeachers.where((t) => t.status == 'active').length;
  int get onLeaveCount =>
      _allTeachers.where((t) => t.status == 'on_leave').length;
  int get inactiveCount =>
      _allTeachers.where((t) => t.status == 'inactive').length;

  TeacherViewModel() {
    loadTeachers();
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> loadTeachers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse(AppConstants.teachersEndpoint), headers: headers)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        _allTeachers = data.map((e) => TeacherModel.fromJson(e)).toList();
      } else {
        _errorMessage = 'Failed to load: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Connection error. Check backend.';
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

  void setFilter(TeacherFilter f) {
    _filter = f;
    _applyFilters();
    notifyListeners();
  }

  void setDepartment(String? dept) {
    _selectedDepartment = dept;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredTeachers = _allTeachers.where((t) {
      final matchSearch = _searchQuery.isEmpty ||
          t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.employeeId.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchFilter = switch (_filter) {
        TeacherFilter.all => true,
        TeacherFilter.active => t.status == 'active',
        TeacherFilter.onLeave => t.status == 'on_leave',
        TeacherFilter.inactive => t.status == 'inactive',
      };

      final matchDept =
          _selectedDepartment == null || t.department == _selectedDepartment;

      return matchSearch && matchFilter && matchDept;
    }).toList();
  }

  Future<void> addTeacher(TeacherModel teacher) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse(AppConstants.teachersEndpoint),
            headers: headers,
            body: jsonEncode(teacher.toJson()),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final created = TeacherModel.fromJson(jsonDecode(response.body));
        _allTeachers.insert(0, created);
      } else {
        _errorMessage = 'Add failed: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Add failed. Check connection.';
    }
    _applyFilters();
    notifyListeners();
  }

  Future<void> updateTeacher(TeacherModel teacher) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .put(
            Uri.parse('${AppConstants.teachersEndpoint}/${teacher.id}'),
            headers: headers,
            body: jsonEncode(teacher.toJson()),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final updated = TeacherModel.fromJson(jsonDecode(response.body));
        final index = _allTeachers.indexWhere((t) => t.id == teacher.id);
        if (index != -1) _allTeachers[index] = updated;
      } else {
        _errorMessage = 'Update failed: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Update failed. Check connection.';
    }
    _applyFilters();
    notifyListeners();
  }

  Future<void> deleteTeacher(String id) async {
    try {
      final headers = await _getHeaders();
      await http
          .delete(Uri.parse('${AppConstants.teachersEndpoint}/$id'), headers: headers)
          .timeout(const Duration(seconds: 8));
      _allTeachers.removeWhere((t) => t.id == id);
    } catch (e) {
      _errorMessage = 'Delete failed. Check connection.';
    }
    _applyFilters();
    notifyListeners();
  }

  Future<void> refresh() => loadTeachers();
}
