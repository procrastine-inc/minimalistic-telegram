import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/models/chatMessageModel.dart';
import 'package:minimalistic_telegram/stores/message_store.dart';
import 'package:palestine_console/palestine_console.dart';
import 'package:tdlib/td_api.dart' as td_api;
import 'package:provider/provider.dart';

class ChatBasePage extends StatelessWidget {
  final td_api.Chat chat;
  const ChatBasePage({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade50,
      appBar: ChatAppBar(title: chat.title),
      body: ChatBody(chat: chat),
    );
  }
}

class ChatBody extends StatelessWidget {
  final td_api.Chat chat;

  const ChatBody({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ChatMessages(
          chatId: chat.id,
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

class ChatMessages extends StatelessWidget {
  final int chatId;

  const ChatMessages({
    super.key,
    required this.chatId,
  });

  @override
  Widget build(BuildContext context) {
    var messageStore = context.read<MessageStore>();
    var messagesByChat = messageStore.items[chatId] ?? {};
    return ListView(
      children: [
        ...messagesByChat.entries.map((message) =>
            MessageBubble(key: ValueKey(message.key), message: message.value))
      ],
    );
  }
}

class MessageBubble extends StatelessWidget {
  final td_api.Message message;

  const MessageBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
      child: Align(
        alignment:
            (message.isOutgoing ? Alignment.topRight : Alignment.topLeft),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color:
                (message.isOutgoing ? Colors.grey.shade200 : Colors.blue[200]),
          ),
          padding: const EdgeInsets.all(8),
          child: message.content is td_api.MessageText
              ? Text(
                  (message.content as td_api.MessageText).text.text,
                  style: const TextStyle(fontSize: 15),
                )
              : const Text(
                  "Unsupported message type",
                  style: TextStyle(fontSize: 15),
                ),
        ),
      ),
    );
  }
}

class ChatAppBar extends StatelessWidget with PreferredSizeWidget {
  final String title;

  const ChatAppBar({
    Key? key,
    this.title = "Chat",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(right: 16),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                width: 2,
              ),
              const CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://randomuser.me/api/portraits/women/5.jpg"),
                maxRadius: 20,
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    const Text(
                      "Online",
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            )),
        PopupMenuButton(
            color: Colors.white,
            itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Wrap(
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: const [
                        Icon(Icons.volume_up_outlined, color: Colors.grey),
                        Text("Mute"),
                      ],
                    ),
                  ),
                ])
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);
}
