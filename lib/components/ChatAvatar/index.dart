import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:palestine_console/palestine_console.dart';

import 'package:tdlib/td_api.dart' as td_api;

import '../../stores/file_store.dart';

class ChatAvatar extends StatefulWidget {
  final td_api.File? smallPhoto;
  final td_api.Minithumbnail? minithumbnail;
  final td_api.User? user;
  const ChatAvatar(
      {super.key,
      required this.smallPhoto,
      required this.minithumbnail,
      this.user});

  @override
  State<ChatAvatar> createState() => _ChatAvatarState();
}

class _ChatAvatarState extends State<ChatAvatar> {
  ImageProvider? backgroundImage;

  List<StreamSubscription> subscriptions = [];

  updateFileListener(td_api.UpdateFile event) {
    if (widget.user?.firstName == 'Alex') debugger();
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
    var smallFileDowloadSubscription =
        fileStore.on<td_api.UpdateFile>().takeWhile((element) {
      if (element.file.id == widget.smallPhoto?.id &&
          widget.user?.firstName == 'Alex') debugger();
      return element.file.id == widget.smallPhoto?.id;
    }).listen(updateFileListener);

    subscriptions.add(smallFileDowloadSubscription);
    if (widget.smallPhoto == null) return;
    var smallPhoto = fileStore.items[widget.smallPhoto?.id];

    if (smallPhoto == null || smallPhoto.local.isDownloadingCompleted == null) {
      fileStore.downloadFile(widget.smallPhoto as td_api.File,
          user: widget.user);
      setState(() {
        backgroundImage = widget.minithumbnail?.data != null
            ? MemoryImage(base64Decode(widget.minithumbnail!.data))
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
