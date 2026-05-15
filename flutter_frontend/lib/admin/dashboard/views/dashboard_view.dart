import 'package:flutter/material.dart';
import 'package:flutter_frontend/admin/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_stats_model.dart';
import '../../core/app_theme.dart';
import '../../widgets/admin_sidebar.dart';
import '../../teacher/views/teacher_list_view.dart';
import '../../student/views/student_list_view.dart';
import '../../course/views/course_list_view.dart';
import '../../subject/views/subject_list_view.dart';
import 'attendance_view.dart';
import 'notification_view.dart';
import 'dashboard_widgets.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _selectedIndex = 0;
  bool _sidebarCollapsed = false;

  final List<String> _pageTitles = [
    'Dashboard',
    'Teachers',
    'Students',
    'Courses',
    'Subjects',
    'Attendance',
    'Notifications',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: Row(
        children: [
          AdminSidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (i) => setState(() => _selectedIndex = i),
            isCollapsed: _sidebarCollapsed,
            onToggleCollapse: () =>
                setState(() => _sidebarCollapsed = !_sidebarCollapsed),
          ),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: _buildCurrentPage()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.dividerColor, width: 1)),
      ),
      child: Row(
        children: [
          Text(_pageTitles[_selectedIndex],
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
          const Spacer(),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 240),
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: const TextField(
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 18),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.accentIndigo.withValues(alpha: 0.15),
            child: const Text('A',
                style: TextStyle(color: AppTheme.accentIndigo, fontWeight: FontWeight.w700, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return ChangeNotifierProvider(
          create: (_) => DashboardViewModel(),
          child: _DashboardContent(onTabChange: (i) => setState(() => _selectedIndex = i)),
        );
      case 1:
        return const TeacherListView();
      case 2:
        return const StudentListView();
      case 3:
        return const CourseListView();
      case 4:
        return const SubjectListView();
      case 5:
        return const AttendanceView();
      case 6:
        return const NotificationView();
      default:
        return _ComingSoon(title: _pageTitles[_selectedIndex]);
    }
  }
}

// ═══════════════════════════════════════════
// DASHBOARD CONTENT
// ═══════════════════════════════════════════
class _DashboardContent extends StatelessWidget {
  final ValueChanged<int> onTabChange;
  const _DashboardContent({required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (ctx, vm, _) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.accentIndigo));
        }
        final stats = vm.stats;
        if (stats == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: AppTheme.accentRed, size: 48),
                const SizedBox(height: 12),
                Text(vm.errorMessage ?? 'Failed to load data',
                    style: const TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: vm.refresh,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentIndigo),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: vm.refresh,
          color: AppTheme.accentIndigo,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _welcomeRow(),
                const SizedBox(height: 20),
                _statCardsRow(stats),
                const SizedBox(height: 20),
                _middleRow(stats),
                const SizedBox(height: 16),
                AttendanceSummaryRow(
                  avgRate: stats.attendanceRate,
                  presentCount: stats.presentCount,
                  absentCount: stats.absentCount,
                ),
                const SizedBox(height: 20),
                _bottomRow(stats, () => onTabChange(2)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Welcome row ──
  Widget _welcomeRow() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final dateStr = '${months[now.month - 1]} ${now.day}, ${now.year}';
    final dayStr = weekdays[now.weekday % 7];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome back, Admin User!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            Text("Here's what's happening in your college today.",
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 16, color: AppTheme.textMuted),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(dateStr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                Text(dayStr, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ── 4 Stat cards ──
  Widget _statCardsRow(DashboardStats s) {
    return LayoutBuilder(builder: (ctx, constraints) {
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          SizedBox(
            width: (constraints.maxWidth - 48) / 4,
            child: DashboardStatCard(
              title: 'Total Students', value: '${s.totalStudents}',
              change: '↑ ${s.pendingStudents} pending',
              icon: Icons.people_alt_rounded,
              color: const Color(0xFF4F46E5), bgColor: const Color(0xFFEEF2FF),
            ),
          ),
          SizedBox(
            width: (constraints.maxWidth - 48) / 4,
            child: DashboardStatCard(
              title: 'Total Teachers', value: '${s.totalTeachers}',
              change: '↑ ${s.activeTeachers} active',
              icon: Icons.school_rounded,
              color: const Color(0xFF0891B2), bgColor: const Color(0xFFECFEFF),
            ),
          ),
          SizedBox(
            width: (constraints.maxWidth - 48) / 4,
            child: DashboardStatCard(
              title: 'Total Courses', value: '${s.totalCourses}',
              change: '↑ courses',
              icon: Icons.book_rounded,
              color: const Color(0xFFF59E0B), bgColor: const Color(0xFFFFFBEB),
            ),
          ),
          SizedBox(
            width: (constraints.maxWidth - 48) / 4,
            child: DashboardStatCard(
              title: 'Total Subjects', value: '${s.totalSubjects}',
              change: '↑ subjects',
              icon: Icons.layers_rounded,
              color: const Color(0xFFEF4444), bgColor: const Color(0xFFFEF2F2),
            ),
          ),
        ],
      );
    });
  }

  // ── Middle row: Chart + Recent Activities ──
  Widget _middleRow(DashboardStats s) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: AttendanceLineChart(data: s.weeklyAttendance)),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: _recentActivities(s)),
      ],
    );
  }

  // ── Recent Activities card ──
  Widget _recentActivities(DashboardStats s) {
    final iconMap = {
      ActivityType.student: (Icons.person_add_rounded, const Color(0xFF4F46E5), const Color(0xFFEEF2FF)),
      ActivityType.attendance: (Icons.check_circle_rounded, const Color(0xFFEF4444), const Color(0xFFFEF2F2)),
      ActivityType.course: (Icons.book_rounded, const Color(0xFFF59E0B), const Color(0xFFFFFBEB)),
      ActivityType.teacher: (Icons.school_rounded, const Color(0xFF8B5CF6), const Color(0xFFF5F3FF)),
      ActivityType.report: (Icons.description_rounded, const Color(0xFF6B7280), const Color(0xFFF3F4F6)),
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Activities',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 16),
          ...s.recentActivities.take(4).map((a) {
            final entry = iconMap[a.type] ?? iconMap[ActivityType.report]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: entry.$3, borderRadius: BorderRadius.circular(10)),
                    child: Icon(entry.$1, color: entry.$2, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                        Text(a.subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  Text(a.time, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                ],
              ),
            );
          }),
          const Divider(color: AppTheme.dividerColor),
          Center(
            child: TextButton(
              onPressed: () => onTabChange(6),
              child: const Text('View All Activities',
                  style: TextStyle(color: Color(0xFF4F46E5), fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom row: Donut + Pending Requests ──
  Widget _bottomRow(DashboardStats s, VoidCallback onViewRequests) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: StudentDonutChart(
            active: s.activeStudents,
            pending: s.pendingStudents,
            inactive: s.inactiveStudents,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: _pendingRequests(s, onViewRequests)),
      ],
    );
  }

  // ── Pending Requests card ──
  Widget _pendingRequests(DashboardStats s, VoidCallback onViewRequests) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Pending Requests',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              TextButton(
                onPressed: onViewRequests,
                child: const Text('View All',
                    style: TextStyle(color: Color(0xFF4F46E5), fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (s.pendingRequests.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No pending requests', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
              ),
            )
          else
            ...s.pendingRequests.take(3).map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                        child: Text(
                          r.name.isNotEmpty ? r.name[0].toUpperCase() : '?',
                          style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary)),
                            Text('${r.course} • Sem ${r.semester}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(r.email, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                          Text(r.phone, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.check_circle_rounded, color: AppTheme.accentGreen, size: 22),
                      const SizedBox(width: 4),
                      Icon(Icons.cancel_rounded, color: AppTheme.accentRed, size: 22),
                    ],
                  ),
                )),
          if (s.pendingRequests.isNotEmpty) ...[
            const Divider(color: AppTheme.dividerColor),
            Center(
              child: TextButton(
                onPressed: onViewRequests,
                child: const Text('View All Requests',
                    style: TextStyle(color: Color(0xFF4F46E5), fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  final String title;
  const _ComingSoon({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('$title Coming Soon', style: const TextStyle(color: AppTheme.textSecondary)));
  }
}
