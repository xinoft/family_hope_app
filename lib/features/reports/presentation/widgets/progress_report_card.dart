import 'package:flutter/material.dart';

import '../../../../core/constants/app_module.dart';
import '../../../../core/theme/app_module_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatting.dart';
import '../../models/progress_report.dart';
import 'approval_status_chip.dart';

class ProgressReportCard extends StatelessWidget {
  final ProgressReport report;
  final VoidCallback onTap;

  const ProgressReportCard({super.key, required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accent = AppModuleColors.of(AppModule.reports);
    final questionCount = report.categories.fold<int>(0, (sum, category) => sum + category.questions.length);

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
                child: Icon(Icons.trending_up_outlined, color: accent, size: 20),
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
                            report.title ?? 'Progress Report',
                            style: textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ApprovalStatusChip(status: report.approvalStatus),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatShortDate(report.reportDate)} · ${report.categories.length} categories, $questionCount questions',
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
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
