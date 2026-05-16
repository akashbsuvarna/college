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
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.dividerColor, width: 1)),
      ),
      child: Row(
        children: [
          Text(_pageTitles[_selectedIndex],
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
          const Spacer(),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: const TextField(
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 9),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: const Text('A',
                  style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.w800, fontSize: 16)),
            ),
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
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, letterSpacing: -0.5)),
            const SizedBox(height: 6),
            Text("Here's what's happening in your college today.",
                style: TextStyle(fontSize: 15, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.calendar_month_rounded, size: 20, color: AppTheme.textMuted),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(dateStr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                Text(dayStr, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
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
              change: '12',
              icon: Icons.group_rounded,
              color: const Color(0xFF4F46E5), bgColor: const Color(0xFFEEF2FF),
            ),
          ),
          SizedBox(
            width: (constraints.maxWidth - 48) / 4,
            child: DashboardStatCard(
              title: 'Total Teachers', value: '${s.totalTeachers}',
              change: '2',
              icon: Icons.school_rounded,
              color: const Color(0xFF0EA5E9), bgColor: const Color(0xFFF0F9FF),
            ),
          ),
          SizedBox(
            width: (constraints.maxWidth - 48) / 4,
            child: DashboardStatCard(
              title: 'Total Courses', value: '${s.totalCourses}',
              change: '3',
              icon: Icons.menu_book_rounded,
              color: const Color(0xFFF59E0B), bgColor: const Color(0xFFFFFBEB),
            ),
          ),
          SizedBox(
            width: (constraints.maxWidth - 48) / 4,
            child: DashboardStatCard(
              title: 'Total Subjects', value: '${s.totalSubjects}',
              change: '5',
              icon: Icons.layers_rounded,
              color: const Color(0xFF8B5CF6), bgColor: const Color(0xFFF5F3FF),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Activities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          const SizedBox(height: 20),
          ...s.recentActivities.take(4).map((a) {
            final entry = iconMap[a.type] ?? iconMap[ActivityType.report]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: entry.$3, shape: BoxShape.circle),
                    child: Icon(entry.$1, color: entry.$2, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                        const SizedBox(height: 2),
                        Text(a.subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Text(a.time, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => onTabChange(6),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.dividerColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('View All Activities',
                  style: TextStyle(color: Color(0xFF4F46E5), fontSize: 14, fontWeight: FontWeight.w700)),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Pending Requests',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              TextButton(
                onPressed: onViewRequests,
                child: const Text('View All',
                    style: TextStyle(color: Color(0xFF4F46E5), fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (s.pendingRequests.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No pending requests', style: TextStyle(color: AppTheme.textMuted, fontSize: 14, fontWeight: FontWeight.w500)),
              ),
            )
          else
            ...s.pendingRequests.take(3).map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: const Color(0xFF4F46E5), borderRadius: BorderRadius.circular(14)),
                        child: Center(
                          child: Text(
                            r.name.isNotEmpty ? r.name[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.textPrimary)),
                            const SizedBox(height: 2),
                            Text('${r.course} • Sem ${r.semester}', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(r.email, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
                          Text(r.phone, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(color: const Color(0xFFDCFCE7), shape: BoxShape.circle),
                        child: Icon(Icons.check_rounded, color: AppTheme.accentGreen, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(color: const Color(0xFFFEE2E2), shape: BoxShape.circle),
                        child: Icon(Icons.close_rounded, color: AppTheme.accentRed, size: 20),
                      ),
                    ],
                  ),
                )),
          const SizedBox(height: 4),
          if (s.pendingRequests.isNotEmpty)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: onViewRequests,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.dividerColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('View All Requests',
                    style: TextStyle(color: Color(0xFF4F46E5), fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ),
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
