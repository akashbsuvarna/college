import 'package:flutter/material.dart';
import '../models/teacher_model.dart';
import '../../core/app_theme.dart';
import '../viewmodels/teacher_viewmodel.dart';


class AddEditTeacherView extends StatefulWidget {
  final TeacherModel? teacher; // null = Add mode
  final TeacherViewModel viewModel;

  const AddEditTeacherView({super.key, this.teacher, required this.viewModel});

  @override
  State<AddEditTeacherView> createState() => _AddEditTeacherViewState();
}

class _AddEditTeacherViewState extends State<AddEditTeacherView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _empIdCtrl;
  late TextEditingController _qualCtrl;
  late TextEditingController _joiningDateCtrl;
  late TextEditingController _subjectsCtrl;
  late TextEditingController _dobCtrl;
  String _ment = 'Computer Science';
  String _designation = 'Assistant Professor';
  String _status = 'active';
  bool _saving = false;

  final List<String> _ments = [
    'Computer Science',
    'Electronics',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Civil Engineering',
    'Mechanical',
    'Management',
  ];

  final List<String> _designations = [
    'Assistant Professor',
    'Associate Professor',
    'Professor',
    'HOD',
    'Visiting Faculty',
    'Lab Instructor',
  ];

  bool get _isEdit => widget.teacher != null;

  @override
  void initState() {
    super.initState();
    final t = widget.teacher;
    _nameCtrl = TextEditingController(text: t?.name ?? '');
    _emailCtrl = TextEditingController(text: t?.email ?? '');
    _phoneCtrl = TextEditingController(text: t?.phone ?? '');
    _empIdCtrl = TextEditingController(text: t?.employeeId ?? '');
    _qualCtrl = TextEditingController(text: t?.qualification ?? '');
    _joiningDateCtrl = TextEditingController(text: t?.joiningDate ?? '');
    _subjectsCtrl =
        TextEditingController(text: t?.subjects.join(', ') ?? '');
    _dobCtrl = TextEditingController(text: t?.dob ?? '');
    if (t != null) {
      _ment = t.department;
      _designation = t.designation;
      _status = t.status;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _empIdCtrl.dispose();
    _qualCtrl.dispose();
    _joiningDateCtrl.dispose();
    _subjectsCtrl.dispose();
    _dobCtrl.dispose();
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
          _isEdit ? 'Edit Teacher' : 'Add New Teacher',
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
                  Expanded(child: _buildPersonalSection()),
                  const SizedBox(width: 20),
                  Expanded(child: _buildProfessionalSection()),
                ],
              ),
              const SizedBox(height: 20),
              _buildSubjectsSection(),
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
          hint: 'Dr. Firstname Lastname',
          icon: Icons.person_outline_rounded,
          validator: (v) =>
              v == null || v.isEmpty ? 'Name is required' : null,
        ),
        const SizedBox(height: 16),
        _FormField(
          ctrl: _emailCtrl,
          label: 'Email Address',
          hint: 'name@college.edu',
          icon: Icons.email_outlined,
          keyboard: TextInputType.emailAddress,
          validator: (v) =>
              v == null || !v.contains('@') ? 'Enter valid email' : null,
        ),
        const SizedBox(height: 16),
        _FormField(
          ctrl: _phoneCtrl,
          label: 'Phone Number',
          hint: '+91 9876543210',
          icon: Icons.phone_outlined,
          keyboard: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _FormField(
          ctrl: _dobCtrl,
          label: 'Date of Birth',
          hint: 'YYYY-MM-DD',
          icon: Icons.cake_outlined,
          keyboard: TextInputType.datetime,
          validator: (v) =>
              v == null || v.isEmpty ? 'DOB is required' : null,
        ),
        const SizedBox(height: 16),
        _FormField(
          ctrl: _empIdCtrl,
          label: 'Employee ID',
          hint: 'EMP001',
          icon: Icons.badge_outlined,
          validator: (v) =>
              v == null || v.isEmpty ? 'Employee ID required' : null,
        ),
      ],
    );
  }

  Widget _buildProfessionalSection() {
    return _FormCard(
      title: 'Professional Details',
      icon: Icons.school_rounded,
      color: AppTheme.accentPurple,
      children: [
        _DropdownField(
          label: 'Department',
          value: _ment,
          items: _ments,
          icon: Icons.account_balance_outlined,
          onChanged: (v) => setState(() => _ment = v!),
        ),
        const SizedBox(height: 16),
        _DropdownField(
          label: 'Designation',
          value: _designation,
          items: _designations,
          icon: Icons.workspace_premium_outlined,
          onChanged: (v) => setState(() => _designation = v!),
        ),
        const SizedBox(height: 16),
        _FormField(
          ctrl: _qualCtrl,
          label: 'Qualification',
          hint: 'Ph.D (Computer Science)',
          icon: Icons.menu_book_outlined,
        ),
        const SizedBox(height: 16),
        _FormField(
          ctrl: _joiningDateCtrl,
          label: 'Joining Date',
          hint: 'YYYY-MM-DD',
          icon: Icons.calendar_month_outlined,
          keyboard: TextInputType.datetime,
        ),
        const SizedBox(height: 16),
        // Status selector
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Status',
                style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatusRadio(
                    label: 'Active',
                    value: 'active',
                    groupValue: _status,
                    color: AppTheme.accentGreen,
                    onChanged: (v) => setState(() => _status = v!)),
                _StatusRadio(
                    label: 'On Leave',
                    value: 'on_leave',
                    groupValue: _status,
                    color: AppTheme.accentOrange,
                    onChanged: (v) => setState(() => _status = v!)),
                _StatusRadio(
                    label: 'Inactive',
                    value: 'inactive',
                    groupValue: _status,
                    color: AppTheme.accentRed,
                    onChanged: (v) => setState(() => _status = v!)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubjectsSection() {
    return _FormCard(
      title: 'Subjects',
      icon: Icons.menu_book_rounded,
      color: AppTheme.accentCyan,
      children: [
        _FormField(
          ctrl: _subjectsCtrl,
          label: 'Subjects (comma-separated)',
          hint: 'Data Structures, Algorithms, Machine Learning',
          icon: Icons.list_alt_rounded,
          maxLines: 2,
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
              : Icon(_isEdit ? Icons.save_rounded : Icons.person_add_rounded,
                  size: 18),
          label: Text(_isEdit ? 'Save Changes' : 'Add Teacher'),
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
    setState(() => _saving = true);
    
    final t = TeacherModel(
      id: widget.teacher?.id ?? '',
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      employeeId: _empIdCtrl.text.trim(),
      department: _ment,
      designation: _designation,
      joiningDate: _joiningDateCtrl.text.trim(),
      dob: _dobCtrl.text.trim(),
      status: _status,
      coursesAssigned: widget.teacher?.coursesAssigned ?? 0,
      qualification: _qualCtrl.text.trim(),
      subjects: _subjectsCtrl.text.isEmpty 
          ? [] 
          : _subjectsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
    );

    if (_isEdit) {
      await widget.viewModel.updateTeacher(t);
    } else {
      await widget.viewModel.addTeacher(t);
    }

    setState(() => _saving = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEdit
            ? 'Teacher updated successfully!'
            : 'Teacher added successfully!'),
        backgroundColor: AppTheme.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.pop(context);
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
            fillColor: AppTheme.primaryNavy.withValues(alpha: 0.05),
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
  final String value;
  final List<String> items;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
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
          initialValue: value,
          dropdownColor: AppTheme.surfaceCard,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 17),
            filled: true,
            fillColor: AppTheme.primaryNavy.withValues(alpha: 0.05),
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
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppTheme.textMuted),
        ),
      ],
    );
  }
}

class _StatusRadio extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final Color color;
  final ValueChanged<String?> onChanged;

  const _StatusRadio({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected
                  ? color.withValues(alpha: 0.6)
                  : AppTheme.dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? color : Colors.transparent,
                border: Border.all(
                    color: selected ? color : AppTheme.textMuted,
                    width: 2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? color : AppTheme.textSecondary,
                fontSize: 13,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
