import 'package:flutter/material.dart';
import 'package:tdlib/td_api.dart' as td_api;

import '../MessageSubtitle/chat_message_subtitle.dart';

class ChatBottomRow extends StatelessWidget {
  const ChatBottomRow({
    Key? key,
    required this.chat,
  }) : super(key: key);

  final td_api.Chat chat;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ChatMessagePreview(
            message: chat.lastMessage,
            draftMessage: chat.draftMessage,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        ChatUnreadCount(
          unreadCount: chat.unreadCount,
        ),
      ],
    );
  }
}

class ChatUnreadCount extends StatelessWidget {
  final int unreadCount;
  const ChatUnreadCount({Key? key, required this.unreadCount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return unreadCount > 0
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              unreadCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
