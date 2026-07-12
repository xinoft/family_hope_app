import '../../../core/network/api_client.dart';
import '../models/approval_status.dart';
import '../models/incident_report.dart';
import '../models/progress_report.dart';
import '../models/progress_report_template.dart';

class ReportRepository {
  final ApiClient _apiClient;

  ReportRepository(this._apiClient);

  // -- Incident reports -----------------------------------------------

  /// Not filtered by student or approval status - the backend returns
  /// every incident report for every student. Callers filter client-side
  /// (see `ReportsPage`).
  Future<List<IncidentReport>> fetchIncidentReports() async {
    final result = await _apiClient.getResult('/Report/GetIncidentReportList');
    return (result as List)
        .map((item) => IncidentReport.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveIncidentReport({
    required String studentId,
    String? title,
    required DateTime incidentDateTime,
    required String incidentDescription,
    String? injuryDetails,
    String? actions,
    String? remarks,
  }) async {
    await _apiClient.postResult(
      '/Report/SaveIncidentReport',
      data: {
        'Id': 0,
        'StudentId': int.parse(studentId),
        if (title != null && title.trim().isNotEmpty) 'Title': title.trim(),
        'IncidentDateTime': incidentDateTime.toIso8601String(),
        'IncidentDescription': incidentDescription.trim(),
        if (injuryDetails != null && injuryDetails.trim().isNotEmpty) 'InjuryDetails': injuryDetails.trim(),
        if (actions != null && actions.trim().isNotEmpty) 'Actions': actions.trim(),
        if (remarks != null && remarks.trim().isNotEmpty) 'Remarks': remarks.trim(),
      },
    );
  }

  Future<void> updateIncidentReportApproval({
    required String id,
    required bool approve,
    String? approvalNote,
  }) async {
    await _apiClient.postResult(
      '/Report/UpdateIncidentReportApproval',
      data: {
        'Id': int.parse(id),
        'ApprovalStatus': approve ? ApprovalStatus.approved.value : ApprovalStatus.rejected.value,
        if (approvalNote != null && approvalNote.trim().isNotEmpty) 'ApprovalNote': approvalNote.trim(),
      },
    );
  }

  // -- Progress reports -------------------------------------------------

  /// Same caveat as incident reports - unfiltered, filter client-side.
  Future<List<ProgressReport>> fetchProgressReports() async {
    final result = await _apiClient.getResult('/Report/GetProgressReportList');
    return (result as List)
        .map((item) => ProgressReport.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// The blank category/question structure configured for this student's
  /// grade, ready to be filled in and submitted via [saveProgressReport].
  Future<ProgressReportTemplate> fetchProgressReportTemplate(String studentId) async {
    final result = await _apiClient.getResult(
      '/Report/GetProgressReportTemplate',
      queryParameters: {'studentId': studentId},
    );
    return ProgressReportTemplate.fromJson(result as Map<String, dynamic>);
  }

  Future<void> saveProgressReport({
    required String studentId,
    String? title,
    required DateTime reportDate,
    required List<ProgressReportCategorySubmission> categories,
  }) async {
    await _apiClient.postResult(
      '/Report/SaveProgressReport',
      data: {
        'Id': 0,
        'StudentId': int.parse(studentId),
        if (title != null && title.trim().isNotEmpty) 'Title': title.trim(),
        'ReportDate': reportDate.toIso8601String(),
        'Categories': [
          for (var i = 0; i < categories.length; i++)
            {
              'Id': 0,
              'CategoryName': categories[i].categoryName,
              'DisplayOrder': i + 1,
              if (categories[i].remarks != null && categories[i].remarks!.trim().isNotEmpty)
                'Remarks': categories[i].remarks!.trim(),
              'Questions': [
                for (var j = 0; j < categories[i].questions.length; j++)
                  {
                    'Id': 0,
                    'QuestionText': categories[i].questions[j].questionText,
                    'DisplayOrder': j + 1,
                    'Grade': categories[i].questions[j].grade,
                  },
              ],
            },
        ],
      },
    );
  }

  Future<void> updateProgressReportApproval({
    required String id,
    required bool approve,
    String? approvalNote,
  }) async {
    await _apiClient.postResult(
      '/Report/UpdateProgressReportApproval',
      data: {
        'Id': int.parse(id),
        'ApprovalStatus': approve ? ApprovalStatus.approved.value : ApprovalStatus.rejected.value,
        if (approvalNote != null && approvalNote.trim().isNotEmpty) 'ApprovalNote': approvalNote.trim(),
      },
    );
  }
}

/// A filled-in category, built from a [ProgressReportTemplateCategory] by
/// the create-report form, ready to submit.
class ProgressReportCategorySubmission {
  final String categoryName;
  final String? remarks;
  final List<ProgressReportQuestionSubmission> questions;

  const ProgressReportCategorySubmission({
    required this.categoryName,
    this.remarks,
    required this.questions,
  });
}

class ProgressReportQuestionSubmission {
  final String questionText;
  final String grade;

  const ProgressReportQuestionSubmission({required this.questionText, required this.grade});
}
