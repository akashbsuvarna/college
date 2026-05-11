import 'package:flutter/material.dart';
import '../../admin/core/app_theme.dart';
import '../../admin/student/models/student_model.dart';
import '../services/student_service.dart';
import 'package:provider/provider.dart';
import '../../admin/course/viewmodels/course_viewmodel.dart';
import '../../admin/course/models/course_model.dart';

class StudentRegistrationView extends StatefulWidget {
  const StudentRegistrationView({super.key});

  @override
  State<StudentRegistrationView> createState() => _StudentRegistrationViewState();
}

class _StudentRegistrationViewState extends State<StudentRegistrationView> {
  final _formKey = GlobalKey<FormState>();
  final _studentService = StudentService();

  // Personal
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _dobCtrl;
  late TextEditingController _casteCtrl;
  late TextEditingController _addressCtrl;

  // Parent
  late TextEditingController _fatherNameCtrl;
  late TextEditingController _fatherOccCtrl;
  late TextEditingController _fatherPhoneCtrl;

  late TextEditingController _motherNameCtrl;
  late TextEditingController _motherOccCtrl;
  late TextEditingController _motherPhoneCtrl;

  // Academic
  late TextEditingController _courseCtrl;
  late TextEditingController _semesterCtrl;

  // SSLC
  late TextEditingController _sslcSchoolCtrl;
  late TextEditingController _sslcPercentCtrl;
  late TextEditingController _sslcBoardCtrl;

  // PUC
  late TextEditingController _pucCollegeCtrl;
  late TextEditingController _pucPercentCtrl;
  late TextEditingController _pucCourseCtrl;

