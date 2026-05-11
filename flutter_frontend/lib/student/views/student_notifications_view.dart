import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../admin/core/app_theme.dart';
import '../viewmodels/student_portal_viewmodel.dart';
import '../models/student_portal_model.dart';

class StudentNotificationsView extends StatelessWidget {
  const StudentNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentPortalViewModel>(
      builder: (ctx, vm, _) {
        return Column(
          children: [
            // ── Header ───────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Notifications (${vm.notifications.length})',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: vm.loadNotifications,
                    icon: const Icon(Icons.refresh_rounded,
                        color: AppTheme.textSecondary, size: 20),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            ),

            // ── List ─────────────────────────────────────────────────────
            Expanded(
              child: vm.isNotificationsLoading && vm.notifications.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.accentCyan))
                  : RefreshIndicator(
                      onRefresh: vm.loadNotifications,
                      color: AppTheme.accentCyan,
                      child: vm.notifications.isEmpty
                          ? Stack(
                              children: [
                                ListView(
                                    physics: const AlwaysScrollableScrollPhysics()),
                                _buildEmpty(),
                              ],
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                              itemCount: vm.notifications.length,
                              separatorBuilder: (_, s) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (ctx, i) => _NotificationCard(
                                  notification: vm.notifications[i]),
                            ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_rounded,
              size: 56, color: AppTheme.textMuted),
          const SizedBox(height: 12),
          const Text('No notifications yet',
              style:
                  TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
          const SizedBox(height: 6),
          const Text('New announcements will appear here',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
        ],
      ),
    );
  }
}

// ─── Notification Card ───────────────────────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  final StudentNotification notification;
  const _NotificationCard({required this.notification});

  String _timeAgo(String dateStr) {
    try {
      final d = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final diff = now.difference(d);

      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return DateFormat('dd MMM yyyy').format(d);
    } catch (_) {
      return '';
    }
  }

  Color get _targetColor => switch (notification.target) {
        'students' => AppTheme.accentCyan,
        'teachers' => AppTheme.accentPurple,
        _ => AppTheme.accentIndigo,
      };

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _targetColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              notification.target == 'students'
                  ? Icons.school_rounded
                  : Icons.campaign_rounded,
              color: _targetColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      _timeAgo(notification.createdAt),
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notification.message,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _targetColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    notification.target == 'all'
                        ? 'Everyone'
                        : notification.target == 'students'
                            ? 'Students'
                            : 'Teachers',
                    style: TextStyle(
                        color: _targetColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
