import 'dart:math';

import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/components/ChatBlock/index.dart';
import 'package:provider/provider.dart';

class ChatsList extends StatelessWidget {
  const ChatsList({super.key});

  @override
  Widget build(BuildContext context) {
    // var mainChatsList = context.read<TelegramService>().mainChatsList;
    // var allChats = context.read<TelegramService>().chats;

    return ListView(children: const [
      ListTile(
        title: Text('Im woking'),
      )
    ]

        // mainChatsList
        //     .map((element) => ChatBlock(
        //           username: allChats[element.chatId]?.title ?? '',
        //         ))
        //     .toList()

        );
  }
}
