/// Mirrors `Report/GetProgressReportTemplate`'s result - the blank
/// category/question structure configured for a student's grade (see
/// `InkersCore.Models.DataModels.ProgressReportData` used as a template
/// shape), ready to be filled in and saved as an actual report.
class ProgressReportTemplate {
  final String studentId;
  final String studentName;
  final List<ProgressReportTemplateCategory> categories;

  const ProgressReportTemplate({
    required this.studentId,
    required this.studentName,
    required this.categories,
  });

  factory ProgressReportTemplate.fromJson(Map<String, dynamic> json) {
    return ProgressReportTemplate(
      studentId: (json['StudentId'] ?? 0).toString(),
      studentName: json['StudentName'] as String? ?? '',
      categories: (json['Categories'] as List? ?? [])
          .map((item) => ProgressReportTemplateCategory.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProgressReportTemplateCategory {
  final String categoryName;
  final int displayOrder;
  final List<ProgressReportTemplateQuestion> questions;

  const ProgressReportTemplateCategory({
    required this.categoryName,
    required this.displayOrder,
    required this.questions,
  });

  factory ProgressReportTemplateCategory.fromJson(Map<String, dynamic> json) {
    return ProgressReportTemplateCategory(
      categoryName: json['CategoryName'] as String? ?? '',
      displayOrder: json['DisplayOrder'] as int? ?? 0,
      questions: (json['Questions'] as List? ?? [])
          .map((item) => ProgressReportTemplateQuestion.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProgressReportTemplateQuestion {
  final String questionText;
  final int displayOrder;

  const ProgressReportTemplateQuestion({required this.questionText, required this.displayOrder});

  factory ProgressReportTemplateQuestion.fromJson(Map<String, dynamic> json) {
    return ProgressReportTemplateQuestion(
      questionText: json['QuestionText'] as String? ?? '',
      displayOrder: json['DisplayOrder'] as int? ?? 0,
    );
  }
}
