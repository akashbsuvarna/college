import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/teacher_model.dart';
import '../viewmodels/teacher_viewmodel.dart';
import '../../core/app_theme.dart';
import 'add_edit_teacher_view.dart';


class TeacherDetailView extends StatelessWidget {
  final TeacherModel teacher;
  const TeacherDetailView({super.key, required this.teacher});

  Color get _statusColor => switch (teacher.status) {
        'active' => AppTheme.accentGreen,
        'on_leave' => AppTheme.accentOrange,
        _ => AppTheme.accentRed,
      };

  String get _statusLabel => switch (teacher.status) {
        'active' => 'Active',
        'on_leave' => 'On Leave',
        _ => 'Inactive',
      };

  Color _avatarColor(String name) {
    final colors = [
      AppTheme.accentIndigo,
      AppTheme.accentPurple,
      AppTheme.accentCyan,
      AppTheme.accentGreen,
      AppTheme.accentOrange,
    ];
    return colors[name.codeUnits.first % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _avatarColor(teacher.name);
    final initials =
        teacher.name.trim().split(' ').take(2).map((w) => w[0]).join();

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        backgroundColor: AppTheme.sidebarBg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textSecondary, size: 18),
        ),
        title: const Text(
          'Teacher Profile',
          style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddEditTeacherView(
                  teacher: teacher,
                  viewModel: Provider.of<TeacherViewModel>(context, listen: false),
                ),
              ),
            ),
            icon: const Icon(Icons.edit_rounded,
                size: 16, color: AppTheme.accentIndigo),
            label: const Text('Edit',
                style: TextStyle(color: AppTheme.accentIndigo)),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.dividerColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Large avatar
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              teacher.name,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: _statusColor.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                _statusLabel,
                                style: TextStyle(
                                    color: _statusColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          teacher.designation,
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            _InfoPill(
                                icon: Icons.badge_rounded,
                                label: teacher.employeeId,
                                color: AppTheme.accentIndigo),
                            _InfoPill(
                                icon: Icons.account_balance_rounded,
                                label: teacher.department,
                                color: AppTheme.accentPurple),
                            _InfoPill(
                                icon: Icons.school_rounded,
                                label: teacher.qualification,
                                color: AppTheme.accentCyan),
                            _InfoPill(
                                icon: Icons.calendar_month_rounded,
                                label: 'Joined: ${teacher.joiningDate}',
                                color: AppTheme.accentGreen),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Courses Count
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppTheme.gradientBlue,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Text(
                          teacher.coursesAssigned.toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 28),
                        ),
                        const Text(
                          'Courses',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildContactCard()),
                const SizedBox(width: 20),
                Expanded(child: _buildSubjectsCard()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
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
          const Text(
            'Contact Information',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16),
          ),
          const SizedBox(height: 16),
          _DetailRow(
              icon: Icons.email_rounded,
              label: 'Email',
              value: teacher.email,
              color: AppTheme.accentIndigo),
          const SizedBox(height: 12),
          _DetailRow(
              icon: Icons.phone_rounded,
              label: 'Phone',
              value: teacher.phone,
              color: AppTheme.accentGreen),
          const SizedBox(height: 12),
          _DetailRow(
              icon: Icons.account_balance_rounded,
              label: 'Department',
              value: teacher.department,
              color: AppTheme.accentPurple),
          const SizedBox(height: 12),
          _DetailRow(
              icon: Icons.workspace_premium_rounded,
              label: 'Designation',
              value: teacher.designation,
              color: AppTheme.accentCyan),
        ],
      ),
    );
  }

  Widget _buildSubjectsCard() {
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
          const Text(
            'Subjects Taught',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: teacher.subjects
                .map(
                  (s) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppTheme.accentIndigo.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppTheme.accentIndigo.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      s,
                      style: const TextStyle(
                          color: AppTheme.accentIndigo,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                )
                .toList(),
          ),
          if (teacher.subjects.isEmpty)
            const Text(
              'No subjects assigned yet.',
              style:
                  TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoPill(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
