/// Mirrors the fields the backend actually returns from
/// `Student/GetStudentById` (`Result.Student` + `Result.Parent`) - see
/// `InkersCore.Models.RequestModels.StudentDetailRequest` /
/// `ParentDetailRequest`. Grade/class aren't included here because that
/// endpoint only returns their raw ids, not the human-readable master-data
/// labels `Student/GetStudentList` provides.
class Student {
  final String id;
  final String name;
  final String? studentCode;
  final String? qatarId;
  final DateTime? dateOfBirth;
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
      fatherName: parent?['FatherName'] as String?,
      motherName: parent?['MotherName'] as String?,
      parentMobileNumber: parent?['MobileNumber'] as String?,
      parentEmail: parent?['Email'] as String?,
    );
  }
}
