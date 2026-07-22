import 'approval_response_status.dart';
import 'approval_summary.dart';

/// Mirrors `Approval/GetApprovalById`'s result - see
/// `InkersCore.Models.DataModels.ApprovalDetailData` (which extends
/// `ApprovalListData` on the backend; here that's just [summary] plus the
/// two detail-only fields).
class ApprovalDetail {
  final ApprovalSummary summary;
  final String description;
  final List<ApprovalStudentResponse> students;

  const ApprovalDetail({required this.summary, required this.description, required this.students});

  factory ApprovalDetail.fromJson(Map<String, dynamic> json) {
    return ApprovalDetail(
      summary: ApprovalSummary.fromJson(json),
      description: json['Description'] as String? ?? '',
      students: (json['Students'] as List? ?? [])
          .map((item) => ApprovalStudentResponse.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// One student's response within an approval - see
/// `InkersCore.Models.DataModels.ApprovalStudentData`. `mappingId` is what
/// `Approval/UpdateParentResponse` needs to record a parent's decision.
class ApprovalStudentResponse {
  final String mappingId;
  final String studentId;
  final String studentName;
  final String? parentName;
  final ApprovalResponseStatus responseStatus;
  final String? responseRemarks;
  final DateTime? respondedTime;

  const ApprovalStudentResponse({
    required this.mappingId,
    required this.studentId,
    required this.studentName,
    this.parentName,
    required this.responseStatus,
    this.responseRemarks,
    this.respondedTime,
  });

  factory ApprovalStudentResponse.fromJson(Map<String, dynamic> json) {
    final respondedTime = json['RespondedTime'] as String?;
    return ApprovalStudentResponse(
      mappingId: (json['MappingId'] ?? 0).toString(),
      studentId: (json['StudentId'] ?? 0).toString(),
      studentName: json['StudentName'] as String? ?? '',
      parentName: json['ParentName'] as String?,
      responseStatus: ApprovalResponseStatus.fromInt(json['ResponseStatus'] as int? ?? 1),
      responseRemarks: json['ResponseRemarks'] as String?,
      respondedTime: respondedTime != null ? DateTime.tryParse(respondedTime) : null,
    );
  }
}
