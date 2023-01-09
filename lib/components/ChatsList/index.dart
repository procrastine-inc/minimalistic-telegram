import 'dart:math';

import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/components/ChatBlock/index.dart';

class ChatsList extends StatelessWidget {
  const ChatsList({super.key});

  @override
  Widget build(BuildContext context) {
    var randomChatsNumber = Random().nextInt(40);

    return ListView(
      children: [
        ...List.generate(
          randomChatsNumber,
          (i) => const ChatBlock(),
        )
      ],
    );
  }
}
