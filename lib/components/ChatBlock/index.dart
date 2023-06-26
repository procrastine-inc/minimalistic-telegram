import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/components/MessageSubtitle/chat_message_subtitle.dart';
import 'package:minimalistic_telegram/pages/ChatBasePage.dart';
import 'package:palestine_console/palestine_console.dart';
import 'package:tdlib/td_api.dart' as td_api;

class ChatBlock extends StatelessWidget {
  final td_api.Chat chat;

  const ChatBlock({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    // debugger();
    return ListTile(
      leading: ChatAvatar(
        photo: chat.photo,
      ),
      title: ChatTopRow(
          title: chat.title,
          date: chat.lastMessage?.date ??
              chat.draftMessage?.date ??
              chat.lastReadInboxMessageId),
      subtitle: ChatMessageSubtitle(
          message: chat.lastMessage, draftMessage: chat.draftMessage),
      // tileColor: theme.colorScheme.background,
      onTap: () {
        Navigator.push(context, CupertinoPageRoute(builder: (context) {
          return ChatBasePage(chat: chat);
        }));
      },
      onLongPress: () {},
    );
  }
}

class ChatAvatar extends StatefulWidget {
  final td_api.ChatPhotoInfo? photo;
  const ChatAvatar({super.key, required this.photo});

  @override
  State<ChatAvatar> createState() => _ChatAvatarState();
}

class _ChatAvatarState extends State<ChatAvatar> {
  late MemoryImage? backgroundImage;

  @override
  void initState() {
    super.initState();
    backgroundImage = widget.photo?.minithumbnail?.data != null
        ? MemoryImage(base64Decode(widget.photo!.minithumbnail!.data))
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundImage: backgroundImage,
    );
  }
}

class ChatTopRow extends StatelessWidget {
  final String title;

  final int date;

  const ChatTopRow({super.key, required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(child: ChatTitle(title: title)),
        ChatTimeAndStatus(date: date),
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
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        )),
        const Icon(
          CupertinoIcons.volume_off,
          size: 14,
        ),
        const SizedBox(
          width: 40,
        ),
      ],
    );
  }
}

class ChatTimeAndStatus extends StatelessWidget {
  final int date;
  const ChatTimeAndStatus({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Icon(
          Icons.done_all,
          size: 20,
        ),
        SizedBox(width: 3),
        // TODO: add INTL
        Text("14:00"),
      ],
    );
  }
}
