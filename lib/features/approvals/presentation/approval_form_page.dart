import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_formatting.dart';
import '../../../core/widgets/gradient_button.dart';
import '../data/approval_repository.dart';
import '../models/approval_detail.dart';
import '../models/master_option.dart';

/// Staff-only "new Approval" form - pushed via a plain [MaterialPageRoute]
/// (ephemeral, not a stable destination). Picking a grade loads that
/// grade's students so staff can choose who the approval applies to.
class ApprovalFormPage extends StatefulWidget {
  const ApprovalFormPage({super.key});

  @override
  State<ApprovalFormPage> createState() => _ApprovalFormPageState();
}

class _ApprovalFormPageState extends State<ApprovalFormPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late Future<(List<MasterOption> grades, List<MasterOption> types)> _optionsFuture;

  String? _gradeId;
  String? _approvalTypeId;
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now().add(const Duration(days: 1));
  DateTime _respondBeforeDate = DateTime.now().add(const Duration(days: 1));

  Future<List<ApprovalStudentResponse>>? _studentsFuture;
  final Set<String> _selectedStudentIds = {};

  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final repo = context.read<ApprovalRepository>();
    _optionsFuture = () async {
      final grades = await repo.fetchGrades();
      final types = await repo.fetchApprovalTypes();
      return (grades, types);
    }();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onGradeChanged(String? gradeId) {
    setState(() {
      _gradeId = gradeId;
      _selectedStudentIds.clear();
      _studentsFuture = gradeId == null
          ? null
          : context.read<ApprovalRepository>().fetchStudentsByGrade(gradeId);
    });
  }

  Future<void> _pickDate({
    required DateTime initial,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null) onPicked(date);
  }

  Future<void> _submit() async {
    if (_approvalTypeId == null) {
      setState(() => _error = 'Please select an approval type');
      return;
    }
    if (_gradeId == null) {
      setState(() => _error = 'Please select a grade');
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter a title');
      return;
    }
    if (_selectedStudentIds.isEmpty) {
      setState(() => _error = 'Please select at least one student');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await context.read<ApprovalRepository>().createApproval(
            approvalTypeId: _approvalTypeId!,
            gradeId: _gradeId!,
            title: _titleController.text,
            fromDate: _fromDate,
            toDate: _toDate,
            respondBeforeDate: _respondBeforeDate,
            description: _descriptionController.text,
            studentIds: _selectedStudentIds.toList(),
          );
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = "Couldn't create this approval");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('New Approval')),
      body: FutureBuilder<(List<MasterOption> grades, List<MasterOption> types)>(
        future: _optionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Couldn't load approval options"));
          }

          final (grades, types) = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _approvalTypeId,
                  decoration: const InputDecoration(labelText: 'Approval Type'),
                  items: [
                    for (final type in types) DropdownMenuItem(value: type.id, child: Text(type.value)),
                  ],
                  onChanged: (value) => setState(() => _approvalTypeId = value),
                ),
                const SizedBox(height: AppSpacing.m),
                DropdownButtonFormField<String>(
                  initialValue: _gradeId,
                  decoration: const InputDecoration(labelText: 'Grade'),
                  items: [
                    for (final grade in grades) DropdownMenuItem(value: grade.id, child: Text(grade.value)),
                  ],
                  onChanged: _onGradeChanged,
                ),
                const SizedBox(height: AppSpacing.m),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: AppSpacing.m),
                _DateField(
                  label: 'From Date',
                  value: _fromDate,
                  onTap: () => _pickDate(initial: _fromDate, onPicked: (d) => setState(() => _fromDate = d)),
                ),
                const SizedBox(height: AppSpacing.m),
                _DateField(
                  label: 'To Date',
                  value: _toDate,
                  onTap: () => _pickDate(initial: _toDate, onPicked: (d) => setState(() => _toDate = d)),
                ),
                const SizedBox(height: AppSpacing.m),
                _DateField(
                  label: 'Respond Before',
                  value: _respondBeforeDate,
                  onTap: () => _pickDate(
                    initial: _respondBeforeDate,
                    onPicked: (d) => setState(() => _respondBeforeDate = d),
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: AppSpacing.l),
                Text('Students', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.s),
                if (_gradeId == null)
                  Text('Select a grade to choose students', style: TextStyle(color: colorScheme.onSurfaceVariant))
                else
                  FutureBuilder<List<ApprovalStudentResponse>>(
                    future: _studentsFuture,
                    builder: (context, studentSnapshot) {
                      if (studentSnapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.m),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (studentSnapshot.hasError || !studentSnapshot.hasData) {
                        return const Text("Couldn't load students for this grade");
                      }
                      final students = studentSnapshot.data!;
                      if (students.isEmpty) {
                        return Text('No students in this grade', style: TextStyle(color: colorScheme.onSurfaceVariant));
                      }
                      return Column(
                        children: [
                          for (final student in students)
                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(student.studentName),
                              value: _selectedStudentIds.contains(student.studentId),
                              onChanged: (checked) => setState(() {
                                if (checked == true) {
                                  _selectedStudentIds.add(student.studentId);
                                } else {
                                  _selectedStudentIds.remove(student.studentId);
                                }
                              }),
                            ),
                        ],
                      );
                    },
                  ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.m),
                  Text(_error!, style: TextStyle(color: colorScheme.error)),
                ],
                const SizedBox(height: AppSpacing.l),
                GradientButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Create Approval'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime value;
  final VoidCallback onTap;

  const _DateField({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(formatShortDate(value)),
      ),
    );
  }
}
