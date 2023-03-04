import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/pages/ChatBasePage.dart';

class ChatBlock extends StatelessWidget {
  String username;

  ChatBlock({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return ListTile(
      leading: const ChatAvatar(),
      title: ChatTopRow(username: username),
      subtitle: const ChatMessagePreview(),
      // tileColor: theme.colorScheme.background,
      onTap: () {
        Navigator.push(context, CupertinoPageRoute(builder: (context) {
          return const ChatBasePage();
        }));
      },
      onLongPress: () {},
    );
  }
}

class ChatAvatar extends StatelessWidget {
  const ChatAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      radius: 22,
      backgroundImage: NetworkImage(
          'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'),
    );
  }
}

class ChatTopRow extends StatelessWidget {
  String username;

  ChatTopRow({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(child: ChatUsername(username: username)),
        const ChatTimeAndStatus(),
      ],
    );
  }
}

class ChatUsername extends StatelessWidget {
  String username;
  ChatUsername({super.key, required this.username});

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
            Icons.car_crash, // could not find bot logo
            size: 20,
          ),
        Flexible(
            child: Text(
          username,
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
  const ChatTimeAndStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Icon(
          Icons.done_all,
          size: 20,
        ),
        SizedBox(width: 3),
        Text("14:00"),
      ],
    );
  }
}

class ChatMessagePreview extends StatelessWidget {
  const ChatMessagePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("Hello!");
  }
}
