import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:palestine_console/palestine_console.dart';
import 'package:provider/provider.dart';
import 'package:tdlib/td_api.dart' as td_api;

import '../../stores/message_store.dart';
import '../ChatMessageBubble/index.dart';

class ChatMessages extends StatefulWidget {
  final int chatId;

  const ChatMessages({
    super.key,
    required this.chatId,
  });

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  late ScrollController _controller;
  late MessageStore messageStore;
  handleNewMessage(td_api.UpdateNewMessage message) {
    if (message.message.chatId == widget.chatId) {
      setState(() => {});
    }
  }

  handleDeleteMessages(td_api.UpdateDeleteMessages messages) {
    if (messages.chatId == widget.chatId) {
      setState(() => {});
    }
  }

  _topReachedHandler() {
    var messageStore = context.read<MessageStore>();
    var messagesByChat = messageStore.items[widget.chatId] ?? {};
    var lastMessage = messagesByChat.values.last;
    lastMessage.schedulingState;

    messageStore.getMessagesList(widget.chatId, fromMessageId: lastMessage.id);
    Print.yellow('top reached');
  }

  _bottomReachedHandler() {
    Print.yellow('bottom reached');
  }

  _scrollListener() {
    var topReached =
        _controller.offset >= _controller.position.maxScrollExtent &&
            !_controller.position.outOfRange;
    var bottomReached =
        _controller.offset <= _controller.position.minScrollExtent &&
            !_controller.position.outOfRange;

    if (topReached) _topReachedHandler();

    if (bottomReached) _bottomReachedHandler();
  }

  handleMessages(_) {
    setState(() => {});
  }

  @override
  void initState() {
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    messageStore = context.read<MessageStore>();
    messageStore.on(td_api.UpdateNewMessage.CONSTRUCTOR, handleNewMessage);
    messageStore.on(
        td_api.UpdateDeleteMessages.CONSTRUCTOR, handleDeleteMessages);
    messageStore.on("messages", handleMessages);
    super.initState();
  }

  @override
  void dispose() {
    messageStore.off(td_api.UpdateNewMessage.CONSTRUCTOR, handleNewMessage);
    messageStore.off("messages", handleMessages);
    messageStore.off(
        td_api.UpdateDeleteMessages.CONSTRUCTOR, handleDeleteMessages);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var messageStore = context.read<MessageStore>();
    var messagesByChat = messageStore.items[widget.chatId] ?? (SplayTreeMap());
    return GroupedListView<td_api.Message, DateTime>(
      controller: _controller,
      padding: const EdgeInsets.all(8),
      groupBy: (message) => DateUtils.dateOnly(
          DateTime.fromMillisecondsSinceEpoch(message.date * 1000)),
      useStickyGroupSeparators: true,
      reverse: true,
      order: GroupedListOrder.DESC,
      floatingHeader: true,
      groupHeaderBuilder: (message) => SizedBox(
        height: 40,
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                DateFormat.yMMMd().format(
                    DateTime.fromMillisecondsSinceEpoch(message.date * 1000)),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ),
      itemBuilder: (context, message) => MessageBubble(
        key: ValueKey(message.id),
        message: message,
      ),
      elements: messagesByChat.values.toList(),
    );
  }
}
