class DashboardStats {
  final int totalTeachers;
  final int totalStudents;
  final int activeTeachers;
  final int activeStudents;
  final double attendanceRate;
  final List<RecentActivity> recentActivities;

  DashboardStats({
    required this.totalTeachers,
    required this.totalStudents,
    required this.activeTeachers,
    required this.activeStudents,
    required this.attendanceRate,
    required this.recentActivities,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalTeachers: json['totalTeachers'] ?? 0,
      totalStudents: json['totalStudents'] ?? 0,
      activeTeachers: json['activeTeachers'] ?? 0,
      activeStudents: json['activeStudents'] ?? 0,
      attendanceRate: (json['attendanceRate'] ?? 0.0).toDouble(),
      recentActivities: (json['recentActivities'] as List? ?? [])
          .map((e) => RecentActivity.fromJson(e))
          .toList(),
    );
  }
}

enum ActivityType { teacher, student, report }

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
