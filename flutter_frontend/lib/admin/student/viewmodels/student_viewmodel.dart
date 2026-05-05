import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student_model.dart';
import '../../core/app_constants.dart';
import '../../../services/auth_service.dart';

class StudentViewModel extends ChangeNotifier {
  final _authService = AuthService();

  List<StudentModel> _allStudents = [];
  List<StudentModel> _filteredStudents = [];

  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  String? _selectedCourse;
  int? _selectedSemester;

  // Getters
  List<StudentModel> get students => _filteredStudents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedCourse => _selectedCourse;
  int? get selectedSemester => _selectedSemester;

  // 🔹 Dynamic Course List (from academic.course)
  List<String> get courses {
    final c = _allStudents.map((s) => s.academic.course).toSet().toList();
    c.sort();
    return c;
  }

  // 🔹 Dynamic Semester List
  List<int> get semesters {
    final s = _allStudents.map((e) => e.academic.semester).toSet().toList();
    s.sort();
    return s;
  }

  // Constructor
  StudentViewModel() {
    loadStudents();
  }

  // 🔐 Headers with JWT
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  List<StudentModel> _pendingStudents = [];
  List<StudentModel> get pendingStudents => _pendingStudents;

  // 🌐 Load Students
  Future<void> loadStudents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final headers = await _getHeaders();
      // Load active
      final responseActive = await http
          .get(Uri.parse('${AppConstants.studentsEndpoint}?status=active'), headers: headers)
          .timeout(const Duration(seconds: 8));

      // Load pending
      final responsePending = await http
          .get(Uri.parse('${AppConstants.studentsEndpoint}?status=pending'), headers: headers)
          .timeout(const Duration(seconds: 8));

      if (responseActive.statusCode == 200) {
        final List data = jsonDecode(responseActive.body);
        _allStudents = data.map((e) => StudentModel.fromJson(e)).toList();
      } else {
        _errorMessage = 'Failed to load active: ${responseActive.statusCode}';
      }

      if (responsePending.statusCode == 200) {
        final List data = jsonDecode(responsePending.body);
        _pendingStudents = data.map((e) => StudentModel.fromJson(e)).toList();
      } else {
        _errorMessage = 'Failed to load pending: ${responsePending.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Connection error';
    }

    _applyFilters();
    _isLoading = false;
    notifyListeners();
  }

  // 🔍 Search
  void setSearch(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // 🎯 Filter by Course
  void setCourse(String? course) {
    _selectedCourse = course;
    _applyFilters();
    notifyListeners();
  }

  // 🎯 Filter by Semester
  void setSemester(int? semester) {
    _selectedSemester = semester;
    _applyFilters();
    notifyListeners();
  }

  // ⚙️ Apply Filters
  void _applyFilters() {
    _filteredStudents = _allStudents.where((s) {
      final matchSearch = _searchQuery.isEmpty ||
          s.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.phone.contains(_searchQuery);

      final matchCourse = _selectedCourse == null ||
          s.academic.course == _selectedCourse;

      final matchSemester = _selectedSemester == null ||
          s.academic.semester == _selectedSemester;

      return matchSearch && matchCourse && matchSemester;
    }).toList();
  }

  // ➕ Add Student
  Future<bool> addStudent(StudentModel student) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse(AppConstants.studentsEndpoint),
            headers: headers,
            body: jsonEncode(student.toJson()),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final created =
            StudentModel.fromJson(jsonDecode(response.body));
        _allStudents.insert(0, created);
        _applyFilters();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _errorMessage = data['message'] ?? 'Failed to add student';
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ✏️ Update Student
  Future<bool> updateStudent(StudentModel student) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final headers = await _getHeaders();
      final response = await http
          .put(
            Uri.parse('${AppConstants.studentsEndpoint}/${student.id}'),
            headers: headers,
            body: jsonEncode(student.toJson()),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final updated =
            StudentModel.fromJson(jsonDecode(response.body));

        final index =
            _allStudents.indexWhere((s) => s.id == student.id);

        if (index != -1) _allStudents[index] = updated;
        _applyFilters();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _errorMessage = data['message'] ?? 'Update failed';
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ❌ Delete Student
  Future<bool> deleteStudent(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final headers = await _getHeaders();
      final response = await http
          .delete(
            Uri.parse('${AppConstants.studentsEndpoint}/$id'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        _allStudents.removeWhere((s) => s.id == id);
        _applyFilters();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _errorMessage = data['message'] ?? 'Delete failed';
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ✅ Accept Student
  Future<bool> acceptStudent(String id, String course, int semester) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final headers = await _getHeaders();
      final response = await http
          .put(
            Uri.parse('${AppConstants.studentsEndpoint}/$id/accept'),
            headers: headers,
            body: jsonEncode({
              'course': course,
              'semester': semester,
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final accepted = StudentModel.fromJson(jsonDecode(response.body));
        _pendingStudents.removeWhere((s) => s.id == id);
        _allStudents.insert(0, accepted);
        _applyFilters();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _errorMessage = data['message'] ?? 'Accept failed';
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ❌ Reject Student
  Future<bool> rejectStudent(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final headers = await _getHeaders();
      final response = await http
          .put(
            Uri.parse('${AppConstants.studentsEndpoint}/$id/reject'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        _pendingStudents.removeWhere((s) => s.id == id);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _errorMessage = data['message'] ?? 'Reject failed';
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // 🔄 Refresh
  Future<void> refresh() => loadStudents();
}