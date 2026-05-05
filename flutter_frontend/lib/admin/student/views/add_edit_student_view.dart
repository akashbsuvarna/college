import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../models/student_model.dart';
import '../viewmodels/student_viewmodel.dart';
import '../../course/viewmodels/course_viewmodel.dart';
import '../../course/models/course_model.dart';

class AddEditStudentView extends StatefulWidget {
  final StudentViewModel viewModel;
  final StudentModel? student;

  const AddEditStudentView({
    super.key,
    required this.viewModel,
    this.student,
  });

  bool get isEditing => student != null;

  @override
  State<AddEditStudentView> createState() => _AddEditStudentViewState();
}

class _AddEditStudentViewState extends State<AddEditStudentView> {
  final _formKey = GlobalKey<FormState>();

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

  BloodGroup _bloodGroup = BloodGroup.Opos;
  String? _selectedCourseId;
  String? _selectedCourseTitle;
  int? _selectedSemester;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.student;

    _nameCtrl = TextEditingController(text: s?.fullName ?? '');
    _emailCtrl = TextEditingController(text: s?.email ?? '');
    _phoneCtrl = TextEditingController(text: s?.phone ?? '');
    _dobCtrl = TextEditingController(text: s?.dob ?? '');
    _casteCtrl = TextEditingController(text: s?.caste ?? '');
    _addressCtrl = TextEditingController(text: s?.permanentAddress ?? '');

    _fatherNameCtrl = TextEditingController(text: s?.father.name ?? '');
    _fatherOccCtrl = TextEditingController(text: s?.father.occupation ?? '');
    _fatherPhoneCtrl = TextEditingController(text: s?.father.mobile ?? '');

    _motherNameCtrl = TextEditingController(text: s?.mother.name ?? '');
    _motherOccCtrl = TextEditingController(text: s?.mother.occupation ?? '');
    _motherPhoneCtrl = TextEditingController(text: s?.mother.mobile ?? '');

    _courseCtrl = TextEditingController(text: s?.academic.course ?? '');
    _semesterCtrl =
        TextEditingController(text: s?.academic.semester.toString() ?? '');

    _sslcSchoolCtrl = TextEditingController(text: s?.sslc.school ?? '');
    _sslcPercentCtrl =
        TextEditingController(text: s?.sslc.percentage.toString() ?? '');
    _sslcBoardCtrl = TextEditingController(text: s?.sslc.board ?? '');

    _pucCollegeCtrl = TextEditingController(text: s?.puc.college ?? '');
    _pucPercentCtrl =
        TextEditingController(text: s?.puc.percentage.toString() ?? '');
    _pucCourseCtrl = TextEditingController(text: s?.puc.course ?? '');

