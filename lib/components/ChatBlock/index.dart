import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/pages/ChatBasePage.dart';
import 'package:minimalistic_telegram/utils/const.dart';
import 'package:tdlib/td_api.dart' as td_api;
import 'package:minimalistic_telegram/services/locator.dart';

import '../ChatAvatar/index.dart';
import 'chat_bottom_row.dart';
import 'chat_top_row.dart';

const sentIcon = Icon(
  Icons.done,
  size: 20,
  color: Colors.grey,
);

const sentAndReadIcon = Icon(
  Icons.done_all,
  size: 20,
  color: Colors.blue,
);

class ChatBlock extends StatelessWidget {
  final td_api.Chat chat;

  const ChatBlock({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    // debugger();
    return ListTile(
      leading: ChatAvatar(photo: chat.photo),
      title: ChatTopRow(chat: chat),
      subtitle: ChatBottomRow(chat: chat),
      // tileColor: theme.colorScheme.background,
      onTap: () {
        locator<NavigationService>()
            .navigator
            .pushNamed(chatRoute, arguments: chat);
        // Navigator.push(context, CupertinoPageRoute(builder: (context) {
        //   return ChatBasePage(chat: chat);
        // }));
      },
      onLongPress: () {},
    );
  }
}
