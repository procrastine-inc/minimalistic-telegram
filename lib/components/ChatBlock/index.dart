import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/components/MessageSubtitle/chat_message_subtitle.dart';
import 'package:minimalistic_telegram/controllers/tdlib_controller.dart';
import 'package:minimalistic_telegram/pages/ChatBasePage.dart';
import 'package:minimalistic_telegram/stores/file_store.dart';
import 'package:palestine_console/palestine_console.dart';
import 'package:tdlib/td_api.dart' as td_api;

import 'chat_bottom_row.dart';
import 'chat_top_row.dart';

const sentIcon = Icon(
  Icons.done,
  size: 20,
  color: Colors.grey,
);

const sentAndReadIcon = Icon(
  Icons.done_all,
  size: 20,
  color: Colors.blue,
);

class ChatBlock extends StatelessWidget {
  final td_api.Chat chat;

  const ChatBlock({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    // debugger();
    return ListTile(
      leading: ChatAvatar(photo: chat.photo),
      title: ChatTopRow(chat: chat),
      subtitle: ChatBottomRow(chat: chat),
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
      backgroundImage: backgroundImage,
    );
  }
}
