import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/components/ChatAppBar/index.dart';
import 'package:minimalistic_telegram/services/isar_service.dart';

import 'package:minimalistic_telegram/stores/message_store.dart';
import 'package:palestine_console/palestine_console.dart';
import 'package:tdlib/td_api.dart' as td_api;
import 'package:provider/provider.dart';

import '../components/ChatMessages/index.dart';

class ChatBasePage extends StatefulWidget {
  final td_api.Chat chat;
  const ChatBasePage({super.key, required this.chat});

  @override
  State<ChatBasePage> createState() => _ChatBasePageState();
}

class _ChatBasePageState extends State<ChatBasePage> {
  @override
  void initState() {
    super.initState();
    var dbservice = IsarService();
    dbservice.addChatOpened(widget.chat);
    var messageStore = context.read<MessageStore>();

    final chatId = widget.chat.id;
    var messagesList = messageStore.items[chatId];
    if (messagesList == null ||
        messagesList.isEmpty ||
        messagesList.length < 2) {
      messageStore.getMessagesList(chatId);
    }
  }

  @override
  void dispose() {
    super.dispose();
    var dbservice = IsarService();
    dbservice.addChatClosed(widget.chat);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade50,
      appBar: ChatAppBar(chat: widget.chat),
      body: ChatBody(chat: widget.chat),
    );
  }
}

class ChatBody extends StatelessWidget {
  final td_api.Chat chat;

  const ChatBody({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ChatMessages(
            chatId: chat.id,
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: ChatInput(chatId: chat.id),
        ),
      ],
    );
  }
}

class ChatInput extends StatefulWidget {
  final int chatId;

  const ChatInput({
    Key? key,
    required this.chatId,
  }) : super(key: key);

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final fieldText = TextEditingController();

  @override
  void initState() {
    super.initState();
    // TODO: this rebuild whole widget tree, find a better way
    fieldText.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    fieldText.dispose();
    super.dispose();
  }

  _handleTextMessageSendTap() {
    var messageStore = context.read<MessageStore>();
    var textFieldValue = fieldText.text;
    fieldText.clear();
    Print.green(textFieldValue.length.toString());
    messageStore.sendMessage(
        widget.chatId,
        td_api.InputMessageText(
          text: td_api.FormattedText(
            text: textFieldValue,
            entities: [],
          ),
          disableWebPagePreview: false,
          clearDraft: true,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.cyan.shade100,
      height: 50,
      width: double.infinity,
      // color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.sentiment_satisfied_alt_outlined),
            onPressed: () {},
            color: Colors.grey,
          ),
          Expanded(
            child: TextField(
              controller: fieldText,
              decoration: const InputDecoration(
                hintText: "Message",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
              onPressed:
                  fieldText.text.isNotEmpty ? _handleTextMessageSendTap : null,
              icon: Icon(
                Icons.send,
                color: Colors.blue.shade800,
              )),
        ],
      ),
    );
  }
}
