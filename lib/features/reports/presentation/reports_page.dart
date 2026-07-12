import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_module.dart';
import '../../../core/constants/user_type.dart';
import '../../../core/theme/app_module_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/providers/session_provider.dart';
import '../../student_context/data/student_repository.dart';
import '../../student_context/models/student_summary.dart';
import '../../student_context/presentation/widgets/student_context_header.dart';
import '../../student_context/presentation/widgets/student_picker.dart';
import '../../student_context/providers/student_context_provider.dart';
import 'report_type_list_page.dart';
import 'report_type_spec.dart';

/// Parents see their current student's reports (Approved only - a report
/// still Pending/Rejected hasn't finished review yet). Staff pick a
/// student first, see every status.
///
/// Report types are shown as tiles (like Home's module grid), not tabs -
/// tabs would eagerly fetch data for more than the one currently open
/// (`TabBarView` mounts the current page's neighbor too), so nothing here
/// loads until a tile is actually tapped. This page never mentions
/// Incident/Progress by name - it's driven entirely off
/// [defaultReportTypes], so adding a report type is adding one
/// [ReportTypeSpec], not editing this file.
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final List<ReportTypeSpec> _reportTypes = defaultReportTypes;
  StudentSummary? _staffSelectedStudent;

  void _openReportType(ReportTypeSpec spec, String studentId, String studentName, bool approvedOnly) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReportTypeListPage(
          spec: spec,
          studentId: studentId,
          studentName: studentName,
          approvedOnly: approvedOnly,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userType = context.watch<SessionProvider>().currentUser?.userType;
    final isParent = userType == UserType.parent;

    Widget body;

    if (isParent) {
      final activeStudent = context.watch<StudentContextProvider>().activeStudent;
      if (activeStudent == null) {
        body = const Center(child: CircularProgressIndicator());
      } else {
        body = _ReportTypeGrid(
          reportTypes: _reportTypes,
          onTap: (spec) => _openReportType(spec, activeStudent.id, activeStudent.name, true),
        );
      }
    } else if (_staffSelectedStudent == null) {
      body = StudentPicker(
        repository: context.read<StudentRepository>(),
        onSelected: (student) => setState(() => _staffSelectedStudent = student),
      );
    } else {
      final student = _staffSelectedStudent!;
      body = Column(
        children: [
          StudentContextHeader(
            name: student.name,
            onChange: () => setState(() => _staffSelectedStudent = null),
          ),
          Expanded(
            child: _ReportTypeGrid(
              reportTypes: _reportTypes,
              onTap: (spec) => _openReportType(spec, student.id, student.name, false),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: body,
    );
  }
}

class _ReportTypeGrid extends StatelessWidget {
  final List<ReportTypeSpec> reportTypes;
  final ValueChanged<ReportTypeSpec> onTap;

  const _ReportTypeGrid({required this.reportTypes, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = AppModuleColors.of(AppModule.reports);
    final colorScheme = Theme.of(context).colorScheme;

    return GridView.count(
      padding: const EdgeInsets.all(AppSpacing.l),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.m,
      crossAxisSpacing: AppSpacing.m,
      childAspectRatio: 1.5,
      children: [
        for (final spec in reportTypes)
          Card(
            color: Color.alphaBlend(accent.withValues(alpha: 0.10), colorScheme.surface),
            child: InkWell(
              onTap: () => onTap(spec),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      alignment: Alignment.center,
                      child: Icon(spec.tileIcon, color: accent, size: 20),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(spec.label, style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
