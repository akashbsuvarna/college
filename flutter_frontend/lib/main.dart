import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'admin/dashboard/views/dashboard_view.dart';
import 'admin/core/app_theme.dart';
import 'admin/student/viewmodels/student_viewmodel.dart';
import 'admin/teacher/viewmodels/teacher_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'auth/views/login_view.dart';
import 'admin/course/viewmodels/course_viewmodel.dart';
import 'admin/subject/viewmodels/subject_viewmodel.dart';
import 'admin/dashboard/viewmodels/attendance_notification_viewmodels.dart';
import 'student/viewmodels/student_portal_viewmodel.dart';
import 'student/views/student_login_view.dart';
import 'student/views/student_home_view.dart';
import 'student/views/student_registration_view.dart';
import 'teacher/viewmodels/teacher_portal_viewmodel.dart';
import 'teacher/views/teacher_login_view.dart';
import 'teacher/views/teacher_home_view.dart';
import 'views/landing_portal_view.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()..checkAuthStatus()),
        ChangeNotifierProvider(create: (_) => StudentViewModel()),
        ChangeNotifierProvider(create: (_) => TeacherViewModel()),
        ChangeNotifierProvider(create: (_) => CourseViewModel()),
        ChangeNotifierProvider(create: (_) => SubjectViewModel()),
        ChangeNotifierProvider(create: (_) => AttendanceViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
        ChangeNotifierProvider(create: (_) => StudentPortalViewModel()..checkSession()),
        ChangeNotifierProvider(create: (_) => TeacherPortalViewModel()),
      ],
      child: const CollegeAdminApp(),
    ),
  );
}

class CollegeAdminApp extends StatelessWidget {
  const CollegeAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College Management System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginView(),
        '/dashboard': (context) => const DashboardView(),
        '/student-login': (context) => const StudentLoginView(),
        '/student-register': (context) => const StudentRegistrationView(),
        '/student-home': (context) => const StudentHomeView(),
        '/teacher-login': (context) => const TeacherLoginView(),
        '/teacher-home': (context) => const TeacherHomeView(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final studentViewModel = context.watch<StudentPortalViewModel>();
    final teacherViewModel = context.watch<TeacherPortalViewModel>();

    if (authViewModel.isLoading || studentViewModel.isLoading || teacherViewModel.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Priority: Admin Dashboard if authenticated as admin
    if (authViewModel.isAuthenticated) {
      return const DashboardView();
    } 
    
    // If authenticated as teacher, show teacher home
    if (teacherViewModel.currentTeacher != null) {
      return const TeacherHomeView();
    }

    // If authenticated as student, show student home
    if (studentViewModel.isLoggedIn) {
      return const StudentHomeView();
    }

    // Default to Landing Portal
    return const LandingPortalView();
  }
}
