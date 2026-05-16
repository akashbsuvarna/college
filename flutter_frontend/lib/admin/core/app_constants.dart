import '../../config/api_config.dart';

class AppConstants {
  // Base URL for API
  static final String baseUrl = ApiConfig.baseUrl;

  // Endpoints
  static final String dashboardStats = '$baseUrl/admin/stats';
  static final String teachersEndpoint = '$baseUrl/admin/teachers';
  static final String studentsEndpoint = '$baseUrl/admin/students';
  static final String coursesEndpoint = '$baseUrl/admin/courses';
  static final String subjectsEndpoint = '$baseUrl/admin/subjects';
  static final String attendanceEndpoint = '$baseUrl/attendance';

  // Sidebar menu items
  static const String menuDashboard = 'Dashboard';
  static const String menuTeachers = 'Teachers';
  static const String menuStudents = 'Students';
}

