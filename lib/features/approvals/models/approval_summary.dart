/// Mirrors `Approval/GetApprovalList`'s items - see
/// `InkersCore.Models.DataModels.ApprovalListData`. Not scoped by grade
/// or student server-side - every approval for every grade comes back,
/// filtered client-side (see `ApprovalsPage`).
class ApprovalSummary {
  final String id;
  final String title;
  final String gradeId;
  final String grade;
  final String approvalType;
  final DateTime fromDate;
  final DateTime toDate;
  final DateTime respondBeforeDate;
  final int studentCount;
  final int pendingCount;
  final int approvedCount;
  final int rejectedCount;

  const ApprovalSummary({
    required this.id,
    required this.title,
    required this.gradeId,
    required this.grade,
    required this.approvalType,
    required this.fromDate,
    required this.toDate,
    required this.respondBeforeDate,
    required this.studentCount,
    required this.pendingCount,
    required this.approvedCount,
    required this.rejectedCount,
  });

  factory ApprovalSummary.fromJson(Map<String, dynamic> json) {
    return ApprovalSummary(
      id: (json['Id'] ?? 0).toString(),
      title: json['Title'] as String? ?? '',
      gradeId: (json['GradeId'] ?? 0).toString(),
      grade: json['Grade'] as String? ?? '',
      approvalType: json['ApprovalType'] as String? ?? '',
      fromDate: DateTime.tryParse(json['FromDate'] as String? ?? '') ?? DateTime.now(),
      toDate: DateTime.tryParse(json['ToDate'] as String? ?? '') ?? DateTime.now(),
      respondBeforeDate: DateTime.tryParse(json['RespondBeforeDate'] as String? ?? '') ?? DateTime.now(),
      studentCount: json['StudentCount'] as int? ?? 0,
      pendingCount: json['PendingCount'] as int? ?? 0,
      approvedCount: json['ApprovedCount'] as int? ?? 0,
      rejectedCount: json['RejectedCount'] as int? ?? 0,
    );
  }
}
