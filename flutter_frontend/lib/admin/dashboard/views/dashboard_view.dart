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
    'Settings',
    'Courses',
    'Subjects',
    'Attendance',
    'Notifications',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
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
                Expanded(
                  child: _buildCurrentPage(),
                ),
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
        color: AppTheme.surfaceDark,
        border: Border(
          bottom: BorderSide(color: AppTheme.dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            _pageTitles[_selectedIndex],
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          // Search bar
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 240),
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: const TextField(
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: AppTheme.textMuted, size: 18),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.accentIndigo.withValues(alpha: 0.2),
            child: const Text(
              'A',
              style: TextStyle(
                  color: AppTheme.accentIndigo,
                  fontWeight: FontWeight.w700,
                  fontSize: 14),
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
          child: const _DashboardContent(),
        );
      case 1:
        return const TeacherListView();
      case 2:
        return const StudentListView();
      case 4:
        return const CourseListView();
      case 5:
        return const SubjectListView();
      case 6:
        return const AttendanceView();
      case 7:
        return const NotificationView();
      default:
        return _ComingSoon(title: _pageTitles[_selectedIndex]);
    }
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

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
                Text(vm.errorMessage ?? 'Failed to load data', style: const TextStyle(color: AppTheme.textSecondary)),
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
                _buildWelcomeBanner(context),
                const SizedBox(height: 24),
                _buildStatCards(stats),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildActivityFeed(stats)),
                    const SizedBox(width: 20),
                    Expanded(flex: 2, child: _buildQuickStats(stats)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE9E6E8), Color(0xFF0D1B35)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Welcome Back, Admin! 👋', style: TextStyle(color: Color(0xFF040914), fontSize: 22, fontWeight: FontWeight.w700)),
          SizedBox(height: 6),
          Text('Focusing on your Teachers and Students management today.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildStatCards(DashboardStats stats) {
    final cards = [
      _StatCardData(
        title: 'Total Teachers',
        value: stats.totalTeachers.toString(),
        subtitle: '${stats.activeTeachers} active',
        icon: Icons.school_rounded,
        gradient: AppTheme.gradientBlue,
      ),
      _StatCardData(
        title: 'Total Students',
        value: stats.totalStudents.toString(),
        subtitle: '${stats.activeStudents} active',
        icon: Icons.people_alt_rounded,
        gradient: AppTheme.gradientPurple,
      ),
      _StatCardData(
        title: 'Attendance Rate',
        value: '${stats.attendanceRate.toStringAsFixed(1)}%',
        subtitle: 'Avg. this week',
        icon: Icons.task_alt_rounded,
        gradient: AppTheme.gradientOrange,
      ),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: cards.map((c) => SizedBox(width: 280, child: _StatCard(data: c))).toList(),
    );
  }

  Widget _buildActivityFeed(DashboardStats stats) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('Recent Activity', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          const Divider(height: 1, color: AppTheme.dividerColor),
          ...stats.recentActivities.map((a) => _ActivityTile(activity: a)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildQuickStats(DashboardStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Overview', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 20),
          _MiniBarChart(label: 'Active Teachers', value: stats.activeTeachers.toDouble(), max: stats.totalTeachers.toDouble(), color: AppTheme.accentIndigo),
          const SizedBox(height: 14),
          _MiniBarChart(label: 'Active Students', value: stats.activeStudents.toDouble(), max: stats.totalStudents.toDouble(), color: AppTheme.accentPurple),
          const SizedBox(height: 14),
          _MiniBarChart(label: 'Attendance Rate', value: stats.attendanceRate, max: 100, color: AppTheme.accentOrange),
        ],
      ),
    );
  }
}

class _StatCardData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;


  const _StatCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });
}

class _StatCard extends StatelessWidget {
  final _StatCardData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: data.gradient[0].withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(data.icon, color: data.gradient[0], size: 24),
          ),
          const SizedBox(height: 16),
          Text(data.value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.w800)),
          Text(data.title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          const SizedBox(height: 4),
          Text(data.subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final RecentActivity activity;
  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    final color = activity.type == ActivityType.teacher ? AppTheme.accentIndigo : AppTheme.accentPurple;
    final icon = activity.type == ActivityType.teacher ? Icons.school_rounded : Icons.person_rounded;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(activity.title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(activity.subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      trailing: Text(activity.time.split('T')[0], style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
    );
  }
}

class _MiniBarChart extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final Color color;

  const _MiniBarChart({required this.label, required this.value, required this.max, required this.color});

  @override
  Widget build(BuildContext context) {
    final frac = max > 0 ? (value / max).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            Text('${(frac * 100).toStringAsFixed(0)}%', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: frac, backgroundColor: AppTheme.dividerColor, color: color, minHeight: 6),
        ),
      ],
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
