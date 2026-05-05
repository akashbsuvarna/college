import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../core/app_theme.dart';

/// Sidebar navigation item descriptor
class SidebarItem {
  final IconData icon;
  final String label;
  final int index;

  const SidebarItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}

/// The persistent left-side navigation rail for the Admin Panel.
class AdminSidebar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.isCollapsed,
    required this.onToggleCollapse,
  });

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _widthAnim;

  static const double _expandedWidth = 240;
  static const double _collapsedWidth = 70;

  static const List<SidebarItem> _items = [
    SidebarItem(icon: Icons.dashboard_rounded, label: 'Dashboard', index: 0),
    SidebarItem(icon: Icons.school_rounded, label: 'Teachers', index: 1),
    SidebarItem(icon: Icons.person_rounded, label: 'Students', index: 2),
    SidebarItem(icon: Icons.book_rounded, label: 'Courses', index: 4),
    SidebarItem(icon: Icons.subject_rounded, label: 'Subjects', index: 5),
    SidebarItem(icon: Icons.qr_code_scanner_rounded, label: 'Attendance', index: 6),
    SidebarItem(icon: Icons.notifications_rounded, label: 'Notifications', index: 7),
    SidebarItem(icon: Icons.settings_rounded, label: 'Settings', index: 3),
  ];

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: widget.isCollapsed ? 0.0 : 1.0,
    );
    _widthAnim =
        Tween<double>(begin: _collapsedWidth, end: _expandedWidth).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void didUpdateWidget(AdminSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCollapsed != oldWidget.isCollapsed) {
      if (widget.isCollapsed) {
        _anim.reverse();
      } else {
        _anim.forward();
      }
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _widthAnim,
      builder: (ctx, _) {
        return Container(
          width: _widthAnim.value,
          decoration: BoxDecoration(
            color: AppTheme.sidebarBg,
            border: Border(
              right: BorderSide(color: AppTheme.dividerColor, width: 1),
            ),
          ),
          child: ClipRect(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: _items
                          .map((item) => _buildNavItem(item))
                          .toList(),
                    ),
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final expanded = _widthAnim.value > 130;
    return Container(
      height: 72,
      padding: EdgeInsets.symmetric(horizontal: expanded ? 12 : 0),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (expanded) ...[
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppTheme.gradientBlue,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.admin_panel_settings_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 120, // fixed width for text chunk to avoid overflows
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'AdminPanel',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'College ERP',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: widget.onToggleCollapse,
                  icon: Icon(Icons.menu_open_rounded,
                      color: AppTheme.textSecondary, size: 20),
                  tooltip: 'Collapse',
                ),
              ] else ...[
                IconButton(
                  onPressed: widget.onToggleCollapse,
                  icon: Icon(Icons.menu_rounded,
                      color: AppTheme.textSecondary, size: 20),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(SidebarItem item) {
    final isSelected = widget.selectedIndex == item.index;
    final expanded = _widthAnim.value > 130;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentIndigo.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(
                  color: AppTheme.accentIndigo.withValues(alpha: 0.2), width: 1)
              : null,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => widget.onItemSelected(item.index),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: expanded ? 12 : 0,
              vertical: 11,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!expanded) const SizedBox(width: 17), // visual compensation when collapsed
                  Icon(
                    item.icon,
                    size: 20,
                    color: isSelected
                        ? AppTheme.accentIndigo
                        : AppTheme.textSecondary,
                  ),
                  if (expanded) ...[
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 130, // reserved space
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 4),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.accentIndigo,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final expanded = _widthAnim.value > 130;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.dividerColor, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.accentPurple.withValues(alpha: 0.2),
                child: const Text(
                  'A',
                  style: TextStyle(
                      color: AppTheme.accentPurple,
                      fontWeight: FontWeight.w700,
                      fontSize: 13),
                ),
              ),
              if (expanded) ...[
                const SizedBox(width: 10),
                SizedBox(
                  width: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Admin User',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Super Admin',
                        style:
                            TextStyle(color: AppTheme.textMuted, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          IconButton(
            onPressed: () => _handleLogout(context),
            icon: const Icon(Icons.logout_rounded),
            color: AppTheme.textMuted,
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to exit the admin panel?',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final authVm = Provider.of<AuthViewModel>(context, listen: false);
              await authVm.logout();
              if (context.mounted) {
                // Navigate back to root wrapper which will show login
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed.withValues(alpha: 0.1),
              foregroundColor: AppTheme.accentRed,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
