import 'package:flutter/material.dart';
import '../models/student_portal_model.dart';
import '../services/student_service.dart';

class StudentPortalViewModel extends ChangeNotifier {
  final StudentService _service = StudentService();

  // Auth
  bool _isLoggedIn = false;
  String? _errorMessage;

  // Separate loading flags — prevents shared flag from triggering spurious rebuilds
  bool _profileLoading = false;
  bool _attendanceLoading = false;
  bool _notificationsLoading = false;
  bool _sessionLoading = false;

  // Data
  StudentPortalModel? _student;
  List<AttendanceRecord> _attendance = [];
  List<StudentNotification> _notifications = [];

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  // isSessionLoading: only true during initial session check (for AuthWrapper)
  bool get isSessionLoading => _sessionLoading;
  // isLoading: true if ANY operation is in progress
  bool get isLoading =>
      _sessionLoading || _profileLoading || _attendanceLoading || _notificationsLoading;
  bool get isAttendanceLoading => _attendanceLoading;
  bool get isProfileLoading => _profileLoading;
  bool get isNotificationsLoading => _notificationsLoading;
  String? get errorMessage => _errorMessage;
  StudentPortalModel? get student => _student;
  List<AttendanceRecord> get attendance => _attendance;
  List<StudentNotification> get notifications => _notifications;
  String? get studentId => _student?.id;

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<bool> login(String phone, String password) async {
    _profileLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _service.login(phone, password);

    if (result['success']) {
      _isLoggedIn = true;
      _student = StudentPortalModel.fromJson(result['student']);
    } else {
      _errorMessage = result['message'];
    }

    _profileLoading = false;
    notifyListeners();
    return result['success'];
  }

  // ── Check session ─────────────────────────────────────────────────────────
  Future<void> checkSession() async {
    final token = await _service.getToken();
    if (token == null) return;

    _sessionLoading = true;
    notifyListeners();

    final profileData = await _service.getProfile();
    if (profileData != null) {
      _student = StudentPortalModel.fromJson(profileData);
      _isLoggedIn = true;
    }

    _sessionLoading = false;
    notifyListeners();
  }

  // ── Load profile ──────────────────────────────────────────────────────────
  Future<void> loadProfile() async {
    if (_profileLoading) return; // guard: skip if already running
    _profileLoading = true;
    notifyListeners();

    final data = await _service.getProfile();
    if (data != null) {
      _student = StudentPortalModel.fromJson(data);
    } else {
      _errorMessage = 'Failed to load profile';
    }

    _profileLoading = false;
    notifyListeners();
  }

  // ── Load attendance ───────────────────────────────────────────────────────
  Future<void> loadAttendance() async {
    if (_attendanceLoading) return; // guard: skip if already running
    _attendanceLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _service.getAttendance();
      _attendance = data.map((e) => AttendanceRecord.fromJson(e)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _attendanceLoading = false;
    notifyListeners();
  }

  // ── Mark attendance (QR) ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> markAttendance(String qrToken) async {
    return await _service.markAttendance(qrToken);
  }

  // ── Load notifications ────────────────────────────────────────────────────
  Future<void> loadNotifications() async {
    if (_notificationsLoading) return; // guard: skip if already running
    _notificationsLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _service.getNotifications();
      _notifications =
          data.map((e) => StudentNotification.fromJson(e)).toList();
    } catch (e) {
      _errorMessage = 'Failed to load notifications';
    }

    _notificationsLoading = false;
    notifyListeners();
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _service.logout();
    _isLoggedIn = false;
    _student = null;
    _attendance = [];
    _notifications = [];
    notifyListeners();
  }
}
