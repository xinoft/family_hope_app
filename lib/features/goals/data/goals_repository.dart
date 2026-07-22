import '../../../core/data/dummy_json_loader.dart';
import '../models/student_goal.dart';

/// TODO(goals-api): replace with a real call to `Goal/GetStudentGoals`
/// once that's wired up - dummy JSON for now, same model either way.
class GoalsRepository {
  Future<List<StudentGoal>> fetchGoals() async {
    final data = await loadDummyJsonList('assets/dummy/goals.json');
    return data.map((item) => StudentGoal.fromJson(item as Map<String, dynamic>)).toList();
  }
}
