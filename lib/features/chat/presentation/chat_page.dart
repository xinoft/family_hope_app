import 'package:flutter/material.dart';

import '../../../core/constants/app_module.dart';
import '../../../core/widgets/module_placeholder_page.dart';

/// v1 scope: parents message a single general staff inbox, no recipient
/// picker (see project chat-scoping notes) - a future iteration may add
/// messaging a child's assigned teacher/therapist directly.
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderPage(
      title: 'Chat',
      module: AppModule.chat,
    );
  }
}
