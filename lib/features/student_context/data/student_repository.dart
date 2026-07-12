import '../../../core/network/api_client.dart';
import '../models/student.dart';
import '../models/student_summary.dart';

class StudentRepository {
  final ApiClient _apiClient;

  StudentRepository(this._apiClient);

  Future<Student> fetchStudentById(String id) async {
    final result = await _apiClient.getResult('/Student/GetStudentById', queryParameters: {'id': id});
    return Student.fromApiResult(result as Map<String, dynamic>);
  }

  /// Used by staff to search for a student (e.g. to view their gallery).
  /// An empty [searchKeyword] returns every student.
  Future<List<StudentSummary>> searchStudents({String searchKeyword = ''}) async {
    final result = await _apiClient.getResult(
      '/Student/GetStudentList',
      queryParameters: {'SearchKeyword': searchKeyword},
    );
    return (result as List)
        .map((item) => StudentSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
