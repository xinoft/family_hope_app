/// Mirrors the backend's `ApprovalPending`/`ApprovalApproved`/
/// `ApprovalRejected` constants (`ReportManager`) - shared by both
/// Incident and Progress reports.
enum ApprovalStatus {
  pending(1),
  approved(2),
  rejected(3);

  final int value;
  const ApprovalStatus(this.value);

  static ApprovalStatus fromInt(int value) => switch (value) {
        2 => ApprovalStatus.approved,
        3 => ApprovalStatus.rejected,
        _ => ApprovalStatus.pending,
      };
}

/// Common shape Incident and Progress reports both have, so list/filter
/// logic (see `ReportList`) is written once instead of twice.
abstract class ReportLike {
  String get studentId;
  ApprovalStatus get approvalStatus;
  DateTime get sortDate;
}
