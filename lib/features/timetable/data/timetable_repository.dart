import '../../../core/data/dummy_json_loader.dart';
import '../models/timetable_slot.dart';

/// TODO(timetable-api): replace with a real call to
/// `ClassSchedule/GetTeacherSchedule` (or a student-scoped equivalent)
/// once that's wired up - dummy JSON for now, same model either way.
class TimetableRepository {
  Future<List<TimetableSlot>> fetchTimetable() async {
    final data = await loadDummyJsonList('assets/dummy/timetable.json');
    return data.map((item) => TimetableSlot.fromJson(item as Map<String, dynamic>)).toList();
  }
}
