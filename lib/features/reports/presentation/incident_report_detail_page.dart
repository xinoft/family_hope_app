import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_module.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_formatting.dart';
import '../../../core/widgets/approval_action_bar.dart';
import '../../../core/widgets/permission_gate.dart';
import '../data/report_repository.dart';
import '../models/approval_status.dart';
import '../models/incident_report.dart';
import 'widgets/approval_status_chip.dart';

/// Read-only detail view, plus an Approve/Reject action for staff when
/// the report is still Pending (gated by our own `approve` capability -
/// see `ApprovalActionBar`'s doc for the caveat on whether the actual
/// backend call succeeds with today's dummy auth).
class IncidentReportDetailPage extends StatelessWidget {
  final IncidentReport report;

  const IncidentReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(report.title ?? 'Incident Report')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(report.studentName, style: textTheme.titleLarge)),
                ApprovalStatusChip(status: report.approvalStatus),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
            _DetailRow(label: 'Incident Date & Time', value: _formatDateTime(report.incidentDateTime)),
            _DetailSection(label: 'Description', value: report.incidentDescription),
            if (report.injuryDetails != null) _DetailSection(label: 'Injury Details', value: report.injuryDetails!),
            if (report.actions != null) _DetailSection(label: 'Actions Taken', value: report.actions!),
            if (report.remarks != null) _DetailSection(label: 'Remarks', value: report.remarks!),
            if (report.approvalNote != null) _DetailSection(label: 'Approval Note', value: report.approvalNote!),
            if (report.approvedRejectedByName != null)
              _DetailRow(label: 'Reviewed By', value: report.approvedRejectedByName!),
            _DetailRow(label: 'Created By', value: report.createdByName),
            if (report.approvalStatus == ApprovalStatus.pending) ...[
              const SizedBox(height: AppSpacing.l),
              PermissionGate(
                module: AppModule.reports,
                action: CapabilityAction.approve,
                child: ApprovalActionBar(
                  onDecide: ({required approve, note}) async {
                    await context.read<ReportRepository>().updateIncidentReportApproval(
                          id: report.id,
                          approve: approve,
                          approvalNote: note,
                        );
                    if (context.mounted) Navigator.of(context).pop(true);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) =>
      '${formatShortDate(dateTime)} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant)),
          const Spacer(),
          Flexible(
            child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String label;
  final String value;

  const _DetailSection({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
