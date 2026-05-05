import 'package:flutter/material.dart';
import '../../../services/attendance_notification_service.dart';
import '../models/attendance_notification_models.dart';

class AttendanceViewModel extends ChangeNotifier {
  final AttendanceService _service = AttendanceService();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _qrCodeUrl;
  String? get qrCodeUrl => _qrCodeUrl;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> generateAttendanceQR(String subjectId, String sessionId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _service.generateQR(subjectId, sessionId);
      if (res['success']) {
        _qrCodeUrl = res['qrCodeUrl'];
      } else {
        _errorMessage = res['message'];
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markStudentAttendance(String token, String studentId) async {
    try {
      final res = await _service.markAttendance(token, studentId);
      return res['success'] ?? false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> markByAdmin(String studentId, String subjectId, String sessionId) async {
    try {
      final res = await _service.markAttendanceByAdmin(studentId, subjectId, sessionId);
      if (res['success'] != true) {
        _errorMessage = res['message'] ?? 'Failed to mark attendance';
        notifyListeners();
      }
      return res['success'] ?? false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}

class NotificationViewModel extends ChangeNotifier {
  final NotificationService _service = NotificationService();
  
  List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => _notifications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  NotificationViewModel() {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _service.getNotifications();
      _notifications = data.map((e) => AppNotification.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error loading notifications: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> send(AppNotification notification) async {
    try {
      await _service.sendNotification(notification.toJson());
      await loadNotifications();
      return true;
    } catch (e) {
      return false;
    }
  }
}
