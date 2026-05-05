import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student_model.dart';
import '../viewmodels/student_viewmodel.dart';
import '../../core/app_theme.dart';
import 'add_edit_student_view.dart';

class StudentDetailView extends StatelessWidget {
  final StudentModel student;

  const StudentDetailView({super.key, required this.student});

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
    final color = _avatarColor(student.fullName);
    final initials =
        student.fullName.trim().split(' ').take(2).map((w) => w[0]).join();

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
          'Student Profile',
          style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddEditStudentView(
                  student: student,
                  viewModel: Provider.of<StudentViewModel>(context, listen: false),
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
                            Flexible(
                              child: Text(
                                student.fullName,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accentGreen.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppTheme.accentGreen.withValues(alpha: 0.4)),
                              ),
                              child: const Text(
                                'Active',
                                style: TextStyle(
                                    color: AppTheme.accentGreen,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          student.email,
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            _InfoPill(
                                icon: Icons.school_rounded,
                                label: student.academic.course,
                                color: AppTheme.accentIndigo),
                            _InfoPill(
                                icon: Icons.calendar_today_rounded,
                                label: 'Sem ${student.academic.semester}',
                                color: AppTheme.accentPurple),
                            _InfoPill(
                                icon: Icons.bloodtype_rounded,
                                label: student.bloodGroup.name,
                                color: AppTheme.accentRed),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Semester Count / Quick Info
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppTheme.gradientOrange,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Text(
                          student.academic.semester.toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 28),
                        ),
                        const Text(
                          'Semester',
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
                Expanded(child: _buildAcademicCard()),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildParentCard()),
                const SizedBox(width: 20),
                Expanded(child: _buildEducationCard()),
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
            'Personal Info',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16),
          ),
          const SizedBox(height: 16),
          _DetailRow(
              icon: Icons.phone_rounded,
              label: 'Phone',
              value: student.phone,
              color: AppTheme.accentGreen),
          const SizedBox(height: 12),
          _DetailRow(
              icon: Icons.location_on_rounded,
              label: 'Address',
              value: student.permanentAddress.isEmpty ? 'N/A' : student.permanentAddress,
              color: AppTheme.accentPurple),
          const SizedBox(height: 12),
          _DetailRow(
              icon: Icons.group_rounded,
              label: 'Caste',
              value: student.caste.isEmpty ? 'N/A' : student.caste,
              color: AppTheme.accentCyan),
        ],
      ),
    );
  }

  Widget _buildAcademicCard() {
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
            'Academic Info',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16),
          ),
          const SizedBox(height: 16),
          _DetailRow(
              icon: Icons.school_rounded,
              label: 'Course',
              value: student.academic.course,
              color: AppTheme.accentIndigo),
          const SizedBox(height: 12),
          _DetailRow(
              icon: Icons.calendar_month_rounded,
              label: 'Semester',
              value: student.academic.semester.toString(),
              color: AppTheme.accentGreen),
        ],
      ),
    );
  }

  Widget _buildParentCard() {
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
            'Parent Details',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16),
          ),
          const SizedBox(height: 16),
          _DetailRow(
              icon: Icons.person_rounded,
              label: 'Father',
              value: '${student.father.name} (${student.father.mobile})',
              color: AppTheme.accentIndigo),
          const SizedBox(height: 12),
          _DetailRow(
              icon: Icons.work_rounded,
              label: 'Father Occupation',
              value: student.father.occupation.isEmpty ? 'N/A' : student.father.occupation,
              color: AppTheme.accentPurple),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.dividerColor),
          const SizedBox(height: 16),
          _DetailRow(
              icon: Icons.person_3_rounded,
              label: 'Mother',
              value: '${student.mother.name} (${student.mother.mobile})',
              color: AppTheme.accentOrange),
          const SizedBox(height: 12),
          _DetailRow(
              icon: Icons.work_rounded,
              label: 'Mother Occupation',
              value: student.mother.occupation.isEmpty ? 'N/A' : student.mother.occupation,
              color: AppTheme.accentCyan),
        ],
      ),
    );
  }

  Widget _buildEducationCard() {
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
            'Previous Education',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16),
          ),
          const SizedBox(height: 16),
          _DetailRow(
              icon: Icons.history_edu_rounded,
              label: 'SSLC',
              value: '${student.sslc.school} • ${student.sslc.percentage}%',
              color: AppTheme.accentIndigo),
          const SizedBox(height: 12),
          _DetailRow(
              icon: Icons.assignment_rounded,
              label: 'SSLC Board',
              value: student.sslc.board.isEmpty ? 'N/A' : student.sslc.board,
              color: AppTheme.accentPurple),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.dividerColor),
          const SizedBox(height: 16),
          _DetailRow(
              icon: Icons.account_balance_rounded,
              label: 'PUC / 12th',
              value: '${student.puc.college} • ${student.puc.percentage}%',
              color: AppTheme.accentGreen),
          const SizedBox(height: 12),
          _DetailRow(
              icon: Icons.science_rounded,
              label: 'PUC Course',
              value: student.puc.course.isEmpty ? 'N/A' : student.puc.course,
              color: AppTheme.accentCyan),
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
            color: color.withValues(alpha: 0.12),
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