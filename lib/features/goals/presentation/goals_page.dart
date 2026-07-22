import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_module.dart';
import '../../../core/theme/app_module_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_formatting.dart';
import '../data/goals_repository.dart';
import '../models/student_goal.dart';
import 'widgets/goal_status_chip.dart';

/// Dummy content for now (see `GoalsRepository`'s TODO) - same for every
/// viewer regardless of persona.
class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  late final Future<List<StudentGoal>> _future = context.read<GoalsRepository>().fetchGoals();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: FutureBuilder<List<StudentGoal>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Couldn't load goals"));
          }

          final goals = snapshot.data!;
          if (goals.isEmpty) {
            return const Center(child: Text('No goals assigned yet'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.m),
            itemCount: goals.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.s),
            itemBuilder: (context, index) => _GoalCard(goal: goals[index]),
          );
        },
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final StudentGoal goal;

  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accent = AppModuleColors.of(AppModule.goals);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration:
                      BoxDecoration(color: accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(11)),
                  alignment: Alignment.center,
                  child: Icon(Icons.flag_outlined, color: accent, size: 20),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.title, style: textTheme.titleMedium),
                      Text(
                        goal.categoryName,
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                GoalStatusChip(status: goal.status),
              ],
            ),
            if (goal.description != null) ...[
              const SizedBox(height: AppSpacing.s),
              Text(goal.description!, style: textTheme.bodySmall),
            ],
            if (goal.startDate != null && goal.endDate != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${formatShortDate(goal.startDate!)} - ${formatShortDate(goal.endDate!)}',
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
            if (goal.checklistItems.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.s),
              for (final item in goal.checklistItems)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        item.status == GoalStatus.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                        size: 18,
                        color: item.status == GoalStatus.completed ? Colors.green.shade700 : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            decoration: item.status == GoalStatus.completed ? TextDecoration.lineThrough : null,
                            color: item.status == GoalStatus.completed ? colorScheme.onSurfaceVariant : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            if (goal.remarks != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                goal.remarks!,
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
