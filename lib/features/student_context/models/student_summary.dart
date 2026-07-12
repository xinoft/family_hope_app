/// A lightweight student record for search/picker lists - mirrors
/// `Student/GetStudentList`'s items (`InkersCore.Models.DataModels.
/// StudentListData`), which already includes human-readable grade/class
/// labels (unlike `Student/GetStudentById`'s detail shape).
class StudentSummary {
  final String id;
  final String name;
  final String? grade;
  final String? studentClass;

  const StudentSummary({
    required this.id,
    required this.name,
    this.grade,
    this.studentClass,
  });

  String get gradeAndClass => [grade, studentClass].where((s) => s != null && s.isNotEmpty).join(' - ');

  factory StudentSummary.fromJson(Map<String, dynamic> json) {
    return StudentSummary(
      id: (json['Id'] ?? 0).toString(),
      name: json['StudentName'] as String? ?? 'Student',
      grade: json['Grade'] as String?,
      studentClass: json['Class'] as String?,
    );
  }
}
