import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:minimalistic_telegram/models/chatMessageModel.dart';
import 'package:minimalistic_telegram/stores/message_store.dart';
import 'package:palestine_console/palestine_console.dart';
import 'package:tdlib/td_api.dart' as td_api;
import 'package:provider/provider.dart';

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

  _topReachedHandler() {
    var messageStore = context.read<MessageStore>();
    var messagesByChat = messageStore.items[widget.chatId] ?? {};
    var lastMessage = messagesByChat.values.last;

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
    messageStore.on("messages", handleMessages);
    super.initState();
  }

  @override
  void dispose() {
    messageStore.off(td_api.UpdateNewMessage.CONSTRUCTOR, handleNewMessage);
    messageStore.off("messages", handleMessages);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var messageStore = context.read<MessageStore>();
    var messagesByChat = messageStore.items[widget.chatId] ?? {};
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
      elements: [...messagesByChat.values],
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
                backgroundColor: Colors.white,
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
