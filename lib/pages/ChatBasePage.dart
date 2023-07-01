import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/components/ChatAppBar/index.dart';

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
    var messageStore = context.read<MessageStore>();

    messageStore.getMessagesList(widget.chat.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade50,
      appBar: ChatAppBar(title: widget.chat.title),
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
          child: Container(
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
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Message",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.send,
                      color: Colors.blue.shade800,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
