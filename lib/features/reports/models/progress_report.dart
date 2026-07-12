import 'approval_status.dart';

/// Mirrors `Report/GetProgressReportList`'s items - see
/// `InkersCore.Models.DataModels.ProgressReportData`. Unlike the
/// template, every category/question here carries a real id (needed to
/// edit an existing report) and each question has its filled-in A-E
/// `grade`.
class ProgressReport implements ReportLike {
  final String id;
  @override
  final String studentId;
  final String studentName;
  final String? title;
  final DateTime reportDate;
  @override
  final ApprovalStatus approvalStatus;
  final String? approvalNote;
  final String? approvedRejectedByName;
  final String createdByName;
  final List<ProgressReportCategory> categories;

  const ProgressReport({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.title,
    required this.reportDate,
    required this.approvalStatus,
    this.approvalNote,
    this.approvedRejectedByName,
    required this.createdByName,
    required this.categories,
  });

  @override
  DateTime get sortDate => reportDate;

  factory ProgressReport.fromJson(Map<String, dynamic> json) {
    String? textOrNull(String key) {
      final value = json[key] as String?;
      return (value == null || value.isEmpty) ? null : value;
    }

    return ProgressReport(
      id: (json['Id'] ?? 0).toString(),
      studentId: (json['StudentId'] ?? 0).toString(),
      studentName: json['StudentName'] as String? ?? '',
      title: textOrNull('Title'),
      reportDate: DateTime.tryParse(json['ReportDate'] as String? ?? '') ?? DateTime.now(),
      approvalStatus: ApprovalStatus.fromInt(json['ApprovalStatus'] as int? ?? 1),
      approvalNote: textOrNull('ApprovalNote'),
      approvedRejectedByName: textOrNull('ApprovedRejectedByName'),
      createdByName: json['CreatedByName'] as String? ?? '',
      categories: (json['Categories'] as List? ?? [])
          .map((item) => ProgressReportCategory.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProgressReportCategory {
  final String categoryName;
  final String? remarks;
  final List<ProgressReportQuestion> questions;

  const ProgressReportCategory({required this.categoryName, this.remarks, required this.questions});

  factory ProgressReportCategory.fromJson(Map<String, dynamic> json) {
    final remarks = json['Remarks'] as String?;
    return ProgressReportCategory(
      categoryName: json['CategoryName'] as String? ?? '',
      remarks: (remarks == null || remarks.isEmpty) ? null : remarks,
      questions: (json['Questions'] as List? ?? [])
          .map((item) => ProgressReportQuestion.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProgressReportQuestion {
  final String questionText;
  final String grade;

  const ProgressReportQuestion({required this.questionText, required this.grade});

  factory ProgressReportQuestion.fromJson(Map<String, dynamic> json) {
    return ProgressReportQuestion(
      questionText: json['QuestionText'] as String? ?? '',
      grade: json['Grade'] as String? ?? '',
    );
  }
}