  String? _selectedCourseTitle;
  int? _selectedSemester;
  BloodGroup _bloodGroup = BloodGroup.Opos;
  bool _saving = false;

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
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _dobCtrl = TextEditingController();
    _casteCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _fatherNameCtrl = TextEditingController();
    _fatherOccCtrl = TextEditingController();
    _fatherPhoneCtrl = TextEditingController();
    _motherNameCtrl = TextEditingController();
    _motherOccCtrl = TextEditingController();
    _motherPhoneCtrl = TextEditingController();
    _courseCtrl = TextEditingController();
    _semesterCtrl = TextEditingController();
    _sslcSchoolCtrl = TextEditingController();
    _sslcPercentCtrl = TextEditingController();
    _sslcBoardCtrl = TextEditingController();
    _pucCollegeCtrl = TextEditingController();
    _pucPercentCtrl = TextEditingController();
    _pucCourseCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    _casteCtrl.dispose();
    _addressCtrl.dispose();
    _fatherNameCtrl.dispose();
    _fatherOccCtrl.dispose();
    _fatherPhoneCtrl.dispose();
    _motherNameCtrl.dispose();
    _motherOccCtrl.dispose();
    _motherPhoneCtrl.dispose();
    _courseCtrl.dispose();
    _semesterCtrl.dispose();
    _sslcSchoolCtrl.dispose();
    _sslcPercentCtrl.dispose();
    _sslcBoardCtrl.dispose();
    _pucCollegeCtrl.dispose();
    _pucPercentCtrl.dispose();
    _pucCourseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0EA5E9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Student Registration',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: Center(
        child: Container(
          width: isMobile ? size.width : size.width * 0.8,
          margin: EdgeInsets.all(isMobile ? 0 : 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isMobile ? 0 : 24),
            boxShadow: [
              if (!isMobile)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 24 : 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Complete Your Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please fill in all details accurately. Your registration will be sent to the administration for approval.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  
                  if (isMobile) ...[
                    _buildPersonalSection(),
                    const SizedBox(height: 24),
                    _buildParentSection(),
                    const SizedBox(height: 24),
                    _buildAcademicSection(),
                    const SizedBox(height: 24),
                    _buildEducationSection(),
                  ] else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              _buildPersonalSection(),
                              const SizedBox(height: 24),
                              _buildParentSection(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          child: Column(
                            children: [
                              _buildAcademicSection(),
                              const SizedBox(height: 24),
                              _buildEducationSection(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0EA5E9),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(
                              'SUBMIT REGISTRATION',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalSection() {
    return _FormSection(
      title: 'Personal Information',
      icon: Icons.person_rounded,
      color: const Color(0xFF0EA5E9),
      children: [
        _FormField(ctrl: _nameCtrl, label: 'Full Name', hint: 'Firstname Lastname', icon: Icons.person_outline),
        const SizedBox(height: 16),
        _FormField(ctrl: _emailCtrl, label: 'Email', hint: 'student@example.com', icon: Icons.email_outlined, keyboard: TextInputType.emailAddress),
        const SizedBox(height: 16),
        _FormField(ctrl: _phoneCtrl, label: 'Phone', hint: '+91 9000000000', icon: Icons.phone_outlined, keyboard: TextInputType.phone),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() {
                _dobCtrl.text = "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
              });
            }
          },
          child: AbsorbPointer(
            child: _FormField(ctrl: _dobCtrl, label: 'Date of Birth', hint: 'Select Date', icon: Icons.calendar_today_outlined),
          ),
        ),
        const SizedBox(height: 16),
        _FormField(ctrl: _addressCtrl, label: 'Permanent Address', hint: 'Home address...', icon: Icons.home_outlined, maxLines: 2),
        const SizedBox(height: 16),
        _DropdownField(
          label: 'Blood Group',
          value: _bloodGroup.name,
          items: BloodGroup.values.map((e) => e.name).toList(),
          icon: Icons.bloodtype_outlined,
          onChanged: (v) {
            setState(() {
              _bloodGroup = BloodGroup.values.firstWhere((e) => e.name == v);
            });
          },
        ),
        const SizedBox(height: 16),
        _FormField(ctrl: _casteCtrl, label: 'Category / Caste', hint: 'General / OBC / SC / ST', icon: Icons.group_outlined),
      ],
    );
  }

  Widget _buildParentSection() {
    return _FormSection(
      title: 'Parent Details',
      icon: Icons.family_restroom_rounded,
      color: const Color(0xFF6366F1),
      children: [
        const Text('Father Information', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        _FormField(ctrl: _fatherNameCtrl, label: 'Name', hint: 'Father Name', icon: Icons.person_outline),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _FormField(ctrl: _fatherOccCtrl, label: 'Occupation', hint: 'Job', icon: Icons.work_outline)),
            const SizedBox(width: 12),
            Expanded(child: _FormField(ctrl: _fatherPhoneCtrl, label: 'Mobile', hint: 'Phone', icon: Icons.phone_outlined, keyboard: TextInputType.phone)),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(color: AppTheme.dividerColor),
        const SizedBox(height: 16),
        const Text('Mother Information', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        _FormField(ctrl: _motherNameCtrl, label: 'Name', hint: 'Mother Name', icon: Icons.person_outline),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _FormField(ctrl: _motherOccCtrl, label: 'Occupation', hint: 'Job', icon: Icons.work_outline)),
            const SizedBox(width: 12),
            Expanded(child: _FormField(ctrl: _motherPhoneCtrl, label: 'Mobile', hint: 'Phone', icon: Icons.phone_outlined, keyboard: TextInputType.phone)),
          ],
        ),
      ],
    );
  }

