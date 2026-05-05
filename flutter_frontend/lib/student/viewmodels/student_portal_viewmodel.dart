import 'package:flutter/material.dart';
import '../models/student_portal_model.dart';
import '../services/student_service.dart';

class StudentPortalViewModel extends ChangeNotifier {
  final StudentService _service = StudentService();

  // Auth
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Data
  StudentPortalModel? _student;
  List<AttendanceRecord> _attendance = [];
  List<StudentNotification> _notifications = [];

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  StudentPortalModel? get student => _student;
  List<AttendanceRecord> get attendance => _attendance;
  List<StudentNotification> get notifications => _notifications;
  String? get studentId => _student?.id;

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _service.login(phone, password);

    if (result['success']) {
      _isLoggedIn = true;
      _student = StudentPortalModel.fromJson(result['student']);
    } else {
      _errorMessage = result['message'];
    }

    _isLoading = false;
    notifyListeners();
    return result['success'];
  }

  // ── Check session ─────────────────────────────────────────────────────────
  Future<void> checkSession() async {
    final token = await _service.getToken();
    if (token == null) return;

    _isLoading = true;
    notifyListeners();

    final profileData = await _service.getProfile();
    if (profileData != null) {
      _student = StudentPortalModel.fromJson(profileData);
      _isLoggedIn = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Load profile ──────────────────────────────────────────────────────────
  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    final data = await _service.getProfile();
    if (data != null) {
      _student = StudentPortalModel.fromJson(data);
    } else {
      _errorMessage = 'Failed to load profile';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Load attendance ───────────────────────────────────────────────────────
  Future<void> loadAttendance() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _service.getAttendance();
      _attendance = data.map((e) => AttendanceRecord.fromJson(e)).toList();
    } catch (e) {
      _errorMessage = 'Failed to load attendance';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Mark attendance (QR) ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> markAttendance(String qrToken) async {
    return await _service.markAttendance(qrToken);
  }

  // ── Load notifications ────────────────────────────────────────────────────
  Future<void> loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _service.getNotifications();
      _notifications =
          data.map((e) => StudentNotification.fromJson(e)).toList();
    } catch (e) {
      _errorMessage = 'Failed to load notifications';
    }

    _isLoading = false;
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
