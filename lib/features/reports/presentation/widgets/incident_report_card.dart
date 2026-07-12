import 'package:flutter/material.dart';

import '../../../../core/theme/app_module_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/app_module.dart';
import '../../../../core/utils/date_formatting.dart';
import '../../models/incident_report.dart';
import 'approval_status_chip.dart';

class IncidentReportCard extends StatelessWidget {
  final IncidentReport report;
  final VoidCallback onTap;

  const IncidentReportCard({super.key, required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accent = AppModuleColors.of(AppModule.reports);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(11)),
                alignment: Alignment.center,
                child: Icon(Icons.warning_amber_outlined, color: accent, size: 20),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            report.title ?? 'Incident Report',
                            style: textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ApprovalStatusChip(status: report.approvalStatus),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatShortDate(report.incidentDateTime),
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      report.incidentDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
