import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/models/chatMessageModel.dart';

List<ChatMessage> messages = [
  ChatMessage(messageContent: "Hello, Will", messageType: "receiver"),
  ChatMessage(messageContent: "How have you been?", messageType: "receiver"),
  ChatMessage(
      messageContent: "Hey Kriss, I am doing fine dude. wbu?",
      messageType: "sender"),
  ChatMessage(messageContent: "ehhhh, doing OK.", messageType: "receiver"),
  ChatMessage(
      messageContent: "Is there any thing wrong?", messageType: "sender"),
];

class ChatBasePage extends StatefulWidget {
  const ChatBasePage({super.key});

  @override
  _ChatBasePageState createState() => _ChatBasePageState();
}

class _ChatBasePageState extends State<ChatBasePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade50,
      appBar: const ChatAppBar(),
      body: const ChatBody(),
    );
  }
}

class ChatBody extends StatelessWidget {
  const ChatBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const ChatMessages(),
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
  const ChatMessages({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ...messages.map((e) =>
            ChatBubble(message: e.messageContent, messageType: e.messageType))
      ],
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final String messageType;
  const ChatBubble({
    Key? key,
    required this.message,
    required this.messageType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
      child: Align(
        alignment: (messageType == "receiver"
            ? Alignment.topLeft
            : Alignment.topRight),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: (messageType == "receiver"
                ? Colors.grey.shade200
                : Colors.blue[200]),
          ),
          padding: const EdgeInsets.all(8),
          child: Text(
            message,
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ),
    );
  }
}

class ChatAppBar extends StatelessWidget with PreferredSizeWidget {
  const ChatAppBar({
    Key? key,
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
                  children: const <Widget>[
                    Text(
                      "Victoria",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
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
