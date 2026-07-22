import '../../../core/data/dummy_json_loader.dart';
import '../models/chat_message.dart';

/// TODO(chat-api): replace with a real call to `Chat/GetMessages` (plus
/// wiring `SendMessage`/the SignalR hub for live updates) once that's
/// built - dummy JSON for now, same model either way.
class ChatRepository {
  Future<List<ChatMessage>> fetchMessages() async {
    final data = await loadDummyJsonList('assets/dummy/chat.json');
    final messages = data.map((item) => ChatMessage.fromJson(item as Map<String, dynamic>)).toList();
    messages.sort((a, b) => a.sentTime.compareTo(b.sentTime));
    return messages;
  }
}
