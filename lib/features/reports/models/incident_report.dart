import 'approval_status.dart';

/// Mirrors `Report/GetIncidentReportList`'s items - see
/// `InkersCore.Models.DataModels.IncidentReportData`.
///
/// `canEdit`/`canApproveReject` come from the backend but are computed
/// from the caller's JWT identity, which our dummy token can't provide
/// correctly - the app gates its own UI via `Capabilities` instead of
/// trusting these two fields (see `ReportsPage`).
class IncidentReport implements ReportLike {
  final String id;
  @override
  final String studentId;
  final String studentName;
  final String? title;
  final DateTime incidentDateTime;
  final String incidentDescription;
  final String? injuryDetails;
  final String? actions;
  final String? remarks;
  @override
  final ApprovalStatus approvalStatus;
  final String? approvalNote;
  final String? approvedRejectedByName;
  final String createdByName;

  const IncidentReport({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.title,
    required this.incidentDateTime,
    required this.incidentDescription,
    this.injuryDetails,
    this.actions,
    this.remarks,
    required this.approvalStatus,
    this.approvalNote,
    this.approvedRejectedByName,
    required this.createdByName,
  });

  @override
  DateTime get sortDate => incidentDateTime;

  factory IncidentReport.fromJson(Map<String, dynamic> json) {
    String? textOrNull(String key) {
      final value = json[key] as String?;
      return (value == null || value.isEmpty) ? null : value;
    }

    return IncidentReport(
      id: (json['Id'] ?? 0).toString(),
      studentId: (json['StudentId'] ?? 0).toString(),
      studentName: json['StudentName'] as String? ?? '',
      title: textOrNull('Title'),
      incidentDateTime: DateTime.tryParse(json['IncidentDateTime'] as String? ?? '') ?? DateTime.now(),
      incidentDescription: json['IncidentDescription'] as String? ?? '',
      injuryDetails: textOrNull('InjuryDetails'),
      actions: textOrNull('Actions'),
      remarks: textOrNull('Remarks'),
      approvalStatus: ApprovalStatus.fromInt(json['ApprovalStatus'] as int? ?? 1),
      approvalNote: textOrNull('ApprovalNote'),
      approvedRejectedByName: textOrNull('ApprovedRejectedByName'),
      createdByName: json['CreatedByName'] as String? ?? '',
    );
  }
}
