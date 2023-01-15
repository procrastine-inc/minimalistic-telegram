import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
        // TODO: update appbar and move to
        // custom SliverAppBar implementation with 2 stoppoints

        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {},
        //   child: const Icon(Icons.add_a_photo_outlined),
        // ),
        appBar: AppBar(
          elevation: 0,
          titleSpacing: 18,
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.qr_code)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            PopupMenuButton(
                itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Wrap(
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: const [
                            Icon(Icons.edit_outlined, color: Colors.black),
                            Text("Change name"),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        child: Wrap(
                          spacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: const [
                            Icon(Icons.add_a_photo_outlined,
                                color: Colors.black),
                            Text("Select photo or video"),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        child: Wrap(
                          spacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: const [
                            Icon(Icons.exit_to_app, color: Colors.black),
                            Text("Logout"),
                          ],
                        ),
                      ),
                    ])
          ],
        ),
        body: ListView(
          children: const [],
        ));
  }
}
