import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_module.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_formatting.dart';
import '../../../core/widgets/permission_gate.dart';
import '../data/report_repository.dart';
import '../models/approval_status.dart';
import '../models/progress_report.dart';
import 'widgets/approval_action_bar.dart';
import 'widgets/approval_status_chip.dart';

class ProgressReportDetailPage extends StatelessWidget {
  final ProgressReport report;

  const ProgressReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(report.title ?? 'Progress Report')),
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
            const SizedBox(height: 2),
            Text(
              formatShortDate(report.reportDate),
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.l),
            for (final category in report.categories) ...[
              Text(category.categoryName, style: textTheme.titleMedium),
              const SizedBox(height: AppSpacing.s),
              for (final question in category.questions)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    children: [
                      Expanded(child: Text(question.questionText)),
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Text(
                          question.grade,
                          style: TextStyle(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              if (category.remarks != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  category.remarks!,
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic),
                ),
              ],
              const SizedBox(height: AppSpacing.m),
            ],
            if (report.approvalNote != null) ...[
              Text('Approval Note', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
              const SizedBox(height: 4),
              Text(report.approvalNote!),
              const SizedBox(height: AppSpacing.m),
            ],
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
                    await context.read<ReportRepository>().updateProgressReportApproval(
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
        children: [
          Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
