import 'package:flutter/material.dart';

import '../../models/approval_status.dart';

/// Small colored pill shown on every report card/detail view - the one
/// place approval-status colors/labels are defined, so Incident and
/// Progress reports (and list vs. detail) always look the same.
class ApprovalStatusChip extends StatelessWidget {
  final ApprovalStatus status;

  const ApprovalStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ApprovalStatus.pending => ('Pending', Colors.amber.shade800),
      ApprovalStatus.approved => ('Approved', Colors.green.shade700),
      ApprovalStatus.rejected => ('Rejected', Colors.red.shade700),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
