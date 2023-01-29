import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/pages/ChatBasePage.dart';

class ChatBlock extends StatelessWidget {
  const ChatBlock({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return ListTile(
      leading: const ChatAvatar(),
      title: const ChatTopRow(),
      subtitle: const ChatMessage(),
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
  const ChatTopRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: const [
        Expanded(child: ChatUsername()),
        ChatTimeAndStatus(),
      ],
    );
  }
}

class ChatUsername extends StatelessWidget {
  const ChatUsername({super.key});

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
        const Text("Victoria"),
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

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("Hello!");
  }
}