  Widget _buildAcademicSection() {
    final courseVm = context.watch<CourseViewModel>();
    final courses = courseVm.allCourses;
    
    int maxSemesters = _getSemestersForCourse(_selectedCourseTitle, courses);
    List<int> semesterOptions = List.generate(maxSemesters, (i) => i + 1);

    return _FormSection(
      title: 'Requested Academic Details',
      icon: Icons.school_rounded,
      color: const Color(0xFF10B981),
      children: [
        _DropdownField(
          label: 'Desired Course',
          value: _selectedCourseTitle,
          items: courses.map((c) => c.title).toList(),
          icon: Icons.menu_book_rounded,
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
        _DropdownField(
          label: 'Semester',
          value: _selectedSemester?.toString(),
          items: semesterOptions.map((s) => s.toString()).toList(),
          icon: Icons.calendar_month_rounded,
          onChanged: (v) {
            setState(() {
              _selectedSemester = int.tryParse(v ?? '');
            });
          },
        ),
      ],
    );
  }

  Widget _buildEducationSection() {
    return _FormSection(
      title: 'Previous Education',
      icon: Icons.history_edu_rounded,
      color: const Color(0xFFF59E0B),
      children: [
        const Text('SSLC / 10th', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        _FormField(ctrl: _sslcSchoolCtrl, label: 'School', hint: 'School Name', icon: Icons.account_balance_outlined),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _FormField(ctrl: _sslcBoardCtrl, label: 'Board', hint: 'State / CBSE', icon: Icons.assignment_outlined)),
            const SizedBox(width: 12),
            Expanded(child: _FormField(ctrl: _sslcPercentCtrl, label: 'Percentage', hint: '90.5', icon: Icons.percent_rounded, keyboard: TextInputType.number)),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(color: AppTheme.dividerColor),
        const SizedBox(height: 16),
        const Text('PUC / 12th', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        _FormField(ctrl: _pucCollegeCtrl, label: 'College', hint: 'College Name', icon: Icons.account_balance_rounded),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _FormField(ctrl: _pucCourseCtrl, label: 'Course', hint: 'Science / Arts', icon: Icons.science_outlined)),
            const SizedBox(width: 12),
            Expanded(child: _FormField(ctrl: _pucPercentCtrl, label: 'Percentage', hint: '85.0', icon: Icons.percent_rounded, keyboard: TextInputType.number)),
          ],
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _phoneCtrl.text.isEmpty || _dobCtrl.text.isEmpty || _selectedCourseTitle == null || _selectedSemester == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields (Name, Email, Phone, DOB, Course, Semester)')),
      );
      return;
    }

    setState(() => _saving = true);

    final data = {
      'fullName': _nameCtrl.text,
      'email': _emailCtrl.text,
      'phone': _phoneCtrl.text,
      'dob': _dobCtrl.text,
      'caste': _casteCtrl.text,
      'bloodGroup': _bloodGroup.name,
      'permanentAddress': _addressCtrl.text,
      'father': {
        'name': _fatherNameCtrl.text,
        'occupation': _fatherOccCtrl.text,
        'mobile': _fatherPhoneCtrl.text,
      },
      'mother': {
        'name': _motherNameCtrl.text,
        'occupation': _motherOccCtrl.text,
        'mobile': _motherPhoneCtrl.text,
      },
      'academic': {
        'course': _selectedCourseTitle,
        'semester': _selectedSemester,
      },
      'sslc': {
        'school': _sslcSchoolCtrl.text,
        'percentage': double.tryParse(_sslcPercentCtrl.text) ?? 0,
        'board': _sslcBoardCtrl.text,
      },
      'puc': {
        'college': _pucCollegeCtrl.text,
        'percentage': double.tryParse(_pucPercentCtrl.text) ?? 0,
        'course': _pucCourseCtrl.text,
      },
    };

    final res = await _studentService.registerStudent(data);

    setState(() => _saving = false);
    if (!mounted) return;

    if (res['success'] == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          title: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Registration Successful',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ),
              ),
            ],
          ),
          content: const Text(
            'Your registration has been submitted successfully.\n\nAn administrator will review and accept your profile. Once approved, your default password will be your Date of Birth (without dashes, e.g., 01012003).',
            style: TextStyle(height: 1.5),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context); // Go back to login
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0EA5E9),
                foregroundColor: Colors.white,
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Registration failed')),
      );
    }
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  const _FormSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboard;
  final int maxLines;

  const _FormField({
    required this.ctrl,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboard = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboard,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 18),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 1.5)),
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    this.value,
    required this.items,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 18),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 1.5)),
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
