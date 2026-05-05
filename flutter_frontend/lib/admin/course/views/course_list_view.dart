import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/course_viewmodel.dart';
import '../models/course_model.dart';
import '../../core/app_theme.dart';
import 'add_edit_course_view.dart';

class CourseListView extends StatelessWidget {
  const CourseListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CourseViewModel(),
      child: const _CourseListContent(),
    );
  }
}

class _CourseListContent extends StatelessWidget {
  const _CourseListContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<CourseViewModel>(
      builder: (ctx, vm, _) {
        return Column(
          children: [
            _buildToolbar(ctx, vm),
            _buildSearchBar(vm),
            Expanded(
              child: vm.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.accentIndigo))
                  : vm.errorMessage != null
                      ? _buildError(ctx, vm)
                      : vm.courses.isEmpty
                          ? _buildEmpty(vm.searchQuery.isNotEmpty)
                          : _buildList(ctx, vm),
            ),
          ],
        );
      },
    );
  }

  // ── Toolbar ────────────────────────────────────────────────────────────────
  Widget _buildToolbar(BuildContext context, CourseViewModel vm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Courses (${vm.courses.length})',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddEditCourseView(viewModel: vm),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Course'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentIndigo,
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

  // ── Search bar ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar(CourseViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
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
            hintText: 'Search by title or code…',
            hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            border: InputBorder.none,
            prefixIcon:
                Icon(Icons.search_rounded, size: 18, color: AppTheme.textMuted),
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  // ── List ───────────────────────────────────────────────────────────────────
  Widget _buildList(BuildContext context, CourseViewModel vm) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
      itemCount: vm.courses.length,
      separatorBuilder: (_, s) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final course = vm.courses[i];
        return _CourseCard(
          course: course,
          onEdit: () => Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) =>
                  AddEditCourseView(viewModel: vm, course: course),
            ),
          ),
          onDelete: () => _confirmDelete(ctx, vm, course),
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
            isFiltered ? Icons.search_off_rounded : Icons.book_outlined,
            size: 56,
            color: AppTheme.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            isFiltered ? 'No courses match your search' : 'No courses yet',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
          ),
          const SizedBox(height: 6),
          if (!isFiltered)
            const Text(
              'Tap "Add Course" to get started',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
        ],
      ),
    );
  }

  // ── Error state ────────────────────────────────────────────────────────────
  Widget _buildError(BuildContext context, CourseViewModel vm) {
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
                backgroundColor: AppTheme.accentIndigo),
          ),
        ],
      ),
    );
  }

  // ── Delete confirm ─────────────────────────────────────────────────────────
  void _confirmDelete(
      BuildContext context, CourseViewModel vm, Course course) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Delete "${course.title}"?\n\nThis cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              vm.deleteCourse(course.id!);
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
// Course Card
// ─────────────────────────────────────────────────────────────────────────────
class _CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CourseCard({
    required this.course,
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
          // Avatar / icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.accentIndigo.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.book_rounded,
                color: AppTheme.accentIndigo, size: 22),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _chip(
                      label: course.code,
                      color: AppTheme.accentIndigo,
                    ),
                    const SizedBox(width: 8),
                    _chip(
                      label: course.duration,
                      color: AppTheme.accentOrange,
                    ),
                  ],
                ),
                if (course.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    course.description,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
      ),
    );
  }
}
