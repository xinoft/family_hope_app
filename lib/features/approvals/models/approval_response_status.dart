/// Mirrors `ApprovalResponseStatus` on the backend (a parent's response
/// to one approval request for one student).
enum ApprovalResponseStatus {
  pending(1),
  approved(2),
  rejected(3);

  final int value;
  const ApprovalResponseStatus(this.value);

  static ApprovalResponseStatus fromInt(int value) => switch (value) {
        2 => ApprovalResponseStatus.approved,
        3 => ApprovalResponseStatus.rejected,
        _ => ApprovalResponseStatus.pending,
      };
}
