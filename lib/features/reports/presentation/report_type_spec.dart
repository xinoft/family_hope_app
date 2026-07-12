import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/report_repository.dart';
import '../models/incident_report.dart';
import '../models/progress_report.dart';
import 'incident_report_detail_page.dart';
import 'incident_report_form_page.dart';
import 'progress_report_detail_page.dart';
import 'progress_report_form_page.dart';
import 'widgets/incident_report_card.dart';
import 'widgets/progress_report_card.dart';
import 'widgets/report_list.dart';

/// Everything `ReportsPage` needs to know about one report type - adding
/// a new report type (beyond Incident/Progress) is adding one more of
/// these to [defaultReportTypes], not editing `ReportsPage` itself. Shown
/// as a tile on the Reports grid (like Home's module grid) rather than a
/// tab, so opening one report type never fetches another's data.
class ReportTypeSpec {
  final String label;
  final IconData tileIcon;
  final String newButtonLabel;

  /// Builds this type's list content (a [ReportList] wired to its own
  /// model/repository call and card/detail page) - the only place that
  /// still needs to know the concrete report type.
  final Widget Function(
    BuildContext context, {
    required String studentId,
    required bool approvedOnly,
    required int refreshToken,
    required VoidCallback onNeedsRefresh,
  }) buildList;

  /// Pushes this type's create form; resolves `true` if a report was
  /// saved (the caller refreshes its list in response).
  final Future<bool?> Function(BuildContext context, String studentId, String studentName) openCreateForm;

  const ReportTypeSpec({
    required this.label,
    required this.tileIcon,
    required this.newButtonLabel,
    required this.buildList,
    required this.openCreateForm,
  });
}

final ReportTypeSpec incidentReportSpec = ReportTypeSpec(
  label: 'Incidents',
  tileIcon: Icons.warning_amber_outlined,
  newButtonLabel: 'New Incident',
  buildList: (context, {required studentId, required approvedOnly, required refreshToken, required onNeedsRefresh}) {
    final reportRepository = context.read<ReportRepository>();
    return ReportList<IncidentReport>(
      key: ValueKey('incidents-$studentId-$refreshToken'),
      fetchAll: reportRepository.fetchIncidentReports,
      studentId: studentId,
      approvedOnly: approvedOnly,
      emptyMessage: 'No incident reports yet',
      itemBuilder: (context, report) => IncidentReportCard(
        report: report,
        onTap: () async {
          final changed = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => IncidentReportDetailPage(report: report)),
          );
          if (changed == true) onNeedsRefresh();
        },
      ),
    );
  },
  openCreateForm: (context, studentId, studentName) => Navigator.of(context).push<bool>(
    MaterialPageRoute(builder: (_) => IncidentReportFormPage(studentId: studentId, studentName: studentName)),
  ),
);

final ReportTypeSpec progressReportSpec = ReportTypeSpec(
  label: 'Progress',
  tileIcon: Icons.trending_up_outlined,
  newButtonLabel: 'New Progress Report',
  buildList: (context, {required studentId, required approvedOnly, required refreshToken, required onNeedsRefresh}) {
    final reportRepository = context.read<ReportRepository>();
    return ReportList<ProgressReport>(
      key: ValueKey('progress-$studentId-$refreshToken'),
      fetchAll: reportRepository.fetchProgressReports,
      studentId: studentId,
      approvedOnly: approvedOnly,
      emptyMessage: 'No progress reports yet',
      itemBuilder: (context, report) => ProgressReportCard(
        report: report,
        onTap: () async {
          final changed = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => ProgressReportDetailPage(report: report)),
          );
          if (changed == true) onNeedsRefresh();
        },
      ),
    );
  },
  openCreateForm: (context, studentId, studentName) => Navigator.of(context).push<bool>(
    MaterialPageRoute(builder: (_) => ProgressReportFormPage(studentId: studentId, studentName: studentName)),
  ),
);

/// The report types this app currently ships. Add a new [ReportTypeSpec]
/// here (plus its own model/repository methods/card/form/detail page,
/// following the same shape as Incident/Progress) to add a report type.
final List<ReportTypeSpec> defaultReportTypes = [incidentReportSpec, progressReportSpec];