    if (s != null) {
      _bloodGroup = s.bloodGroup;
      _selectedCourseTitle = s.academic.course;
      _selectedSemester = s.academic.semester;
    }
  }

  int _getSemestersForCourse(String? title, List<Course> allCourses) {
    if (title == null) return 0;
    final course = allCourses.firstWhere((c) => c.title == title,
        orElse: () => Course(title: '', description: '', duration: '0', code: ''));
    
    // Parse duration like "3 Years" or "8 Semesters" or "6"
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
      return int.tryParse(durationStr) ?? 8; // default to 8 if unknown
    }
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
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        backgroundColor: AppTheme.sidebarBg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textSecondary, size: 18),
        ),
        title: Text(
          widget.isEditing ? 'Edit Student' : 'Add New Student',
          style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.dividerColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildPersonalSection(),
                        const SizedBox(height: 20),
                        _buildParentSection(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        _buildAcademicSection(),
                        const SizedBox(height: 20),
                        _buildEducationSection(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalSection() {
    return _FormCard(
      title: 'Personal Information',
      icon: Icons.person_rounded,
      color: AppTheme.accentIndigo,
      children: [
        _FormField(
          ctrl: _nameCtrl,
          label: 'Full Name',
          hint: 'Firstname Lastname',
          icon: Icons.person_outline_rounded,
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _FormField(
          ctrl: _emailCtrl,
          label: 'Email',
          hint: 'student@example.com',
          icon: Icons.email_outlined,
          keyboard: TextInputType.emailAddress,
          validator: (v) =>
              v == null || !v.contains('@') ? 'Enter valid email' : null,
        ),
        const SizedBox(height: 16),
        _FormField(
          ctrl: _phoneCtrl,
          label: 'Phone',
          hint: '+91 9000000000',
          icon: Icons.phone_outlined,
          keyboard: TextInputType.phone,
        ),
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
            child: _FormField(
              ctrl: _dobCtrl,
              label: 'Date of Birth',
              hint: 'Select Date',
              icon: Icons.calendar_today_outlined,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _FormField(
          ctrl: _addressCtrl,
          label: 'Permanent Address',
          hint: 'Home address...',
          icon: Icons.home_outlined,
          maxLines: 2,
        ),
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
        _FormField(
          ctrl: _casteCtrl,
          label: 'Category / Caste',
          hint: 'General / OBC / SC / ST',
          icon: Icons.group_outlined,
        ),
      ],
    );
  }

  Widget _buildParentSection() {
    return _FormCard(
      title: 'Parent Details',
      icon: Icons.family_restroom_rounded,
      color: AppTheme.accentPurple,
      children: [
        const Text('Father Information',
            style: TextStyle(
                color: AppTheme.accentPurple,
                fontWeight: FontWeight.w600,
                fontSize: 14)),
        const SizedBox(height: 12),
        _FormField(
            ctrl: _fatherNameCtrl,
            label: 'Father Name',
            hint: 'Name',
            icon: Icons.person_outline),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _FormField(
                  ctrl: _fatherOccCtrl,
                  label: 'Occupation',
                  hint: 'Job',
                  icon: Icons.work_outline),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FormField(
                  ctrl: _fatherPhoneCtrl,
                  label: 'Mobile',
                  hint: 'Phone',
                  icon: Icons.phone_outlined),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Divider(color: AppTheme.dividerColor),
        const SizedBox(height: 16),
        const Text('Mother Information',
            style: TextStyle(
                color: AppTheme.accentOrange,
                fontWeight: FontWeight.w600,
                fontSize: 14)),
        const SizedBox(height: 12),
        _FormField(
            ctrl: _motherNameCtrl,
            label: 'Mother Name',
            hint: 'Name',
            icon: Icons.person_3_outlined),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _FormField(
                  ctrl: _motherOccCtrl,
                  label: 'Occupation',
                  hint: 'Job',
                  icon: Icons.work_outline),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FormField(
                  ctrl: _motherPhoneCtrl,
                  label: 'Mobile',
                  hint: 'Phone',
                  icon: Icons.phone_outlined),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAcademicSection() {
    final courseVm = context.watch<CourseViewModel>();
    final courses = courseVm.allCourses;
    
    // Find selected course object to get its duration
    int maxSemesters = _getSemestersForCourse(_selectedCourseTitle, courses);
    List<int> semesterOptions = List.generate(maxSemesters, (i) => i + 1);

    return _FormCard(
      title: 'Academic details',
      icon: Icons.school_rounded,
      color: AppTheme.accentCyan,
      children: [
        _DropdownField(
          label: 'Course',
          value: _selectedCourseTitle,
          items: courses.map((c) => c.title).toList(),
          icon: Icons.menu_book_rounded,
          hint: 'Select Course',
          onChanged: (v) {
            setState(() {
              _selectedCourseTitle = v;
              // Reset semester if invalid for new course
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
          hint: 'Select Semester',
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
    return _FormCard(
      title: 'Previous Education',
      icon: Icons.history_edu_rounded,
      color: AppTheme.accentGreen,
      children: [
        const Text('SSLC / 10th',
            style: TextStyle(
                color: AppTheme.accentGreen,
                fontWeight: FontWeight.w600,
                fontSize: 14)),
        const SizedBox(height: 12),
        _FormField(
            ctrl: _sslcSchoolCtrl,
            label: 'School',
            hint: 'School Name',
            icon: Icons.account_balance_outlined),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _FormField(
                  ctrl: _sslcBoardCtrl,
                  label: 'Board',
                  hint: 'State / CBSE',
                  icon: Icons.assignment_outlined),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FormField(
                  ctrl: _sslcPercentCtrl,
                  label: 'Percentage',
                  hint: '90.5',
                  icon: Icons.percent_rounded,
                  keyboard: TextInputType.number),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Divider(color: AppTheme.dividerColor),
        const SizedBox(height: 16),
        const Text('PUC / 12th',
            style: TextStyle(
                color: AppTheme.accentIndigo,
                fontWeight: FontWeight.w600,
                fontSize: 14)),
        const SizedBox(height: 12),
        _FormField(
            ctrl: _pucCollegeCtrl,
            label: 'College',
            hint: 'College Name',
            icon: Icons.account_balance_rounded),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _FormField(
                  ctrl: _pucCourseCtrl,
                  label: 'Course',
                  hint: 'Science / Arts',
                  icon: Icons.science_outlined),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FormField(
                  ctrl: _pucPercentCtrl,
                  label: 'Percentage',
                  hint: '85.0',
                  icon: Icons.percent_rounded,
                  keyboard: TextInputType.number),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.textSecondary,
            side: const BorderSide(color: AppTheme.dividerColor),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _saving ? null : _submit,
          icon: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Icon(widget.isEditing ? Icons.save_rounded : Icons.person_add_rounded,
                  size: 18),
          label: Text(widget.isEditing ? 'Save Changes' : 'Add Student'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentIndigo,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCourseTitle == null || _selectedSemester == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Course and Semester')),
      );
      return;
    }

    setState(() => _saving = true);

    final student = StudentModel(
      id: widget.student?.id ?? '',
      fullName: _nameCtrl.text,
      email: _emailCtrl.text,
      phone: _phoneCtrl.text,
      studentId: widget.student?.studentId ?? '',
      dob: _dobCtrl.text,
      caste: _casteCtrl.text,
      bloodGroup: _bloodGroup,
      permanentAddress: _addressCtrl.text,
      father: ParentModel(
        name: _fatherNameCtrl.text,
        occupation: _fatherOccCtrl.text,
        mobile: _fatherPhoneCtrl.text,
      ),
      mother: ParentModel(
        name: _motherNameCtrl.text,
        occupation: _motherOccCtrl.text,
        mobile: _motherPhoneCtrl.text,
      ),
      academic: AcademicInfo(
        course: _selectedCourseTitle!,
        semester: _selectedSemester!,
      ),
      sslc: SSLCModel(
        school: _sslcSchoolCtrl.text,
        percentage: double.tryParse(_sslcPercentCtrl.text) ?? 0,
        board: _sslcBoardCtrl.text,
      ),
      puc: PUCModel(
        college: _pucCollegeCtrl.text,
        percentage: double.tryParse(_pucPercentCtrl.text) ?? 0,
        course: _pucCourseCtrl.text,
      ),
    );

    bool success = false;
    if (widget.isEditing) {
      success = await widget.viewModel.updateStudent(student);
    } else {
      success = await widget.viewModel.addStudent(student);
    }

    setState(() => _saving = false);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditing
              ? 'Student updated successfully!'
              : 'Student added successfully!'),
          backgroundColor: AppTheme.accentGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.viewModel.errorMessage ?? 'Operation failed'),
          backgroundColor: AppTheme.accentRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}

// ───── Reusable Form Widgets ─────

class _FormCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  const _FormCard({
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
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
  final String? Function(String?)? validator;
  final int maxLines;

  const _FormField({
    required this.ctrl,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboard = TextInputType.text,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboard,
          validator: validator,
          maxLines: maxLines,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 17),
            filled: true,
            fillColor: AppTheme.primaryNavy.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.accentIndigo),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.accentRed),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final String? hint;
  final List<String> items;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    this.value,
    this.hint,
    required this.items,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          hint: hint != null ? Text(hint!, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)) : null,
          dropdownColor: AppTheme.surfaceCard,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 17),
            filled: true,
            fillColor: AppTheme.primaryNavy.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.accentIndigo),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          ),
          items: items
              .map((d) => DropdownMenuItem(value: d, child: Text(d)))
              .toList(),
          onChanged: onChanged,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: AppTheme.textMuted),
        ),
      ],
    );
  }
}