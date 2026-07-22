import 'package:flutter/material.dart';

import '../../models/approval_response_status.dart';

class ApprovalResponseChip extends StatelessWidget {
  final ApprovalResponseStatus status;

  const ApprovalResponseChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ApprovalResponseStatus.pending => ('Pending', Colors.amber.shade800),
      ApprovalResponseStatus.approved => ('Approved', Colors.green.shade700),
      ApprovalResponseStatus.rejected => ('Declined', Colors.red.shade700),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}
