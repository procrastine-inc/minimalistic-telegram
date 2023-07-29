import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/components/MessageSubtitle/chat_message_subtitle.dart';
import 'package:minimalistic_telegram/controllers/tdlib_controller.dart';
import 'package:minimalistic_telegram/pages/ChatBasePage.dart';
import 'package:minimalistic_telegram/stores/file_store.dart';
import 'package:palestine_console/palestine_console.dart';
import 'package:tdlib/td_api.dart' as td_api;

class ChatBlock extends StatelessWidget {
  final td_api.Chat chat;

  const ChatBlock({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    // debugger();
    return ListTile(
      leading: ChatAvatar(
        photo: chat.photo,
      ),
      title: ChatTopRow(
          title: chat.title,
          date: chat.lastMessage?.date ??
              chat.draftMessage?.date ??
              chat.lastReadInboxMessageId),
      subtitle: ChatMessageSubtitle(
          message: chat.lastMessage, draftMessage: chat.draftMessage),
      // tileColor: theme.colorScheme.background,
      onTap: () {
        Navigator.push(context, CupertinoPageRoute(builder: (context) {
          return ChatBasePage(chat: chat);
        }));
      },
      onLongPress: () {},
    );
  }
}

class ChatAvatar extends StatefulWidget {
  final td_api.ChatPhotoInfo? photo;
  const ChatAvatar({super.key, required this.photo});

  @override
  State<ChatAvatar> createState() => _ChatAvatarState();
}

class _ChatAvatarState extends State<ChatAvatar> {
  ImageProvider? backgroundImage;

  List<StreamSubscription> subscriptions = [];

  updateFileListener(td_api.UpdateFile event) {
    Print.yellow('updateFileListener');
    var file = event.file;
    if (file.local.isDownloadingCompleted) {
      setState(() {
        backgroundImage = FileImage(File(file.local.path));
      });
    }
  }

  @override
  void initState() {
    var fileStore = context.read<FileStore>();
    var smallFileDowloadSubscription = fileStore
        .on<td_api.UpdateFile>()
        .takeWhile((element) => element.file.id == widget.photo?.small.id)
        .listen(updateFileListener);
    subscriptions.add(smallFileDowloadSubscription);

    var smallPhoto = widget.photo?.small;
    var smallPhotoDownloadingCompleted =
        smallPhoto?.local.isDownloadingCompleted;

    var smallPhotoAvailable = (smallPhotoDownloadingCompleted ?? false);

    if (!smallPhotoAvailable && smallPhoto != null) {
      fileStore.downloadFile(smallPhoto);
      setState(() {
        backgroundImage = widget.photo?.minithumbnail?.data != null
            ? MemoryImage(base64Decode(widget.photo!.minithumbnail!.data))
            : null;
      });
    } else {
      var localPath = smallPhoto?.local.path;
      if (localPath == null) {
        Print.red('file path is null');
      } else {
        setState(() {
          backgroundImage = FileImage(File(localPath));
        });
      }
    }
    super.initState();
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
    return CircleAvatar(
      radius: 22,
      backgroundImage: backgroundImage,
    );
  }
}

class ChatTopRow extends StatelessWidget {
  final String title;

  final int date;

  const ChatTopRow({super.key, required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(child: ChatTitle(title: title)),
        ChatTimeAndStatus(date: date),
      ],
    );
  }
}

class ChatTitle extends StatelessWidget {
  final String title;
  const ChatTitle({super.key, required this.title});

  final isCommunity = true;
  final isBot = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isCommunity)
          const Icon(
            Icons.people_alt,
            size: 20,
          ),
        if (isBot)
          const Icon(
            Icons.smart_toy_outlined,
            size: 20,
          ),
        Flexible(
            child: Text(
          title,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        )),
        const Icon(
          CupertinoIcons.volume_off,
          size: 14,
        ),
        const SizedBox(
          width: 40,
        ),
      ],
    );
  }
}

class ChatTimeAndStatus extends StatelessWidget {
  final int date;
  const ChatTimeAndStatus({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Icon(
          Icons.done_all,
          size: 20,
        ),
        SizedBox(width: 3),
        // TODO: add INTL
        Text("14:00"),
      ],
    );
  }
}
