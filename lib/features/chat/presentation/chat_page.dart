import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/user_type.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/providers/session_provider.dart';
import '../data/chat_repository.dart';
import '../models/chat_message.dart';
import 'widgets/chat_bubble.dart';

/// v1 scope: a single general staff inbox, no picking an individual
/// recipient (see project chat-scoping notes). Dummy content for now
/// (see `ChatRepository`'s TODO) - sending a message only appends it
/// locally, nothing is actually persisted or delivered yet.
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<ChatMessage> _messages = [];
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoading = true;
  String? _error;
  int _nextDummyId = 1000;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final messages = await context.read<ChatRepository>().fetchMessages();
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(messages);
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = "Couldn't load messages";
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _send(ChatSenderType myType, String myName) {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(
        id: '${_nextDummyId++}',
        senderType: myType,
        senderName: myName,
        message: text,
        sentTime: DateTime.now(),
      ));
      _textController.clear();
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionProvider>().currentUser;
    final myType = user?.userType == UserType.parent ? ChatSenderType.parent : ChatSenderType.staff;

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(AppSpacing.m),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return ChatBubble(message: message, isMine: message.senderType == myType);
                        },
                      ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(myType, user?.name ?? 'Me'),
                      decoration: const InputDecoration(hintText: 'Type a message'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  IconButton.filled(
                    onPressed: () => _send(myType, user?.name ?? 'Me'),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
