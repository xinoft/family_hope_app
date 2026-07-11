import '../../../core/network/api_client.dart';
import '../models/student.dart';

class StudentRepository {
  final ApiClient _apiClient;

  StudentRepository(this._apiClient);

  Future<Student> fetchStudentById(String id) async {
    final result = await _apiClient.getResult('/Student/GetStudentById', queryParameters: {'id': id});
    return Student.fromApiResult(result as Map<String, dynamic>);
  }
}
