import 'package:flutter/material.dart';

class ChatAppBar extends StatelessWidget with PreferredSizeWidget {
  final String title;

  const ChatAppBar({
    Key? key,
    this.title = "Chat",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(right: 16),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                width: 2,
              ),
              const CircleAvatar(
                backgroundColor: Colors.white,
                maxRadius: 20,
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    const Text(
                      "Online",
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            )),
        PopupMenuButton(
            color: Colors.white,
            itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Wrap(
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: const [
                        Icon(Icons.volume_up_outlined, color: Colors.grey),
                        Text("Mute"),
                      ],
                    ),
                  ),
                ])
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);
}