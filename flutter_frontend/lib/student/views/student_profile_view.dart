import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../admin/core/app_theme.dart';
import '../viewmodels/student_portal_viewmodel.dart';
import '../models/student_portal_model.dart';

class StudentProfileView extends StatelessWidget {
  const StudentProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentPortalViewModel>(
      builder: (ctx, vm, _) {
        if (vm.isLoading && vm.student == null) {
          return const Center(
              child:
                  CircularProgressIndicator(color: AppTheme.accentCyan));
        }

        final s = vm.student;
        if (s == null) {
          return const Center(
            child: Text('Unable to load profile',
                style: TextStyle(color: AppTheme.textSecondary)),
          );
        }

        return RefreshIndicator(
          onRefresh: vm.loadProfile,
          color: AppTheme.accentCyan,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ── Header card ──────────────────────────────────────────
                _buildHeader(s),
                const SizedBox(height: 20),

                // ── Personal info ────────────────────────────────────────
                _cardSection(
                  title: 'Personal Information',
                  icon: Icons.person_rounded,
                  color: AppTheme.accentIndigo,
                  children: [
                    _infoRow(Icons.email_rounded, 'Email', s.email,
                        AppTheme.accentIndigo),
                    _infoRow(Icons.phone_rounded, 'Phone', s.phone,
                        AppTheme.accentGreen),
                    _infoRow(Icons.bloodtype_rounded, 'Blood Group',
                        s.bloodGroup, AppTheme.accentRed),
                    _infoRow(Icons.people_rounded, 'Caste', s.caste,
                        AppTheme.accentOrange),
                    _infoRow(Icons.location_on_rounded, 'Address',
                        s.permanentAddress, AppTheme.accentPurple),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Parent info ──────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _cardSection(
                        title: "Father's Details",
                        icon: Icons.man_rounded,
                        color: AppTheme.accentCyan,
                        children: [
                          _infoRow(Icons.person_rounded, 'Name',
                              s.father.name, AppTheme.accentCyan),
                          _infoRow(Icons.work_rounded, 'Occupation',
                              s.father.occupation, AppTheme.accentOrange),
                          _infoRow(Icons.phone_rounded, 'Mobile',
                              s.father.mobile, AppTheme.accentGreen),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _cardSection(
                        title: "Mother's Details",
                        icon: Icons.woman_rounded,
                        color: AppTheme.accentPurple,
                        children: [
                          _infoRow(Icons.person_rounded, 'Name',
                              s.mother.name, AppTheme.accentPurple),
                          _infoRow(Icons.work_rounded, 'Occupation',
                              s.mother.occupation, AppTheme.accentOrange),
                          _infoRow(Icons.phone_rounded, 'Mobile',
                              s.mother.mobile, AppTheme.accentGreen),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Education ────────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _cardSection(
                        title: 'SSLC',
                        icon: Icons.menu_book_rounded,
                        color: AppTheme.accentGreen,
                        children: [
                          _infoRow(Icons.school_rounded, 'School',
                              s.sslc.school, AppTheme.accentGreen),
                          _infoRow(
                              Icons.percent_rounded,
                              'Percentage',
                              '${s.sslc.percentage}%',
                              AppTheme.accentIndigo),
                          _infoRow(Icons.manage_accounts_rounded, 'Board',
                              s.sslc.board, AppTheme.accentOrange),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _cardSection(
                        title: 'PUC',
                        icon: Icons.menu_book_rounded,
                        color: AppTheme.accentOrange,
                        children: [
                          _infoRow(Icons.account_balance_rounded, 'College',
                              s.puc.college, AppTheme.accentOrange),
                          _infoRow(
                              Icons.percent_rounded,
                              'Percentage',
                              '${s.puc.percentage}%',
                              AppTheme.accentIndigo),
                          _infoRow(Icons.subject_rounded, 'Course',
                              s.puc.course, AppTheme.accentCyan),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(StudentPortalModel student) {
    final initial = student.fullName.isNotEmpty ? student.fullName[0] : '?';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                initial.toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  student.email,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _headerChip(
                        Icons.book_rounded, student.academic.course),
                    _headerChip(Icons.calendar_month_rounded,
                        'Sem ${student.academic.semester}'),
                    _headerChip(
                      Icons.circle,
                      student.status == 'active' ? 'Active' : student.status,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 5),
          Text(text,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Card section ───────────────────────────────────────────────────────────
  Widget _cardSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color color) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 11)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
