class Attendance {
  final String? id;
  final String studentId;
  final String subjectId;
  final String sessionId;
  final DateTime date;
  final String status;

  Attendance({
    this.id,
    required this.studentId,
    required this.subjectId,
    required this.sessionId,
    required this.date,
    required this.status,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['_id'],
      studentId: json['studentId'],
      subjectId: json['subjectId'],
      sessionId: json['sessionId'],
      date: DateTime.parse(json['date']).toLocal(),
      status: json['status'],
    );
  }
}

class AppNotification {
  final String? id;
  final String title;
  final String message;
  final String target;
  final DateTime? createdAt;

  AppNotification({
    this.id,
    required this.title,
    required this.message,
    required this.target,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['_id'],
      title: json['title'],
      message: json['message'],
      target: json['target'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']).toLocal() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'target': target,
    };
  }
}
