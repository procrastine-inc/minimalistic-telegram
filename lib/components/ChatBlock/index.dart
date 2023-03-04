import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/pages/ChatBasePage.dart';
import 'package:palestine_console/palestine_console.dart';
import 'package:tdlib/td_api.dart' as td_api;

class ChatBlock extends StatelessWidget {
  final td_api.Chat chat;

  const ChatBlock({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ChatAvatar(
        photo: chat.photo,
      ),
      title: ChatTopRow(title: chat.title),
      subtitle: const ChatMessagePreview(),
      // tileColor: theme.colorScheme.background,
      onTap: () {
        Navigator.push(context, CupertinoPageRoute(builder: (context) {
          return const ChatBasePage();
        }));
      },
      onLongPress: () {},
    );
  }
}

class ChatAvatar extends StatelessWidget {
  final td_api.ChatPhotoInfo? photo;
  const ChatAvatar({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    Print.black(photo?.small.local.path ?? '');
    return CircleAvatar(
      radius: 22,
      backgroundImage: photo?.minithumbnail?.data != null
          ? MemoryImage(base64Decode(photo!.minithumbnail!.data))
          : null,
    );
  }
}

class ChatTopRow extends StatelessWidget {
  final String title;

  const ChatTopRow({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(child: ChatTitle(title: title)),
        const ChatTimeAndStatus(),
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
  const ChatTimeAndStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Icon(
          Icons.done_all,
          size: 20,
        ),
        SizedBox(width: 3),
        Text("14:00"),
      ],
    );
  }
}

class ChatMessagePreview extends StatelessWidget {
  const ChatMessagePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("Hello!");
  }
}
