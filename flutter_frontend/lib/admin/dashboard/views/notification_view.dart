import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/attendance_notification_viewmodels.dart';
import '../models/attendance_notification_models.dart';
import '../../core/app_theme.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationViewModel>(
      builder: (ctx, vm, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Notifications', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      onPressed: () => _showSendNotificationDialog(context, vm),
                      icon: const Icon(Icons.send, color: Colors.white),
                      label: const Text('Send Notification', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentIndigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: vm.notifications.length,
                    itemBuilder: (ctx, index) {
                      final n = vm.notifications[index];
                      return Card(
                        color: AppTheme.surfaceCard,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(n.title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                          subtitle: Text(n.message, style: const TextStyle(color: AppTheme.textSecondary)),
                          trailing: Text(n.target.toUpperCase(), style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSendNotificationDialog(BuildContext context, NotificationViewModel vm) {
    final titleController = TextEditingController();
    final msgController = TextEditingController();
    String target = "all";

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          title: const Text('Send Notification', style: TextStyle(color: AppTheme.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title'), style: const TextStyle(color: AppTheme.textPrimary)),
              TextField(controller: msgController, decoration: const InputDecoration(labelText: 'Message'), maxLines: 3, style: const TextStyle(color: AppTheme.textPrimary)),
              DropdownButtonFormField<String>(
                value: target,
                dropdownColor: AppTheme.surfaceDark,
                items: ["all", "students", "teachers"].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) => setState(() => target = val!),
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                vm.send(AppNotification(title: titleController.text, message: msgController.text, target: target));
                Navigator.pop(ctx);
              },
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
