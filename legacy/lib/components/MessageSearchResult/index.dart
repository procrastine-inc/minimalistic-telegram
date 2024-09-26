import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/components/ChatAvatar/index.dart';
import 'package:minimalistic_telegram/components/ChatBlock/utils.dart';
import 'package:minimalistic_telegram/stores/chat_store.dart';
import 'package:provider/provider.dart';

import 'package:tdlib/td_api.dart' as td_api;

import '../MessageSubtitle/chat_message_subtitle.dart';

class MessageSearchResult extends StatelessWidget {
  final td_api.Message message;

  const MessageSearchResult({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final chatStore = context.read<ChatStore>();

    var chat = chatStore.items[message.chatId];

    if (chat == null) {
      return const SizedBox.shrink();
    }

    return ListTile(
      leading: ChatAvatar(
        smallPhoto: chat.photo?.small,
        minithumbnail: chat.photo?.minithumbnail,
      ),
      title: Text(chat.title),
      subtitle: ChatMessagePreview(
        message: message,
        draftMessage: null,
      ),
      trailing: Text(formatDate(message.date, context)),
    );
  }
}
