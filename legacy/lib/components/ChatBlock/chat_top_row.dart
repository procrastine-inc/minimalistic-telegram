import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:palestine_console/palestine_console.dart';
import 'package:tdlib/td_api.dart' as td_api;

import 'utils.dart';

class ChatTopRow extends StatelessWidget {
  final td_api.Chat chat;

  const ChatTopRow({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    var messageRead = chat.lastReadOutboxMessageId == chat.lastMessage?.id;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(child: ChatTitle(title: chat.title)),
        const SizedBox(
          width: 40,
        ),
        ChatTimeAndStatus(
            date: chat.draftMessage?.date ?? chat.lastMessage?.date ?? 0,
            isOutgoing: chat.lastMessage?.isOutgoing ?? false,
            isRead: messageRead,
            sendingState: chat.lastMessage?.sendingState),
      ],
    );
  }
}

class ChatTitle extends StatelessWidget {
  final String title;
  const ChatTitle({super.key, required this.title});

  final isCommunity = true;
  final isBot = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isCommunity)
          const Icon(
            Icons.people_alt,
            size: 20,
          ),
        if (isBot)
          const Icon(
            Icons.smart_toy_outlined,
            size: 20,
          ),
        Flexible(
            child: Text(
          title,
          overflow: TextOverflow.fade,
          softWrap: false,
        )),
        const SizedBox(
          width: 5,
        ),
        const Icon(
          CupertinoIcons.volume_off,
          size: 14,
        ),
      ],
    );
  }
}

class ChatTimeAndStatus extends StatelessWidget {
  final int date;

  final bool isOutgoing;

  final td_api.MessageSendingState? sendingState;

  final bool isRead;

  const ChatTimeAndStatus(
      {super.key,
      required this.date,
      required this.sendingState,
      required this.isOutgoing,
      required this.isRead});

  @override
  Widget build(BuildContext context) {
    var messageSent = sendingState is! td_api.MessageSendingStatePending &&
        sendingState is! td_api.MessageSendingStateFailed;
    var messageSending = sendingState is td_api.MessageSendingStatePending;

    var messageFailed = sendingState is td_api.MessageSendingStateFailed;
    return Row(
      children: [
        if (!isOutgoing)
          ...[]
        else if (messageFailed) ...[
          const Icon(
            Icons.error_outline,
            size: 20,
            color: Colors.red,
          )
        ] else if (messageSending) ...[
          const Icon(
            Icons.access_time,
            size: 20,
            color: Colors.grey,
          )
        ] else if (isRead) ...[
          const Icon(
            Icons.done_all,
            size: 20,
            color: Colors.blue,
          )
        ] else if (messageSent) ...[
          const Icon(
            Icons.done,
            size: 20,
            color: Colors.blue,
          )
        ],
        const SizedBox(width: 3),
        Text(formatDate(date, context))
      ],
    );
  }
}
