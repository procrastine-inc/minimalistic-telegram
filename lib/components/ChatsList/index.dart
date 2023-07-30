import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/components/ChatBlock/index.dart';
import 'package:minimalistic_telegram/stores/chat_store.dart';
import 'package:provider/provider.dart';
import 'package:tdlib/td_api.dart' as td_api;

import '../../models/ordered_chat.dart';

class ArchiveBlock extends StatelessWidget {
  const ArchiveBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.archive),
      ),
      title: const Text('Archive'),
      subtitle: const Text('Archived chats'),
      onTap: () {},
      onLongPress: () {},
    );
  }
}

class ChatsList extends StatefulWidget {
  const ChatsList({super.key});

  @override
  State<ChatsList> createState() => _ChatsListState();
}

class _ChatsListState extends State<ChatsList> {
  var chatIdsList = SplayTreeSet<OrderedChat>();
  List<StreamSubscription> subscriptions = [];
  @override
  void initState() {
    super.initState();
    var chatStore = context.read<ChatStore>();
    chatIdsList = chatStore.chatList;
    chatStore.getChatList(100);
    var subscription = chatStore
        .on()
        .where((event) => (event is td_api.UpdateNewChat ||
            event is td_api.UpdateChatPosition ||
            event is td_api.UpdateChatAction ||
            event is td_api.UpdateChatLastMessage ||
            event is td_api.UpdateChatDraftMessage))
        .listen(onChatListUpdate);
    subscriptions.add(subscription);
  }

  @override
  void dispose() {
    for (var element in subscriptions) {
      element.cancel();
    }
    subscriptions = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var chatStore = context.read<ChatStore>();
    return ListView.builder(
        itemCount: chatIdsList.length + 1,
        itemBuilder: ((context, index) {
          if (index == 0) {
            // return the header
            return const ArchiveBlock(
              key: ValueKey('archive'),
            );
          }
          index -= 1;
          var chatId = chatIdsList.elementAt(index).chatId;
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
