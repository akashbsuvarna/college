import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/student_viewmodel.dart';
import '../models/student_model.dart';
import '../../core/app_theme.dart';
import '../../course/viewmodels/course_viewmodel.dart';
import '../../course/models/course_model.dart';
import 'student_detail_view.dart';
import 'add_edit_student_view.dart';

class StudentListView extends StatelessWidget {
  const StudentListView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _StudentListContent();
  }
}

class _StudentListContent extends StatelessWidget {
  const _StudentListContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentViewModel>(
      builder: (ctx, vm, _) {
        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              _buildToolbar(ctx, vm),
              TabBar(
                labelColor: AppTheme.accentIndigo,
                unselectedLabelColor: AppTheme.textSecondary,
                indicatorColor: AppTheme.accentIndigo,
                tabs: [
                  Tab(text: 'Active Students (${vm.students.length})'),
                  Tab(text: 'Pending Requests (${vm.pendingStudents.length})'),
                ],
              ),
              Expanded(
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : vm.errorMessage != null
                        ? _buildError(vm.errorMessage!)
                        : TabBarView(
                            children: [
                              // Active Students Tab
                              Column(
                                children: [
                                  const SizedBox(height: 12),
                                  _buildSearchBar(ctx, vm),
                                  Expanded(
                                    child: vm.students.isEmpty
                                        ? _buildEmpty()
                                        : _buildList(ctx, vm),
                                  ),
                                ],
                              ),
                              // Pending Requests Tab
                              vm.pendingStudents.isEmpty
                                  ? const Center(child: Text("No pending requests"))
                                  : _buildPendingList(ctx, vm),
                            ],
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔹 TOOLBAR
  Widget _buildToolbar(BuildContext context, StudentViewModel vm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Students (${vm.students.length})',
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
                builder: (_) => AddEditStudentView(viewModel: vm),
              ),
            ).then((_) => vm.refresh()),
            icon: const Icon(Icons.person_add_rounded, size: 18),
            label: const Text('Add Student'),
          ),
        ],
      ),
    );
  }

  // 🔹 SEARCH BAR
  Widget _buildSearchBar(BuildContext context, StudentViewModel vm) {
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
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Search by name, email or phone...',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
          ),
        ),
      ),
    );
  }

  // 🔹 LIST
  Widget _buildList(BuildContext context, StudentViewModel vm) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: vm.students.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final student = vm.students[i];
        return _StudentCard(
          student: student,
          onTap: () => Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => StudentDetailView(student: student),
            ),
          ),
          onEdit: () => Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) =>
                  AddEditStudentView(viewModel: vm, student: student),
            ),
          ).then((_) => vm.refresh()),
          onDelete: () => _confirmDelete(ctx, vm, student),
        );
      },
    );
  }

  // 🔹 EMPTY
  Widget _buildEmpty() {
    return const Center(
      child: Text("No students found"),
    );
  }

  // 🔹 ERROR
  Widget _buildError(String msg) {
    return Center(
      child: Text(msg, style: const TextStyle(color: Colors.red)),
    );
  }

  // 🔹 DELETE CONFIRM
  void _confirmDelete(
      BuildContext context, StudentViewModel vm, StudentModel s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Student"),
        content: Text('Delete "${s.fullName}" ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final success = await vm.deleteStudent(s.id);
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(vm.errorMessage ?? 'Delete failed'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  // 🔹 PENDING LIST
  Widget _buildPendingList(BuildContext context, StudentViewModel vm) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: vm.pendingStudents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final student = vm.pendingStudents[i];
        return _PendingStudentCard(
          student: student,
          onAccept: () => _confirmAccept(ctx, vm, student),
          onReject: () => _confirmReject(ctx, vm, student),
        );
      },
    );
  }

  // 🔹 ACCEPT CONFIRM (PROMPT FOR COURSE & SEMESTER)
  void _confirmAccept(BuildContext context, StudentViewModel vm, StudentModel s) {
    showDialog(
      context: context,
      builder: (_) => _AcceptStudentDialog(student: s, vm: vm),
    );
  }

  // 🔹 REJECT CONFIRM
  void _confirmReject(BuildContext context, StudentViewModel vm, StudentModel s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reject Student"),
        content: Text('Are you sure you want to reject the registration for "${s.fullName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final success = await vm.rejectStudent(s.id);
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(vm.errorMessage ?? 'Reject failed'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 🔥 PENDING STUDENT CARD
// ─────────────────────────────────────────────
class _PendingStudentCard extends StatelessWidget {
  final StudentModel student;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _PendingStudentCard({
    required this.student,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300, width: 1.5),
      ),
      child: Row(
        children: [
          _StudentAvatar(name: student.fullName),
          const SizedBox(width: 12),

          // INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Text('Requested: ${student.academic.course} • Sem ${student.academic.semester}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),

          // CONTACT
          if (MediaQuery.of(context).size.width > 500)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.email, style: const TextStyle(fontSize: 12)),
                  Text(student.phone, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),

          // ACTIONS
          Row(
            children: [
              IconButton(
                onPressed: onAccept,
                icon: const Icon(Icons.check_circle_rounded, color: AppTheme.accentGreen),
                tooltip: 'Accept',
              ),
              IconButton(
                onPressed: onReject,
                icon: const Icon(Icons.cancel_rounded, color: AppTheme.accentRed),
                tooltip: 'Reject',
              ),
            ],
          )
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 🔥 STUDENT CARD
// ─────────────────────────────────────────────
class _StudentCard extends StatelessWidget {
  final StudentModel student;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _StudentCard({
    required this.student,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          children: [
            _StudentAvatar(name: student.fullName),
            const SizedBox(width: 12),

            // INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.fullName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Text(
                    '${student.academic.course} • Sem ${student.academic.semester}',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),

            // CONTACT
            if (MediaQuery.of(context).size.width > 500)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.email,
                        style: const TextStyle(fontSize: 12)),
                    Text(student.phone,
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),

            // ACTIONS
            Row(
              children: [
                IconButton(
                  onPressed: onTap,
                  icon: const Icon(Icons.visibility),
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 🔹 AVATAR
// ─────────────────────────────────────────────
class _StudentAvatar extends StatelessWidget {
  final String name;

  const _StudentAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials =
        name.trim().split(' ').take(2).map((e) => e[0]).join();

    return CircleAvatar(
      radius: 22,
      child: Text(initials.toUpperCase()),
    );
  }
}

// ─────────────────────────────────────────────
// 🔥 ACCEPT STUDENT DIALOG
// ─────────────────────────────────────────────
class _AcceptStudentDialog extends StatefulWidget {
  final StudentModel student;
  final StudentViewModel vm;

  const _AcceptStudentDialog({required this.student, required this.vm});

  @override
  State<_AcceptStudentDialog> createState() => _AcceptStudentDialogState();
}

class _AcceptStudentDialogState extends State<_AcceptStudentDialog> {
  String? _selectedCourseTitle;
  int? _selectedSemester;

  @override
  void initState() {
    super.initState();
    _selectedCourseTitle = widget.student.academic.course;
    _selectedSemester = widget.student.academic.semester;
  }

  int _getSemestersForCourse(String? title, List<Course> allCourses) {
    if (title == null) return 0;
    final course = allCourses.firstWhere((c) => c.title == title,
        orElse: () => Course(title: '', description: '', duration: '0', code: ''));
    
    final durationStr = course.duration.toLowerCase();
    int years = 0;
    int semesters = 0;

    if (durationStr.contains('year')) {
      years = int.tryParse(durationStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return years * 2;
    } else if (durationStr.contains('sem')) {
      semesters = int.tryParse(durationStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return semesters;
    } else {
      return int.tryParse(durationStr) ?? 8;
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseVm = context.watch<CourseViewModel>();
    final courses = courseVm.allCourses;
    
    int maxSemesters = _getSemestersForCourse(_selectedCourseTitle, courses);
    List<int> semesterOptions = List.generate(maxSemesters, (i) => i + 1);

    // Validate initials against loaded courses
    if (courses.isNotEmpty && _selectedCourseTitle != null && _selectedCourseTitle!.isNotEmpty) {
       final exists = courses.any((c) => c.title == _selectedCourseTitle);
       if (!exists) _selectedCourseTitle = null;
    }

    return AlertDialog(
      title: const Text("Accept Student"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Assign "${widget.student.fullName}" to a Class:'),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCourseTitle,
            decoration: const InputDecoration(labelText: 'Course', border: OutlineInputBorder()),
            items: courses.map((c) => DropdownMenuItem(value: c.title, child: Text(c.title))).toList(),
            onChanged: (v) {
              setState(() {
                _selectedCourseTitle = v;
                int newMax = _getSemestersForCourse(v, courses);
                if (_selectedSemester != null && _selectedSemester! > newMax) {
                  _selectedSemester = null;
                }
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _selectedSemester,
            decoration: const InputDecoration(labelText: 'Semester', border: OutlineInputBorder()),
            items: semesterOptions.map((s) => DropdownMenuItem(value: s, child: Text(s.toString()))).toList(),
            onChanged: (v) {
              setState(() {
                _selectedSemester = v;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGreen),
          onPressed: () async {
            if (_selectedCourseTitle == null || _selectedSemester == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select Course and Semester'), backgroundColor: Colors.red),
              );
              return;
            }
            
            Navigator.pop(context);
            final success = await widget.vm.acceptStudent(widget.student.id, _selectedCourseTitle!, _selectedSemester!);
            if (!success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(widget.vm.errorMessage ?? 'Accept failed'), backgroundColor: Colors.red),
              );
            }
          },
          child: const Text('Accept', style: TextStyle(color: Colors.white)),
        )
      ],
    );
  }
}