/// Mirrors the fields the backend actually returns from
/// `Student/GetStudentById` (`Result.Student` + `Result.Parent`) - see
/// `InkersCore.Models.RequestModels.StudentDetailRequest` /
/// `ParentDetailRequest`. Only `gradeId` (a raw id) is carried from
/// grade/class - the human-readable label isn't in this endpoint's
/// response, only `Student/GetStudentList`'s.
class Student {
  final String id;
  final String name;
  final String? studentCode;
  final String? qatarId;
  final DateTime? dateOfBirth;
  final String? gradeId;
  final String? fatherName;
  final String? motherName;
  final String? parentMobileNumber;
  final String? parentEmail;

  const Student({
    required this.id,
    required this.name,
    this.studentCode,
    this.qatarId,
    this.dateOfBirth,
    this.gradeId,
    this.fatherName,
    this.motherName,
    this.parentMobileNumber,
    this.parentEmail,
  });

  /// [result] is the `Result` payload of `Student/GetStudentById`'s
  /// `CommonResponse` - shaped like `{ "Student": {...}, "Parent": {...} }`.
  factory Student.fromApiResult(Map<String, dynamic> result) {
    final student = result['Student'] as Map<String, dynamic>?;
    final parent = result['Parent'] as Map<String, dynamic>?;
    final dob = student?['DateOfBirth'] as String?;

    return Student(
      id: (student?['Id'] ?? 0).toString(),
      name: (student?['StudentName'] as String?)?.trim().isNotEmpty == true
          ? student!['StudentName'] as String
          : 'Student',
      studentCode: student?['StudentCode'] as String?,
      qatarId: student?['QatarId'] as String?,
      dateOfBirth: dob != null ? DateTime.tryParse(dob) : null,
      gradeId: student?['GradeId']?.toString(),
      fatherName: parent?['FatherName'] as String?,
      motherName: parent?['MotherName'] as String?,
      parentMobileNumber: parent?['MobileNumber'] as String?,
      parentEmail: parent?['Email'] as String?,
    );
  }
}
