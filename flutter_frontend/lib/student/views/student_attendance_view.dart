import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../../admin/core/app_theme.dart';
import '../viewmodels/student_portal_viewmodel.dart';
import '../models/student_portal_model.dart';
import 'package:intl/intl.dart';

class StudentAttendanceView extends StatelessWidget {
  const StudentAttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentPortalViewModel>(
      builder: (ctx, vm, _) {
        final s = vm.student;
        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            return Column(
              children: [
                // ── My QR Section ───────────────────────────────────────────
                if (s != null)
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0EA5E9).withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: isMobile
                        ? Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: QrImageView(
                                  data: s.id,
                                  version: QrVersions.auto,
                                  size: 100,
                                  gapless: false,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'MY ATTENDANCE QR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Show this QR to your teacher to mark your attendance.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: QrImageView(
                                  data: s.id,
                                  version: QrVersions.auto,
                                  size: 100,
                                  gapless: false,
                                ),
                              ),
                              const SizedBox(width: 20),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'MY ATTENDANCE QR',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.2,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Show this QR to your teacher to mark your attendance.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),

                // ── Toolbar ──────────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    children: [
                      const Icon(Icons.history_rounded,
                          color: AppTheme.accentCyan, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Attendance History (${vm.attendance.length})',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: vm.loadAttendance,
                        icon: const Icon(Icons.refresh_rounded,
                            color: AppTheme.textSecondary, size: 22),
                      ),
                    ],
                  ),
                ),

                // ── List ─────────────────────────────────────────────────────
                Expanded(
                  child: vm.isAttendanceLoading && vm.attendance.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.accentCyan))
                      : RefreshIndicator(
                          onRefresh: vm.loadAttendance,
                          color: AppTheme.accentCyan,
                          child: vm.attendance.isEmpty
                              ? Stack(
                                  children: [
                                    ListView(
                                        physics:
                                            const AlwaysScrollableScrollPhysics()),
                                    _buildEmpty(),
                                  ],
                                )
                              : ListView.separated(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 4, 20, 20),
                                  itemCount: vm.attendance.length,
                                  separatorBuilder: (_, s) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (ctx, i) =>
                                      _AttendanceCard(record: vm.attendance[i]),
                                ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fact_check_outlined,
              size: 56, color: AppTheme.textMuted),
          const SizedBox(height: 12),
          const Text('No attendance records yet',
              style:
                  TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
          const SizedBox(height: 6),
          const Text('Show your QR code to the admin to mark attendance',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
        ],
      ),
    );
  }
}

// ─── Attendance Card ─────────────────────────────────────────────────────────
class _AttendanceCard extends StatelessWidget {
  final AttendanceRecord record;
  const _AttendanceCard({required this.record});

  Color get _statusColor => switch (record.status) {
        'present' => AppTheme.accentGreen,
        'late' => AppTheme.accentOrange,
        _ => AppTheme.accentRed,
      };

  String get _statusLabel => switch (record.status) {
        'present' => 'Present',
        'late' => 'Late',
        _ => 'Absent',
      };

  String _formatDate(String dateStr) {
    try {
      final d = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(d);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              record.status == 'present'
                  ? Icons.check_circle_rounded
                  : record.status == 'late'
                      ? Icons.access_time_rounded
                      : Icons.cancel_rounded,
              color: _statusColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Subject + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.subjectName,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (record.subjectCode.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accentCyan.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(record.subjectCode,
                            style: const TextStyle(
                                color: AppTheme.accentCyan,
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        _formatDate(record.date),
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
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
    );
  }
}

