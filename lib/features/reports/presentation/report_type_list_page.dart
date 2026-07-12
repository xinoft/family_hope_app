import 'package:flutter/material.dart';

import '../../../core/constants/app_module.dart';
import '../../../core/widgets/permission_gate.dart';
import 'report_type_spec.dart';

/// Dedicated list page for exactly one report type - pushed from a tile
/// on `ReportsPage`. Owns its own refresh token, so re-opening this page
/// (or saving a new report from it) never touches any other report
/// type's data.
class ReportTypeListPage extends StatefulWidget {
  final ReportTypeSpec spec;
  final String studentId;
  final String studentName;
  final bool approvedOnly;

  const ReportTypeListPage({
    super.key,
    required this.spec,
    required this.studentId,
    required this.studentName,
    required this.approvedOnly,
  });

  @override
  State<ReportTypeListPage> createState() => _ReportTypeListPageState();
}

class _ReportTypeListPageState extends State<ReportTypeListPage> {
  int _refreshToken = 0;

  void _refresh() => setState(() => _refreshToken++);

  Future<void> _openCreateForm() async {
    final saved = await widget.spec.openCreateForm(context, widget.studentId, widget.studentName);
    if (saved == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.spec.label)),
      body: widget.spec.buildList(
        context,
        studentId: widget.studentId,
        approvedOnly: widget.approvedOnly,
        refreshToken: _refreshToken,
        onNeedsRefresh: _refresh,
      ),
      floatingActionButton: PermissionGate(
        module: AppModule.reports,
        action: CapabilityAction.add,
        child: FloatingActionButton.extended(
          onPressed: _openCreateForm,
          icon: const Icon(Icons.add),
          label: Text(widget.spec.newButtonLabel),
        ),
      ),
    );
  }
}
