import 'package:flutter/material.dart';

import '../../../../core/constants/app_module.dart';
import '../../../../core/theme/app_module_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;

  const ChatBubble({super.key, required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = AppModuleColors.of(AppModule.chat);
    final bubbleColor = isMine ? accent : colorScheme.surfaceContainerHighest;
    final textColor = isMine ? Colors.white : colorScheme.onSurface;
    final time = '${message.sentTime.hour.toString().padLeft(2, '0')}:${message.sentTime.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMine)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  message.senderName,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant),
                ),
              ),
            Text(message.message, style: TextStyle(color: textColor)),
            const SizedBox(height: 2),
            Text(
              time,
              style: TextStyle(fontSize: 11, color: isMine ? Colors.white70 : colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
