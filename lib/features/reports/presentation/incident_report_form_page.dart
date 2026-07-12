import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_formatting.dart';
import '../../../core/widgets/gradient_button.dart';
import '../data/report_repository.dart';

/// Staff-only "new Incident Report" form, pushed via a plain
/// [MaterialPageRoute] (ephemeral, tied to whichever student is selected
/// on the Reports page - not a stable destination).
class IncidentReportFormPage extends StatefulWidget {
  final String studentId;
  final String studentName;

  const IncidentReportFormPage({super.key, required this.studentId, required this.studentName});

  @override
  State<IncidentReportFormPage> createState() => _IncidentReportFormPageState();
}

class _IncidentReportFormPageState extends State<IncidentReportFormPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _injuryController = TextEditingController();
  final _actionsController = TextEditingController();
  final _remarksController = TextEditingController();

  DateTime _incidentDateTime = DateTime.now();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _injuryController.dispose();
    _actionsController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _incidentDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_incidentDateTime),
    );
    if (time == null) return;

    setState(() {
      _incidentDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (_descriptionController.text.trim().isEmpty) {
      setState(() => _error = 'Please describe the incident');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await context.read<ReportRepository>().saveIncidentReport(
            studentId: widget.studentId,
            title: _titleController.text,
            incidentDateTime: _incidentDateTime,
            incidentDescription: _descriptionController.text,
            injuryDetails: _injuryController.text,
            actions: _actionsController.text,
            remarks: _remarksController.text,
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
      appBar: AppBar(title: Text('New Incident - ${widget.studentName}')),
      body: SingleChildScrollView(
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
              onTap: _pickDateTime,
              borderRadius: BorderRadius.circular(16),
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Incident Date & Time'),
                child: Text(
                  '${formatShortDate(_incidentDateTime)} at '
                  '${_incidentDateTime.hour.toString().padLeft(2, '0')}:'
                  '${_incidentDateTime.minute.toString().padLeft(2, '0')}',
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Incident Description'),
            ),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: _injuryController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Injury Details (optional)'),
            ),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: _actionsController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Actions Taken (optional)'),
            ),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: _remarksController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Remarks (optional)'),
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
                  : const Text('Submit Report'),
            ),
          ],
        ),
      ),
    );
  }
}
