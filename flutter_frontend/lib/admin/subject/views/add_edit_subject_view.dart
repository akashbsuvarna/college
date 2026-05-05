import 'package:flutter/material.dart';
import '../viewmodels/subject_viewmodel.dart';
import '../models/subject_model.dart';
import '../../course/models/course_model.dart';
import '../../core/app_theme.dart';

class AddEditSubjectView extends StatefulWidget {
  final SubjectViewModel viewModel;
  final List<Course> courses;
  final Subject? subject; // null = Add mode

  const AddEditSubjectView({
    super.key,
    required this.viewModel,
    required this.courses,
    this.subject,
  });

  @override
  State<AddEditSubjectView> createState() => _AddEditSubjectViewState();
}

class _AddEditSubjectViewState extends State<AddEditSubjectView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _codeCtrl;
  late final TextEditingController _creditsCtrl;

  String? _selectedCourseId;
  bool _isSaving = false;

  bool get _isEdit => widget.subject != null;

  @override
  void initState() {
    super.initState();
    final s = widget.subject;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _codeCtrl = TextEditingController(text: s?.code ?? '');
    _creditsCtrl = TextEditingController(text: s?.credits.toString() ?? '3');
    _selectedCourseId = s?.courseId;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _creditsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a course'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final subject = Subject(
      id: widget.subject?.id,
      name: _nameCtrl.text.trim(),
      code: _codeCtrl.text.trim().toUpperCase(),
      courseId: _selectedCourseId!,
      credits: int.tryParse(_creditsCtrl.text.trim()) ?? 3,
    );

    if (_isEdit) {
      await widget.viewModel.updateSubject(subject);
    } else {
      await widget.viewModel.addSubject(subject);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (widget.viewModel.errorMessage == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit
                ? 'Subject updated successfully'
                : 'Subject added successfully'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.viewModel.errorMessage!),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Edit Subject' : 'Add New Subject',
          style: const TextStyle(
              color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppTheme.surfaceDark,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        elevation: 0,
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
              // ── Header card ─────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8F5E9), Color(0xFFE3F2FD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentCyan.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _isEdit
                            ? Icons.edit_rounded
                            : Icons.subject_rounded,
                        color: AppTheme.accentCyan,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEdit ? 'Edit Subject Details' : 'New Subject',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isEdit
                                ? 'Update the subject information below'
                                : 'Fill in the details for the new subject',
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Section: Subject Information ─────────────────────────────
              _sectionLabel('Subject Information'),
              const SizedBox(height: 12),
              _buildCard(children: [
                _field(
                  controller: _nameCtrl,
                  label: 'Subject Name',
                  hint: 'e.g. Data Structures & Algorithms',
                  icon: Icons.library_books_rounded,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _field(
                        controller: _codeCtrl,
                        label: 'Subject Code',
                        hint: 'e.g. DSA101',
                        icon: Icons.tag_rounded,
                        textCapitalization: TextCapitalization.characters,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _field(
                        controller: _creditsCtrl,
                        label: 'Credits',
                        hint: '3',
                        icon: Icons.star_rounded,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if (int.tryParse(v.trim()) == null) return 'Must be a number';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ]),

              const SizedBox(height: 20),

              // ── Section: Course Association ─────────────────────────────
              _sectionLabel('Course Association'),
              const SizedBox(height: 12),
              _buildCard(children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedCourseId,
                  decoration: InputDecoration(
                    labelText: 'Select Course',
                    labelStyle: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13),
                    prefixIcon: const Icon(Icons.book_rounded,
                        color: AppTheme.textMuted, size: 18),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    filled: true,
                    fillColor: AppTheme.surfaceCardHover,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppTheme.dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppTheme.dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: AppTheme.accentIndigo, width: 1.5),
                    ),
                  ),
                  dropdownColor: AppTheme.surfaceCard,
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 14),
                  hint: const Text('Choose a course',
                      style: TextStyle(
                          color: AppTheme.textMuted, fontSize: 13)),
                  items: widget.courses
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(
                              '${c.code} – ${c.title}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _selectedCourseId = val),
                  validator: (v) =>
                      v == null ? 'Please select a course' : null,
                ),
              ]),

              const SizedBox(height: 32),

              // ── Action buttons ──────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isSaving ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppTheme.dividerColor),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Cancel',
                          style:
                              TextStyle(color: AppTheme.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _submit,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Icon(_isEdit
                              ? Icons.save_rounded
                              : Icons.add_circle_rounded),
                      label:
                          Text(_isEdit ? 'Save Changes' : 'Add Subject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentCyan,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    TextCapitalization textCapitalization = TextCapitalization.words,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle:
            const TextStyle(color: AppTheme.textMuted, fontSize: 13),
        labelStyle:
            const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 18),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        filled: true,
        fillColor: AppTheme.surfaceCardHover,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppTheme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppTheme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: AppTheme.accentCyan, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppTheme.accentRed),
        ),
      ),
    );
  }
}
