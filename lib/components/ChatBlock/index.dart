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
          return ChatBasePage();
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
        ChatTimeAndStatus(),
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
        Text(username),
        const Icon(
          CupertinoIcons.volume_off,
          size: 20,
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
