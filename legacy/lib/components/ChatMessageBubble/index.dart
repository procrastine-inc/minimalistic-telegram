import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palestine_console/palestine_console.dart';
import 'package:tdlib/td_api.dart' as td_api;
import 'package:flutter/foundation.dart';

class MessageBubble extends StatefulWidget {
  final td_api.Message message;

  MessageBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final _contextMenuController = ContextMenuController();
  var _tapPosition;

  @override
  void initState() {
    super.initState();
    // On web, disable the browser's context menu since this example uses a custom
    // Flutter-rendered context menu.
    if (kIsWeb) {
      BrowserContextMenu.disableContextMenu();
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      BrowserContextMenu.enableContextMenu();
    }
    super.dispose();
  }

  _buildContextMenu(BuildContext context, Offset offset) {
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: TextSelectionToolbarAnchors(
        primaryAnchor: offset,
      ),
      buttonItems: <ContextMenuButtonItem>[
        ContextMenuButtonItem(
          onPressed: () {
            ContextMenuController.removeAny();
          },
          label: 'Reply',
        ),
      ],
    );
  }

  void _show(Offset position) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu(
        context: context,
        position: RelativeRect.fromRect(
            _tapPosition & const Size(40, 40), // smaller rect, the touch area
            Offset.zero & overlay.size // Bigger rect, the entire screen
            ),
        items: [
          PopupMenuItem(
            value: 1,
            child: const ListTile(
              leading: Icon(Icons.reply),
              title: Text('Reply'),
            ),
            onTap: () {
              Print.green("Reply");
            },
          ),
          const PopupMenuItem(
            value: 2,
            child: ListTile(
              leading: Icon(Icons.forward_rounded),
              title: Text('Forward'),
            ),
          ),
          const PopupMenuItem(
            value: 3,
            child: ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit'),
            ),
          ),
          const PopupMenuItem(
            value: 4,
            child: ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete'),
            ),
          ),
        ]);
    // _contextMenuController.show(
    //   context: context,
    //   contextMenuBuilder: (context) => _buildContextMenu(context, position),
    // );
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  void _onTap() {
    _show(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _storePosition,
      onTap: _onTap,
      child: Container(
        padding:
            const EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
        child: Align(
          alignment: (widget.message.isOutgoing
              ? Alignment.topRight
              : Alignment.topLeft),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: (widget.message.isOutgoing
                  ? Colors.grey.shade200
                  : Colors.blue[200]),
            ),
            padding: const EdgeInsets.all(8),
            child: widget.message.content is td_api.MessageText
                ? Text(
                    (widget.message.content as td_api.MessageText).text.text,
                    style: const TextStyle(fontSize: 15),
                  )
                : const Text(
                    "Unsupported message type",
                    style: TextStyle(fontSize: 15),
                  ),
          ),
        ),
      ),
    );
  }
}
