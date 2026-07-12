import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_formatting.dart';
import '../../../core/widgets/gradient_button.dart';
import '../data/report_repository.dart';
import '../models/progress_report_template.dart';

const _grades = ['A', 'B', 'C', 'D', 'E'];

/// Staff-only "new Progress Report" form. Unlike Incident Reports, this
/// needs the student's grade-specific question template first (see
/// `ReportRepository.fetchProgressReportTemplate`) before there's
/// anything to show.
class ProgressReportFormPage extends StatefulWidget {
  final String studentId;
  final String studentName;

  const ProgressReportFormPage({super.key, required this.studentId, required this.studentName});

  @override
  State<ProgressReportFormPage> createState() => _ProgressReportFormPageState();
}

class _ProgressReportFormPageState extends State<ProgressReportFormPage> {
  late final Future<ProgressReportTemplate> _templateFuture =
      context.read<ReportRepository>().fetchProgressReportTemplate(widget.studentId);

  final _titleController = TextEditingController();
  final Map<int, Map<int, String>> _selectedGrades = {};
  final Map<int, TextEditingController> _categoryRemarks = {};

  DateTime _reportDate = DateTime.now();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    for (final controller in _categoryRemarks.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _reportDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _reportDate = picked);
  }

  Future<void> _submit(ProgressReportTemplate template) async {
    for (var i = 0; i < template.categories.length; i++) {
      final category = template.categories[i];
      for (var j = 0; j < category.questions.length; j++) {
        if (_selectedGrades[i]?[j] == null) {
          setState(() => _error = 'Please grade every question under "${category.categoryName}"');
          return;
        }
      }
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      final categories = [
        for (var i = 0; i < template.categories.length; i++)
          ProgressReportCategorySubmission(
            categoryName: template.categories[i].categoryName,
            remarks: _categoryRemarks[i]?.text,
            questions: [
              for (var j = 0; j < template.categories[i].questions.length; j++)
                ProgressReportQuestionSubmission(
                  questionText: template.categories[i].questions[j].questionText,
                  grade: _selectedGrades[i]![j]!,
                ),
            ],
          ),
      ];
      await context.read<ReportRepository>().saveProgressReport(
            studentId: widget.studentId,
            title: _titleController.text,
            reportDate: _reportDate,
            categories: categories,
          );
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = "Couldn't save this report");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('New Progress Report - ${widget.studentName}')),
      body: FutureBuilder<ProgressReportTemplate>(
        future: _templateFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error is ApiException ? (snapshot.error as ApiException).message : "Couldn't load the progress report template",
                textAlign: TextAlign.center,
              ),
            );
          }

          final template = snapshot.data!;
          if (template.categories.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.l),
                child: Text(
                  "No progress report template is configured for this student's grade yet",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title (optional)'),
                ),
                const SizedBox(height: AppSpacing.m),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(16),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Report Date'),
                    child: Text(formatShortDate(_reportDate)),
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                for (var i = 0; i < template.categories.length; i++)
                  _CategorySection(
                    category: template.categories[i],
                    selectedGrades: _selectedGrades.putIfAbsent(i, () => {}),
                    remarksController: _categoryRemarks.putIfAbsent(i, () => TextEditingController()),
                    onGradeChanged: (questionIndex, grade) =>
                        setState(() => _selectedGrades[i]![questionIndex] = grade),
                  ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.m),
                  Text(_error!, style: TextStyle(color: colorScheme.error)),
                ],
                const SizedBox(height: AppSpacing.l),
                GradientButton(
                  onPressed: _isSubmitting ? null : () => _submit(template),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Submit Report'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final ProgressReportTemplateCategory category;
  final Map<int, String> selectedGrades;
  final TextEditingController remarksController;
  final void Function(int questionIndex, String grade) onGradeChanged;

  const _CategorySection({
    required this.category,
    required this.selectedGrades,
    required this.remarksController,
    required this.onGradeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(category.categoryName, style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s),
          for (var j = 0; j < category.questions.length; j++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.questions[j].questionText),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final grade in _grades)
                        ChoiceChip(
                          label: Text(grade),
                          selected: selectedGrades[j] == grade,
                          onSelected: (_) => onGradeChanged(j, grade),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: remarksController,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Remarks (optional)'),
          ),
        ],
      ),
    );
  }
}
