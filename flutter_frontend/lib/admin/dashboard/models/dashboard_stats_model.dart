class DashboardStats {
  final int totalTeachers;
  final int totalStudents;
  final int totalCourses;
  final int totalSubjects;
  final int activeTeachers;
  final int activeStudents;
  final int pendingStudents;
  final int inactiveStudents;
  final double attendanceRate;
  final int presentCount;
  final int absentCount;
  final List<RecentActivity> recentActivities;
  final List<WeeklyAttendance> weeklyAttendance;
  final List<PendingRequest> pendingRequests;

  DashboardStats({
    required this.totalTeachers,
    required this.totalStudents,
    required this.totalCourses,
    required this.totalSubjects,
    required this.activeTeachers,
    required this.activeStudents,
    required this.pendingStudents,
    required this.inactiveStudents,
    required this.attendanceRate,
    required this.presentCount,
    required this.absentCount,
    required this.recentActivities,
    required this.weeklyAttendance,
    required this.pendingRequests,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final totalStudents = json['totalStudents'] ?? 0;
    final activeStudents = json['activeStudents'] ?? totalStudents;
    final pendingStudents = json['pendingStudents'] ?? 0;
    final inactiveStudents = json['inactiveStudents'] ?? 0;
    final attendanceRate = (json['attendanceRate'] ?? 82.0).toDouble();

    // Build weekly attendance – use backend data if provided, else mock
    List<WeeklyAttendance> weekly;
    if (json['weeklyAttendance'] != null) {
      weekly = (json['weeklyAttendance'] as List)
          .map((e) => WeeklyAttendance.fromJson(e))
          .toList();
    } else {
      weekly = _mockWeekly();
    }

    return DashboardStats(
      totalTeachers: json['totalTeachers'] ?? 0,
      totalStudents: totalStudents,
      totalCourses: json['totalCourses'] ?? 0,
      totalSubjects: json['totalSubjects'] ?? 0,
      activeTeachers: json['activeTeachers'] ?? json['totalTeachers'] ?? 0,
      activeStudents: activeStudents,
      pendingStudents: pendingStudents,
      inactiveStudents: inactiveStudents,
      attendanceRate: attendanceRate,
      presentCount: json['presentCount'] ?? (activeStudents * attendanceRate ~/ 100),
      absentCount: json['absentCount'] ?? (activeStudents - (activeStudents * attendanceRate ~/ 100)),
      recentActivities: (json['recentActivities'] as List? ?? [])
          .map((e) => RecentActivity.fromJson(e))
          .toList(),
      weeklyAttendance: weekly,
      pendingRequests: (json['pendingRequests'] as List? ?? [])
          .map((e) => PendingRequest.fromJson(e))
          .toList(),
    );
  }

  static List<WeeklyAttendance> _mockWeekly() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final pcts = [50.0, 70.0, 85.0, 75.0, 80.0, 65.0];
    return List.generate(days.length, (i) => WeeklyAttendance(day: days[i], percentage: pcts[i]));
  }
}

// ──────────────────────────────────────
// Weekly Attendance (for line chart)
// ──────────────────────────────────────
class WeeklyAttendance {
  final String day;
  final double percentage;

  const WeeklyAttendance({required this.day, required this.percentage});

  factory WeeklyAttendance.fromJson(Map<String, dynamic> json) {
    return WeeklyAttendance(
      day: json['day'] ?? '',
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

// ──────────────────────────────────────
// Recent Activity
// ──────────────────────────────────────
enum ActivityType { teacher, student, course, attendance, report }

class RecentActivity {
  final String title;
  final String subtitle;
  final String time;
  final ActivityType type;

  RecentActivity({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.type,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      time: json['time'] ?? '',
      type: ActivityType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ActivityType.report,
      ),
    );
  }
}

// ──────────────────────────────────────
// Pending Request
// ──────────────────────────────────────
class PendingRequest {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String course;
  final int semester;

  PendingRequest({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.course,
    required this.semester,
  });

  factory PendingRequest.fromJson(Map<String, dynamic> json) {
    final academic = json['academic'] ?? {};
    return PendingRequest(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['fullName'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      course: academic['course'] ?? '',
      semester: academic['semester'] ?? 1,
    );
  }
}
