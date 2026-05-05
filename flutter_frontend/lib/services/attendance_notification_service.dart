import 'dart:convert';
import 'base_api_service.dart';

class AttendanceService extends BaseApiService {
  Future<Map<String, dynamic>> generateQR(String subjectId, String sessionId) async {
    final response = await post("/attendance/generate", {
      "subjectId": subjectId,
      "sessionId": sessionId,
    });
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> markAttendance(String token, String studentId) async {
    final response = await post("/attendance/mark", {
      "token": token,
      "studentId": studentId,
    });
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> markAttendanceByAdmin(String studentId, String subjectId, String sessionId) async {
    final response = await post("/attendance/mark-admin", {
      "studentId": studentId,
      "subjectId": subjectId,
      "sessionId": sessionId,
    });
    return jsonDecode(response.body);
  }
}

class NotificationService extends BaseApiService {
  Future<List<dynamic>> getNotifications() async {
    final response = await get("/notifications");
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  Future<dynamic> sendNotification(Map<String, dynamic> data) async {
    final response = await post("/notifications", data);
    return jsonDecode(response.body);
  }
}
