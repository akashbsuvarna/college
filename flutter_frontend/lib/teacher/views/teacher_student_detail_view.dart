import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../admin/core/app_theme.dart';
import '../../admin/student/models/student_model.dart';
import '../viewmodels/teacher_portal_viewmodel.dart';

class TeacherStudentDetailView extends StatefulWidget {
  final StudentModel student;

  const TeacherStudentDetailView({super.key, required this.student});

  @override
  State<TeacherStudentDetailView> createState() => _TeacherStudentDetailViewState();
}

class _TeacherStudentDetailViewState extends State<TeacherStudentDetailView> {
  bool _isLoadingAttendance = true;
  List<dynamic> _attendanceRecords = [];
  String? _attendanceError;

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  Future<void> _fetchAttendance() async {
    final vm = context.read<TeacherPortalViewModel>();
    try {
      final records = await vm.fetchStudentAttendance(widget.student.studentId);
      if (mounted) {
        setState(() {
          _attendanceRecords = records;
          _isLoadingAttendance = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _attendanceError = e.toString();
          _isLoadingAttendance = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Student Detail',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 24),
                DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TabBar(
                          labelColor: const Color(0xFF10B981),
                          unselectedLabelColor: AppTheme.textSecondary,
                          indicatorColor: const Color(0xFF10B981),
                          tabs: const [
                            Tab(text: 'Profile Information', icon: Icon(Icons.person)),
                            Tab(text: 'Attendance Records', icon: Icon(Icons.fact_check)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 600, // Fixed height for tabs content
                        child: TabBarView(
                          children: [
                            _buildProfileTab(),
                            _buildAttendanceTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.1),
            child: const Icon(Icons.person, size: 40, color: Color(0xFF10B981)),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.student.fullName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _infoBadge(Icons.badge, widget.student.studentId),
                    const SizedBox(width: 12),
                    _infoBadge(Icons.menu_book, '${widget.student.academic.course} - Sem ${widget.student.academic.semester}'),
                    const SizedBox(width: 12),
                    _statusBadge(widget.student.status),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'active':
        bgColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green.shade700;
        break;
      case 'pending':
        bgColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange.shade700;
        break;
      default:
        bgColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildInfoSection('Contact Information', [
            _buildInfoRow('Email', widget.student.email),
            _buildInfoRow('Phone', widget.student.phone),
            _buildInfoRow('Date of Birth', widget.student.dob),
            _buildInfoRow('Address', widget.student.permanentAddress),
          ]),
          const SizedBox(height: 16),
          _buildInfoSection('Parent Information', [
            _buildInfoRow('Father\'s Name', widget.student.father.name),
            _buildInfoRow('Father\'s Contact', widget.student.father.mobile),
            _buildInfoRow('Mother\'s Name', widget.student.mother.name),
            _buildInfoRow('Mother\'s Contact', widget.student.mother.mobile),
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const Divider(height: 32),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab() {
    if (_isLoadingAttendance) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
    }
    
    if (_attendanceError != null) {
      return Center(child: Text('Error: $_attendanceError', style: const TextStyle(color: Colors.red)));
    }
    
    if (_attendanceRecords.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'No attendance records found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    // Calculate stats
    final totalClasses = _attendanceRecords.length;
    final presentClasses = _attendanceRecords.where((r) => r['status'] == 'present').length;
    final percentage = totalClasses > 0 ? (presentClasses / totalClasses * 100).toStringAsFixed(1) : '0.0';

    return Column(
      children: [
        // Stats Summary
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total Classes', totalClasses.toString(), Icons.class_),
              _buildStatItem('Present', presentClasses.toString(), Icons.check_circle, Colors.green),
              _buildStatItem('Absent', (totalClasses - presentClasses).toString(), Icons.cancel, Colors.red),
              _buildStatItem('Percentage', '$percentage%', Icons.pie_chart, 
                  double.parse(percentage) >= 75 ? Colors.green : Colors.orange),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Detailed List
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _attendanceRecords.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final record = _attendanceRecords[index];
                final date = DateTime.parse(record['date']).toLocal();
                final formattedDate = '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
                final isPresent = record['status'] == 'present';
                
                String subjectName = 'Unknown Subject';
                if (record['subjectId'] != null) {
                  subjectName = record['subjectId']['name'] ?? record['subjectId'];
                }
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isPresent ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                    child: Icon(
                      isPresent ? Icons.check : Icons.close,
                      color: isPresent ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(subjectName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(formattedDate),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isPresent ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isPresent ? 'PRESENT' : 'ABSENT',
                      style: TextStyle(
                        color: isPresent ? Colors.green.shade700 : Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, [Color? color]) {
    return Column(
      children: [
        Icon(icon, color: color ?? AppTheme.textSecondary, size: 28),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color ?? AppTheme.textPrimary)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
      ],
    );
  }
}
