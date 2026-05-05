import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../admin/core/app_theme.dart';
import '../viewmodels/teacher_portal_viewmodel.dart';
import 'teacher_student_detail_view.dart';
import 'teacher_notifications_view.dart';

class TeacherHomeView extends StatefulWidget {
  const TeacherHomeView({super.key});

  @override
  State<TeacherHomeView> createState() => _TeacherHomeViewState();
}

class _TeacherHomeViewState extends State<TeacherHomeView> {
  final _searchCtrl = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<TeacherPortalViewModel>();
      vm.fetchStudents();
      vm.fetchNotifications();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TeacherPortalViewModel>();
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.co_present_rounded, color: Color(0xFF10B981)),
            const SizedBox(width: 12),
            const Text(
              'Teacher Portal',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.textSecondary),
            onPressed: () {
              setState(() {
                _selectedIndex = 1;
              });
            },
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.textSecondary),
            onPressed: () {
              vm.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
            tooltip: 'Logout',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile)
            Container(
              width: 250,
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.1),
                          child: const Icon(Icons.person, size: 40, color: Color(0xFF10B981)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          vm.currentTeacher?.name ?? 'Teacher',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vm.currentTeacher?.email ?? '',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.people_alt, color: Color(0xFF10B981)),
                    title: const Text('My Students', style: TextStyle(fontWeight: FontWeight.bold)),
                    selected: _selectedIndex == 0,
                    selectedTileColor: const Color(0xFF10B981).withValues(alpha: 0.1),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications, color: Color(0xFF10B981)),
                    title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
                    selected: _selectedIndex == 1,
                    selectedTileColor: const Color(0xFF10B981).withValues(alpha: 0.1),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: _selectedIndex == 0 ? _buildStudentsTab(vm, isMobile) : const TeacherNotificationsView(),
          ),
        ],
      ),
      bottomNavigationBar: isMobile
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
              ),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (i) => setState(() => _selectedIndex = i),
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: const Color(0xFF10B981),
                unselectedItemColor: AppTheme.textMuted,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                unselectedLabelStyle: const TextStyle(fontSize: 12),
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: 'Students'),
                  BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildStudentsTab(TeacherPortalViewModel vm, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Students Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 16),
          
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: vm.searchStudents,
              decoration: InputDecoration(
                hintText: 'Search by name, ID or course...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Student List
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
                : vm.errorMessage != null
                    ? Center(child: Text(vm.errorMessage!, style: const TextStyle(color: Colors.red)))
                    : vm.filteredStudents.isEmpty
                        ? const Center(child: Text('No students found.'))
                        : isMobile ? _buildStudentList(vm) : _buildStudentGrid(vm),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList(TeacherPortalViewModel vm) {
    return ListView.builder(
      itemCount: vm.filteredStudents.length,
      itemBuilder: (context, index) {
        final student = vm.filteredStudents[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.1),
              child: const Icon(Icons.person_outline, color: Color(0xFF10B981)),
            ),
            title: Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${student.studentId} • ${student.academic.course} (Sem ${student.academic.semester})'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TeacherStudentDetailView(student: student),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStudentGrid(TeacherPortalViewModel vm) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      itemCount: vm.filteredStudents.length,
      itemBuilder: (context, index) {
        final student = vm.filteredStudents[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TeacherStudentDetailView(student: student),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
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
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.1),
                  child: const Icon(Icons.person_outline, color: Color(0xFF10B981)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        student.fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        student.studentId,
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${student.academic.course} S${student.academic.semester}',
                          style: const TextStyle(color: Color(0xFF047857), fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
