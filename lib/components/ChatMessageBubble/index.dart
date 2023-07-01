import 'package:flutter/material.dart';
import 'package:tdlib/td_api.dart' as td_api;

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
