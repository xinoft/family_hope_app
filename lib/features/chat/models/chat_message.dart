/// Mirrors `ChatUserType` on the backend.
enum ChatSenderType {
  staff(1),
  parent(2);

  final int value;
  const ChatSenderType(this.value);

  static ChatSenderType fromInt(int value) => value == 2 ? ChatSenderType.parent : ChatSenderType.staff;
}

/// Mirrors `Chat/GetMessages`'s items - see
/// `InkersCore.Models.DataModels.ChatMessageData`. Dummy content for now -
/// see `ChatRepository`. v1 scope is a single general staff inbox (no
/// picking an individual recipient), so there's only ever one thread.
class ChatMessage {
  final String id;
  final ChatSenderType senderType;
  final String senderName;
  final String message;
  final DateTime sentTime;

  const ChatMessage({
    required this.id,
    required this.senderType,
    required this.senderName,
    required this.message,
    required this.sentTime,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: (json['Id'] ?? 0).toString(),
      senderType: ChatSenderType.fromInt(json['SenderUserType'] as int? ?? 1),
      senderName: json['SenderName'] as String? ?? '',
      message: json['Message'] as String? ?? '',
      sentTime: DateTime.tryParse(json['SentTime'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
