import 'package:flutter/material.dart';

class DraftSubtitle extends StatelessWidget {
  final String text;
  const DraftSubtitle({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Text(
        'Draft:',
        style: TextStyle(color: Colors.redAccent),
      ),
      Flexible(
        child: Text(
          text.replaceAll(RegExp(r'[\r\n]+'), ' '),
          overflow: TextOverflow.ellipsis,
        ),
      )
    ]);
  }
}
