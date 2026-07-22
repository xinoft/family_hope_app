import 'package:flutter/material.dart';

import '../../models/student_goal.dart';

class GoalStatusChip extends StatelessWidget {
  final GoalStatus status;

  const GoalStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      GoalStatus.pending => ('Pending', Colors.amber.shade800),
      GoalStatus.completed => ('Completed', Colors.green.shade700),
      GoalStatus.onHold => ('On Hold', Colors.blueGrey.shade600),
      GoalStatus.canceled => ('Canceled', Colors.red.shade700),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}
