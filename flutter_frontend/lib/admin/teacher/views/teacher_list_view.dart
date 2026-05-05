import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/teacher_viewmodel.dart';
import '../models/teacher_model.dart';
import '../../core/app_theme.dart';
import 'teacher_detail_view.dart';
import 'add_edit_teacher_view.dart';

class TeacherListView extends StatelessWidget {
  const TeacherListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TeacherViewModel(),
      child: const _TeacherListContent(),
    );
  }
}

class _TeacherListContent extends StatelessWidget {
  const _TeacherListContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherViewModel>(
      builder: (ctx, vm, _) {
        return Column(
          children: [
            _buildToolbar(ctx, vm),
            _buildFilterBar(ctx, vm),
            Expanded(
              child: vm.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.accentIndigo))
                  : vm.errorMessage != null
                      ? _buildError(vm.errorMessage!)
                      : vm.teachers.isEmpty
                          ? _buildEmpty()
                          : _buildList(ctx, vm),
            ),
          ],
        );
      },
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.accentRed.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.accentRed.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppTheme.accentRed, size: 32),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                  color: AppTheme.accentRed,
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, TeacherViewModel vm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          // Stats chips
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _StatusChip(
                      label: 'All (${vm.teachers.length})',
                      selected: vm.filter == TeacherFilter.all,
                      color: AppTheme.accentIndigo,
                      onTap: () => vm.setFilter(TeacherFilter.all)),
                  const SizedBox(width: 8),
                  _StatusChip(
                      label: 'Active (${vm.activeCount})',
                      selected: vm.filter == TeacherFilter.active,
                      color: AppTheme.accentGreen,
                      onTap: () => vm.setFilter(TeacherFilter.active)),
                  const SizedBox(width: 8),
                  _StatusChip(
                      label: 'On Leave (${vm.onLeaveCount})',
                      selected: vm.filter == TeacherFilter.onLeave,
                      color: AppTheme.accentOrange,
                      onTap: () => vm.setFilter(TeacherFilter.onLeave)),
                  const SizedBox(width: 8),
                  _StatusChip(
                      label: 'Inactive (${vm.inactiveCount})',
                      selected: vm.filter == TeacherFilter.inactive,
                      color: AppTheme.accentRed,
                      onTap: () => vm.setFilter(TeacherFilter.inactive)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Add Teacher button
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => AddEditTeacherView(viewModel: vm)),
            ),
            icon: const Icon(Icons.person_add_rounded, size: 18),
            label: const Text('Add Teacher'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentIndigo,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, TeacherViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 4),
      child: Row(
        children: [
          // Search
          Expanded(
            flex: 3,
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: TextField(
                onChanged: vm.setSearch,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search by name, email or employee ID...',
                  hintStyle: TextStyle(
                      color: AppTheme.textMuted, fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: AppTheme.textMuted, size: 18),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Department filter
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.dividerColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: vm.selectedDepartment,
                dropdownColor: AppTheme.surfaceCard,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 13),
                hint: const Text('All Departments',
                    style: TextStyle(
                        color: AppTheme.textMuted, fontSize: 13)),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All Departments'),
                  ),
                  ...vm.departments.map(
                    (d) => DropdownMenuItem<String?>(
                      value: d,
                      child: Text(d),
                    ),
                  ),
                ],
                onChanged: vm.setDepartment,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.textMuted, size: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Refresh
          IconButton(
            onPressed: vm.refresh,
            icon: const Icon(Icons.refresh_rounded,
                color: AppTheme.textSecondary, size: 20),
            tooltip: 'Refresh',
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.surfaceCard,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: AppTheme.dividerColor)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, TeacherViewModel vm) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: vm.teachers.length,
      separatorBuilder: (_, s) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) => _TeacherCard(
        teacher: vm.teachers[i],
        onDelete: () => _confirmDelete(ctx, vm, vm.teachers[i]),
        onEdit: () => Navigator.of(ctx).push(
          MaterialPageRoute(
            builder: (_) =>
                AddEditTeacherView(viewModel: vm, teacher: vm.teachers[i]),
          ),
        ),
        onTap: () => Navigator.of(ctx).push(
          MaterialPageRoute(
            builder: (_) =>
                TeacherDetailView(teacher: vm.teachers[i]),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.accentIndigo.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_search_rounded,
                color: AppTheme.accentIndigo, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'No teachers found',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try changing your search or filter.',
            style:
                TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, TeacherViewModel vm, TeacherModel t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Teacher',
            style: TextStyle(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to delete "${t.name}"? This cannot be undone.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              vm.deleteTeacher(t.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentRed),
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

/// ─── Teacher Card ───
class _TeacherCard extends StatefulWidget {
  final TeacherModel teacher;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TeacherCard({
    required this.teacher,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_TeacherCard> createState() => _TeacherCardState();
}

class _TeacherCardState extends State<_TeacherCard> {
  bool _hovering = false;

  Color get _statusColor => switch (widget.teacher.status) {
        'active' => AppTheme.accentGreen,
        'on_leave' => AppTheme.accentOrange,
        _ => AppTheme.accentRed,
      };

  String get _statusLabel => switch (widget.teacher.status) {
        'active' => 'Active',
        'on_leave' => 'On Leave',
        _ => 'Inactive',
      };

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _hovering
                ? AppTheme.surfaceCardHover
                : AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovering
                  ? AppTheme.accentIndigo.withValues(alpha: 0.2)
                  : AppTheme.dividerColor,
            ),
            boxShadow: _hovering
                ? [
                    BoxShadow(
                      color: AppTheme.accentIndigo.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              // Avatar
              if (MediaQuery.of(context).size.width > 400) ...[
                _TeacherAvatar(name: widget.teacher.name),
                const SizedBox(width: 16),
              ],
              // Name & Dept
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.teacher.name,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.teacher.designation,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Dept
              if (MediaQuery.of(context).size.width > 500)
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Department',
                          style: TextStyle(
                              color: AppTheme.textMuted, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text(
                        widget.teacher.department,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                            fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              // Courses & Status
              if (MediaQuery.of(context).size.width > 600) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Courses',
                          style: TextStyle(
                              color: AppTheme.textMuted, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text(
                        widget.teacher.coursesAssigned.toString(),
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _statusColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                            color: _statusColor,
                            shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _statusLabel,
                        style: TextStyle(
                            color: _statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],
              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: widget.onTap,
                    icon: const Icon(Icons.visibility_rounded,
                        size: 18, color: AppTheme.accentIndigo),
                    tooltip: 'View Details',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  IconButton(
                    onPressed: widget.onEdit,
                    icon: const Icon(Icons.edit_rounded,
                        size: 18, color: AppTheme.accentCyan),
                    tooltip: 'Edit',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  IconButton(
                    onPressed: widget.onDelete,
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 18, color: AppTheme.accentRed),
                    tooltip: 'Delete',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeacherAvatar extends StatelessWidget {
  final String name;
  const _TeacherAvatar({required this.name});

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
    final color = _avatarColor(name);
    final initials = name.trim().split(' ').take(2).map((w) => w[0]).join();
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15),
        ),
      ),
    );
  }
}

/// Filter chip  
class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected
                  ? color.withValues(alpha: 0.2)
                  : AppTheme.dividerColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : AppTheme.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

