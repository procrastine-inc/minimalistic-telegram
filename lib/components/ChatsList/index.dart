import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/components/ChatBlock/index.dart';
import 'package:minimalistic_telegram/stores/chat_store.dart';
import 'package:provider/provider.dart';
import 'package:tdlib/td_api.dart' as td_api;

import '../../models/ordered_chat.dart';

class ChatsList extends StatefulWidget {
  const ChatsList({super.key});

  @override
  State<ChatsList> createState() => _ChatsListState();
}

class _ChatsListState extends State<ChatsList> {
  var chatList = SplayTreeSet<OrderedChat>();

  @override
  void initState() {
    super.initState();
    var chatStore = context.read<ChatStore>();
    chatList = chatStore.chatList;
    chatStore.getChatList(100);

    chatStore.on(td_api.UpdateNewChat.CONSTRUCTOR, onChatListUpdate);
    chatStore.on(td_api.UpdateChatAction.CONSTRUCTOR, onChatListUpdate);
    chatStore.on(td_api.UpdateChatLastMessage.CONSTRUCTOR, onChatListUpdate);
    chatStore.on(td_api.UpdateChatDraftMessage.CONSTRUCTOR, onChatListUpdate);
  }

  @override
  void dispose() {
    super.dispose();
    var chatStore = context.read<ChatStore>();

    chatStore.off(td_api.UpdateNewChat.CONSTRUCTOR, onChatListUpdate);
    chatStore.off(td_api.UpdateChatAction.CONSTRUCTOR, onChatListUpdate);
    chatStore.off(td_api.UpdateChatLastMessage.CONSTRUCTOR, onChatListUpdate);
    chatStore.off(td_api.UpdateChatDraftMessage.CONSTRUCTOR, onChatListUpdate);
  }

  @override
  Widget build(BuildContext context) {
    var chatStore = context.read<ChatStore>();
    return ListView.builder(
        itemCount: chatList.length,
        itemBuilder: ((context, index) {
          var chatId = chatList.elementAt(index).chatId;
          return ChatBlock(
              chat: chatStore.items[chatId]!, key: ValueKey(chatId));
        }));
    // return ListView(
    //     children: chatList
    //         .map((element) => ChatBlock(chatId: element.chatId))
    //         .toList());
  }

  void onChatListUpdate(_) {
    // var chatStore = context.read<ChatStore>();
    setState(() {
      // TODO: probably not needed, but we'll see
      // chatList = chatStore.chatList;
    });
  }
}
