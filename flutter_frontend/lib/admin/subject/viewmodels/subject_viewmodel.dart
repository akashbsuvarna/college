import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/subject_model.dart';
import '../../core/app_constants.dart';
import '../../../services/auth_service.dart';

class SubjectViewModel extends ChangeNotifier {
  final _authService = AuthService();

  List<Subject> _allSubjects = [];
  List<Subject> _filteredSubjects = [];

  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedCourseId;

  List<Subject> get subjects => _filteredSubjects;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedCourseId => _selectedCourseId;

  SubjectViewModel() {
    loadSubjects();
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> loadSubjects({String? courseId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final headers = await _getHeaders();
      final path = courseId != null
          ? '${AppConstants.subjectsEndpoint}?courseId=$courseId'
          : AppConstants.subjectsEndpoint;
      final response = await http
          .get(Uri.parse(path), headers: headers)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        _allSubjects = data.map((e) => Subject.fromJson(e)).toList();
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

  void setFilterCourse(String? courseId) {
    _selectedCourseId = courseId;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredSubjects = _allSubjects.where((s) {
      final matchSearch = _searchQuery.isEmpty ||
          s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.code.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchCourse =
          _selectedCourseId == null || s.courseId == _selectedCourseId;
      return matchSearch && matchCourse;
    }).toList();
  }

  Future<void> addSubject(Subject subject) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse(AppConstants.subjectsEndpoint),
            headers: headers,
            body: jsonEncode(subject.toJson()),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final created = Subject.fromJson(jsonDecode(response.body));
        _allSubjects.insert(0, created);
      } else {
        _errorMessage = 'Add failed: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Connection error';
    }
    _applyFilters();
    notifyListeners();
  }

  Future<void> updateSubject(Subject subject) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .put(
            Uri.parse('${AppConstants.subjectsEndpoint}/${subject.id}'),
            headers: headers,
            body: jsonEncode(subject.toJson()),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final updated = Subject.fromJson(jsonDecode(response.body));
        final index = _allSubjects.indexWhere((s) => s.id == subject.id);
        if (index != -1) _allSubjects[index] = updated;
      } else {
        _errorMessage = 'Update failed';
      }
    } catch (e) {
      _errorMessage = 'Connection error';
    }
    _applyFilters();
    notifyListeners();
  }

  Future<void> deleteSubject(String id) async {
    try {
      final headers = await _getHeaders();
      await http
          .delete(
            Uri.parse('${AppConstants.subjectsEndpoint}/$id'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 8));

      _allSubjects.removeWhere((s) => s.id == id);
    } catch (e) {
      _errorMessage = 'Delete failed';
    }
    _applyFilters();
    notifyListeners();
  }

  Future<void> refresh() => loadSubjects();
}
