import '../../../core/data/dummy_json_loader.dart';
import '../models/meeting.dart';

/// TODO(meetings-api): replace with a real call to `Meeting/GetMeetings`
/// once that's wired up - dummy JSON for now, same model either way.
class MeetingsRepository {
  Future<List<Meeting>> fetchMeetings() async {
    final data = await loadDummyJsonList('assets/dummy/meetings.json');
    final meetings = data.map((item) => Meeting.fromJson(item as Map<String, dynamic>)).toList();
    meetings.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    return meetings;
  }
}
