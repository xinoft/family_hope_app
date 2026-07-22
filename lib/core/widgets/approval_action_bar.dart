import 'package:flutter/material.dart';

/// Approve/Reject (or Approve/Decline) row shown at the bottom of a
/// detail page for something pending review - shared by Reports (staff
/// approving a report) and Approvals (a parent responding to a request),
/// so the confirmation flow and its note prompt look and behave
/// identically everywhere approval happens.
///
/// Note: where this calls a backend endpoint that derives "who is
/// approving" from the caller's JWT identity, it may be rejected
/// server-side until real signed-JWT auth exists - see the caller's own
/// docs for whether that applies.
class ApprovalActionBar extends StatefulWidget {
  final Future<void> Function({required bool approve, String? note}) onDecide;
  final String itemNoun;
  final String declineLabel;

  const ApprovalActionBar({
    super.key,
    required this.onDecide,
    this.itemNoun = 'report',
    this.declineLabel = 'Reject',
  });

  @override
  State<ApprovalActionBar> createState() => _ApprovalActionBarState();
}

class _ApprovalActionBarState extends State<ApprovalActionBar> {
  bool _isSubmitting = false;

  Future<void> _handle(bool approve) async {
    final note = await _promptForNote(context, approve: approve);
    if (note == null) return; // cancelled

    setState(() => _isSubmitting = true);
    try {
      await widget.onDecide(approve: approve, note: note.isEmpty ? null : note);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// Returns the entered note, or `null` if the dialog was cancelled.
  Future<String?> _promptForNote(BuildContext context, {required bool approve}) async {
    final controller = TextEditingController();
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(approve ? 'Approve ${widget.itemNoun}?' : '${widget.declineLabel} ${widget.itemNoun}?'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Note (optional)'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: approve ? Colors.green.shade700 : Theme.of(dialogContext).colorScheme.error,
                foregroundColor: Colors.white,
                minimumSize: const Size(64, 40),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(approve ? 'Approve' : widget.declineLabel),
            ),
          ],
        ),
      );
      return confirmed == true ? controller.text.trim() : null;
    } finally {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSubmitting ? null : () => _handle(false),
            style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: Text(widget.declineLabel),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: _isSubmitting ? null : () => _handle(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.green.shade700),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Approve'),
          ),
        ),
      ],
    );
  }
}
