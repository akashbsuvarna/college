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

  // Separate loading flags to avoid AuthWrapper loop
  bool _sessionLoading = false;
  bool _studentsLoading = false;
  bool _notificationsLoading = false;

  // isLoading: only session check for AuthWrapper — prevents loop when
  // fetchStudents/fetchNotifications are called from inside the portal.
  bool get isLoading => _sessionLoading;
  bool get isStudentsLoading => _studentsLoading;
  bool get isNotificationsLoading => _notificationsLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String phone, String dob) async {
    _sessionLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _service.login(phone, dob);

    if (result['success'] == true) {
      _currentTeacher = result['teacher'];
    } else {
      _errorMessage = result['message'];
    }

    _sessionLoading = false;
    notifyListeners();
    return result['success'] == true;
  }

  void logout() {
    _service.logout();
    _currentTeacher = null;
    _students = [];
    _filteredStudents = [];
    _notifications = [];
    notifyListeners();
  }

  Future<void> fetchStudents() async {
    if (_studentsLoading) return; // guard: skip if already running
    _studentsLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _students = await _service.fetchStudents();
      _filteredStudents = _students;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _studentsLoading = false;
    notifyListeners();
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
    if (_notificationsLoading) return; // guard: skip if already running
    _notificationsLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await _service.fetchNotifications();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _notificationsLoading = false;
    notifyListeners();
  }
}
