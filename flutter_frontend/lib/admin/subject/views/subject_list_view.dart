import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/subject_viewmodel.dart';
import '../models/subject_model.dart';
import '../../course/viewmodels/course_viewmodel.dart';
import '../../course/models/course_model.dart';
import '../../core/app_theme.dart';
import 'add_edit_subject_view.dart';

class SubjectListView extends StatelessWidget {
  const SubjectListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SubjectViewModel(),
      child: const _SubjectListContent(),
    );
  }
}

class _SubjectListContent extends StatelessWidget {
  const _SubjectListContent();

  @override
  Widget build(BuildContext context) {
    return Consumer2<SubjectViewModel, CourseViewModel>(
      builder: (ctx, vm, courseVm, _) {
        return Column(
          children: [
            _buildToolbar(ctx, vm, courseVm),
            _buildFiltersRow(ctx, vm, courseVm),
            _buildSearchBar(vm),
            Expanded(
              child: vm.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.accentCyan))
                  : vm.errorMessage != null
                      ? _buildError(ctx, vm)
                      : vm.subjects.isEmpty
                          ? _buildEmpty(
                              vm.searchQuery.isNotEmpty ||
                                  vm.selectedCourseId != null)
                          : _buildList(ctx, vm, courseVm.allCourses),
            ),
          ],
        );
      },
    );
  }

  // ── Toolbar ────────────────────────────────────────────────────────────────
  Widget _buildToolbar(
      BuildContext context, SubjectViewModel vm, CourseViewModel courseVm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Subjects (${vm.subjects.length})',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: courseVm.allCourses.isEmpty
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddEditSubjectView(
                          viewModel: vm,
                          courses: courseVm.allCourses,
                        ),
                      ),
                    ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Subject'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentCyan,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter chips (by course) ───────────────────────────────────────────────
  Widget _buildFiltersRow(
      BuildContext context, SubjectViewModel vm, CourseViewModel courseVm) {
    final courses = courseVm.allCourses;
    if (courses.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          // "All" chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: vm.selectedCourseId == null,
              onSelected: (_) => vm.setFilterCourse(null),
              selectedColor: AppTheme.accentCyan.withValues(alpha: 0.15),
              checkmarkColor: AppTheme.accentCyan,
              labelStyle: TextStyle(
                color: vm.selectedCourseId == null
                    ? AppTheme.accentCyan
                    : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: vm.selectedCourseId == null
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
              side: BorderSide(
                color: vm.selectedCourseId == null
                    ? AppTheme.accentCyan
                    : AppTheme.dividerColor,
              ),
            ),
          ),
          // per-course chips
          ...courses.map(
            (c) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(c.code),
                selected: vm.selectedCourseId == c.id,
                onSelected: (_) => vm.setFilterCourse(
                    vm.selectedCourseId == c.id ? null : c.id),
                selectedColor: AppTheme.accentCyan.withValues(alpha: 0.15),
                checkmarkColor: AppTheme.accentCyan,
                labelStyle: TextStyle(
                  color: vm.selectedCourseId == c.id
                      ? AppTheme.accentCyan
                      : AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: vm.selectedCourseId == c.id
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
                side: BorderSide(
                  color: vm.selectedCourseId == c.id
                      ? AppTheme.accentCyan
                      : AppTheme.dividerColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search bar ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar(SubjectViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: TextField(
          onChanged: vm.setSearch,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          decoration: const InputDecoration(
            hintText: 'Search by name or code…',
            hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search_rounded,
                size: 18, color: AppTheme.textMuted),
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  // ── List ───────────────────────────────────────────────────────────────────
  Widget _buildList(
      BuildContext context, SubjectViewModel vm, List<Course> courses) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
      itemCount: vm.subjects.length,
      separatorBuilder: (_, s) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final subject = vm.subjects[i];
        return _SubjectCard(
          subject: subject,
          onEdit: () => Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => AddEditSubjectView(
                viewModel: vm,
                courses: courses,
                subject: subject,
              ),
            ),
          ),
          onDelete: () => _confirmDelete(ctx, vm, subject),
        );
      },
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────
  Widget _buildEmpty(bool isFiltered) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFiltered
                ? Icons.search_off_rounded
                : Icons.subject_outlined,
            size: 56,
            color: AppTheme.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            isFiltered
                ? 'No subjects match your filter'
                : 'No subjects yet',
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
          ),
          const SizedBox(height: 6),
          if (!isFiltered)
            const Text(
              'Tap "Add Subject" to get started',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
        ],
      ),
    );
  }

  // ── Error state ────────────────────────────────────────────────────────────
  Widget _buildError(BuildContext context, SubjectViewModel vm) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 48, color: AppTheme.accentRed),
          const SizedBox(height: 12),
          Text(
            vm.errorMessage ?? 'Something went wrong',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: vm.refresh,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCyan),
          ),
        ],
      ),
    );
  }

  // ── Delete confirm ─────────────────────────────────────────────────────────
  void _confirmDelete(
      BuildContext context, SubjectViewModel vm, Subject subject) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Subject'),
        content:
            Text('Delete "${subject.name}"?\n\nThis cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              vm.deleteSubject(subject.id!);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentRed,
                foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Subject Card
// ─────────────────────────────────────────────────────────────────────────────
class _SubjectCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SubjectCard({
    required this.subject,
    required this.onEdit,
    required this.onDelete,
  });

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
          // Icon avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.accentCyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.subject_rounded,
                color: AppTheme.accentCyan, size: 22),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _chip(label: subject.code, color: AppTheme.accentCyan),
                    const SizedBox(width: 8),
                    _chip(
                        label: '${subject.credits} Credits',
                        color: AppTheme.accentPurple),
                    if (subject.courseName != null) ...[
                      const SizedBox(width: 8),
                      _chip(
                          label: subject.courseName!,
                          color: AppTheme.accentIndigo),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded,
                    color: AppTheme.accentIndigo, size: 20),
                tooltip: 'Edit',
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_rounded,
                    color: AppTheme.accentRed, size: 20),
                tooltip: 'Delete',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
