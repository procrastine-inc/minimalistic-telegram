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

String formatDate(int dateInSeconds, BuildContext context) {
  final now = DateTime.now();
  final date = DateTime.fromMillisecondsSinceEpoch(dateInSeconds * 1000);
  final timeFormat = MediaQuery.of(context).alwaysUse24HourFormat
      ? DateFormat.Hm() // 24-hour format (e.g., 14:30)
      : DateFormat.jm(); // 12-hour format (e.g., 2:30 PM)

  final last365Days = now.subtract(const Duration(days: 365));

  if (date.isAfter(last365Days) && date.isBefore(now)) {
    // Within the last 365 days, show month and day
    return DateFormat.MMMd()
        .format(date); // Month and day format (e.g., Jul 15)
  } else if (date.year == now.year) {
    if (date.month == now.month && date.day == now.day) {
      // Today, show time
      return timeFormat.format(date); // Format based on system settings
    } else if (date.isAfter(now.subtract(Duration(days: now.weekday - 1))) &&
        date.isBefore(
            now.add(Duration(days: DateTime.daysPerWeek - now.weekday)))) {
      // This week, show the day of the week
      return DateFormat.E().format(date); // Weekday format (e.g., Mon)
    } else {
      // Not within the last 365 days, show day.month.year
      return DateFormat.yMd()
          .format(date); // Full date format (e.g., 07/15/2022)
    }
  } else {
    // Not within the last 365 days and not this year, show day.month.year
    return DateFormat.yMd().format(date); // Full date format (e.g., 07/15/2022)
  }
}

class ChatBlock extends StatelessWidget {
  final td_api.Chat chat;

  const ChatBlock({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    // debugger();
    return ListTile(
      leading: ChatAvatar(photo: chat.photo),
      title: ChatTopRow(chat: chat),
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
      backgroundImage: backgroundImage,
    );
  }
}

class ChatTopRow extends StatelessWidget {
  final td_api.Chat chat;

  const ChatTopRow({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(child: ChatTitle(title: chat.title)),
        const SizedBox(
          width: 40,
        ),
        ChatTimeAndStatus(
            date: chat.draftMessage?.date ?? chat.lastMessage?.date ?? 0,
            isOutgoing: chat.lastMessage?.isOutgoing ?? false,
            sendingState: chat.lastMessage?.sendingState),
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
          overflow: TextOverflow.fade,
          softWrap: false,
        )),
        const SizedBox(
          width: 5,
        ),
        const Icon(
          CupertinoIcons.volume_off,
          size: 14,
        ),
      ],
    );
  }
}

class ChatTimeAndStatus extends StatelessWidget {
  final int date;

  final bool isOutgoing;

  final td_api.MessageSendingState? sendingState;
  const ChatTimeAndStatus(
      {super.key,
      required this.date,
      required this.sendingState,
      required this.isOutgoing});

  @override
  Widget build(BuildContext context) {
    Print.green(date.toString());
    return Row(
      children: [
        const Icon(
          Icons.done_all,
          size: 20,
        ),
        const SizedBox(width: 3),
        Text(formatDate(date, context))
      ],
    );
  }
}
