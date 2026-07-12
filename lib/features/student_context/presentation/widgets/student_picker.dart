import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../data/student_repository.dart';
import '../../models/student_summary.dart';

/// Staff-only search/select list used to choose whose data to view (e.g.
/// gallery, finance) - parents never see this, they only ever have their
/// own student in context. Lives in `student_context/` rather than any one
/// feature so every module that needs a "pick a student" step can reuse it
/// without depending on each other.
class StudentPicker extends StatefulWidget {
  final StudentRepository repository;
  final ValueChanged<StudentSummary> onSelected;

  const StudentPicker({super.key, required this.repository, required this.onSelected});

  @override
  State<StudentPicker> createState() => _StudentPickerState();
}

class _StudentPickerState extends State<StudentPicker> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<StudentSummary> _results = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(query));
  }

  Future<void> _search(String query) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await widget.repository.searchStudents(searchKeyword: query);
      if (!mounted) return;
      setState(() => _results = results);
    } catch (_) {
      if (mounted) setState(() => _error = "Couldn't load students");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: TextField(
            controller: _searchController,
            onChanged: _onQueryChanged,
            decoration: const InputDecoration(
              hintText: 'Search students by name',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: switch ((_isLoading, _error, _results.isEmpty)) {
            (true, _, _) => const Center(child: CircularProgressIndicator()),
            (_, final err?, _) => Center(child: Text(err, style: TextStyle(color: colorScheme.onSurfaceVariant))),
            (_, _, true) => Center(
                child: Text('No students found', style: TextStyle(color: colorScheme.onSurfaceVariant)),
              ),
            _ => ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                itemCount: _results.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final student = _results[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.primaryContainer,
                      child: Text(
                        student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                        style: TextStyle(color: colorScheme.onPrimaryContainer),
                      ),
                    ),
                    title: Text(student.name),
                    subtitle: student.gradeAndClass.isNotEmpty ? Text(student.gradeAndClass) : null,
                    onTap: () => widget.onSelected(student),
                  );
                },
              ),
          },
        ),
      ],
    );
  }
}
