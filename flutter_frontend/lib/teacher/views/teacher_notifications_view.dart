import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../admin/core/app_theme.dart';
import '../viewmodels/teacher_portal_viewmodel.dart';

class TeacherNotificationsView extends StatelessWidget {
  const TeacherNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherPortalViewModel>(
      builder: (ctx, vm, _) {
        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Notifications (${vm.notifications.length})',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: vm.fetchNotifications,
                    icon: const Icon(Icons.refresh_rounded,
                        color: AppTheme.textSecondary, size: 24),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: vm.isNotificationsLoading && vm.notifications.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF10B981)))
                  : RefreshIndicator(
                      onRefresh: vm.fetchNotifications,
                      color: const Color(0xFF10B981),
                      child: vm.notifications.isEmpty
                          ? Stack(
                              children: [
                                ListView(
                                    physics: const AlwaysScrollableScrollPhysics()),
                                _buildEmpty(),
                              ],
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                              itemCount: vm.notifications.length,
                              separatorBuilder: (_, s) =>
                                  const SizedBox(height: 12),
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
              size: 64, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          const Text('No notifications yet',
              style:
                  TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('New announcements will appear here',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final dynamic notification;
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

  Color get _targetColor {
    final target = notification['target'] ?? 'all';
    switch (target) {
      case 'students':
        return const Color(0xFF0EA5E9);
      case 'teachers':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6366F1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final target = notification['target'] ?? 'all';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _targetColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              target == 'students'
                  ? Icons.school_rounded
                  : Icons.campaign_rounded,
              color: _targetColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification['title'] ?? '',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      _timeAgo(notification['createdAt'] ?? ''),
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  notification['message'] ?? '',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _targetColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    target == 'all'
                        ? 'Everyone'
                        : target == 'students'
                            ? 'Students'
                            : 'Teachers',
                    style: TextStyle(
                        color: _targetColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
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
