import 'package:flutter/foundation.dart';
import '../../admin/teacher/models/teacher_model.dart';
import '../../admin/student/models/student_model.dart';
import '../services/teacher_service.dart';

class TeacherPortalViewModel extends ChangeNotifier {
  final TeacherService _service = TeacherService();
  
  TeacherModel? _currentTeacher;
  TeacherModel? get currentTeacher => _currentTeacher;

  List<StudentModel> _students = [];
  List<StudentModel> get students => _students;
  
  List<StudentModel> _filteredStudents = [];
  List<StudentModel> get filteredStudents => _filteredStudents;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String phone, String dob) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _service.login(phone, dob);
    
    if (result['success'] == true) {
      _currentTeacher = result['teacher'];
      _setLoading(false);
      return true;
    } else {
      _errorMessage = result['message'];
      _setLoading(false);
      return false;
    }
  }

  void logout() {
    _service.logout();
    _currentTeacher = null;
    _students = [];
    _filteredStudents = [];
    notifyListeners();
  }

  Future<void> fetchStudents() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _students = await _service.fetchStudents();
      _filteredStudents = _students;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }
  
  void searchStudents(String query) {
    if (query.isEmpty) {
      _filteredStudents = _students;
    } else {
      final lowercaseQuery = query.toLowerCase();
      _filteredStudents = _students.where((s) {
        return s.fullName.toLowerCase().contains(lowercaseQuery) ||
               s.studentId.toLowerCase().contains(lowercaseQuery) ||
               s.academic.course.toLowerCase().contains(lowercaseQuery);
      }).toList();
    }
    notifyListeners();
  }

  List<dynamic> _notifications = [];
  List<dynamic> get notifications => _notifications;

  Future<List<dynamic>> fetchStudentAttendance(String studentId) async {
    try {
      return await _service.fetchStudentAttendance(studentId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<void> fetchNotifications() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _notifications = await _service.fetchNotifications();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
