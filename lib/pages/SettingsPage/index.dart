import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/services/locator.dart';
import 'package:minimalistic_telegram/utils/const.dart';

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
                      const PopupMenuItem(
                        child: Wrap(
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Icon(Icons.edit_outlined, color: Colors.black),
                            Text("Change name"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        child: Wrap(
                          spacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined,
                                color: Colors.black),
                            Text("Select photo or video"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        child: Wrap(
                          spacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Icon(Icons.exit_to_app, color: Colors.black),
                            Text("Logout"),
                          ],
                        ),
                      ),
                    ])
          ],
        ),
        body: ListView(
          children: [
            SettingsCardBlock(
              title: "Account",
              children: [
                ListTile(
                  title: const Text("@my_username"),
                  subtitle: const Text(
                    "Username",
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text("eehehehehehe"),
                  subtitle: const Text(
                    "Bio",
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () {},
                )
              ],
            ),
            const SizedBox(
              height: 14,
            ),
            SettingsCardBlock(
              title: "Settings",
              children: [
                ListTile(
                  visualDensity: VisualDensity.compact,
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text("Notifications and Sounds"),
                  onTap: () {},
                ),
                ListTile(
                  visualDensity: VisualDensity.compact,
                  leading: const Icon(Icons.lock_outline),
                  title: const Text("Privacy and Security"),
                  onTap: () {},
                ),
                ListTile(
                  visualDensity: VisualDensity.compact,
                  leading: const Icon(Icons.pie_chart_outline),
                  title: const Text("Data and Storage"),
                  onTap: () {},
                ),
                ListTile(
                  visualDensity: VisualDensity.compact,
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: const Text("Chat Settings"),
                  onTap: () {},
                ),
                ListTile(
                  visualDensity: VisualDensity.compact,
                  leading: const Icon(Icons.sticky_note_2),
                  title: const Text("Stickers and Emoji"),
                  onTap: () {},
                ),
                ListTile(
                  visualDensity: VisualDensity.compact,
                  leading: const Icon(Icons.folder_outlined),
                  title: const Text("Chat Folders"),
                  onTap: () {},
                ),
                ListTile(
                  visualDensity: VisualDensity.compact,
                  leading: const Icon(Icons.devices),
                  title: const Text("Devices"),
                  onTap: () {},
                ),
                ListTile(
                  visualDensity: VisualDensity.compact,
                  leading: const Icon(Icons.language_outlined),
                  title: const Text("Language"),
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(
              height: 14,
            ),
            SettingsCardBlock(
              title: "Minigram Settings",
              children: [
                ListTile(
                  visualDensity: VisualDensity.compact,
                  leading: const Icon(Icons.travel_explore_sharp),
                  title: const Text("Channel search"),
                  onTap: () {
                    locator<NavigationService>()
                        .navigator
                        .pushNamed(channelSearchRoute);
                  },
                ),
                ListTile(
                  visualDensity: VisualDensity.compact,
                  leading: const Icon(Icons.analytics_outlined),
                  title: const Text("Analytics"),
                  onTap: () {
                    locator<NavigationService>()
                        .navigator
                        .pushNamed(statsRoute);
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 14,
            ),
            SettingsCardBlock(
              title: "Help",
              children: [
                ListTile(
                  visualDensity: VisualDensity.compact,
                  leading: const Icon(Icons.help_outline_outlined),
                  title: const Text("Telegram FAQ"),
                  onTap: () {},
                ),
                ListTile(
                  visualDensity: VisualDensity.compact,
                  leading: const Icon(Icons.verified_user_outlined),
                  title: const Text("Privacy Policy"),
                  onTap: () {},
                )
              ],
            )
          ],
        ));
  }
}

class SettingsCardBlock extends StatelessWidget {
  const SettingsCardBlock({
    Key? key,
    required this.title,
    required this.children,
  }) : super(key: key);

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return SafeArea(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        margin: const EdgeInsets.all(0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 5),
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.primaryColor),
            ),
          ),
          ...children,
        ]),
      ),
    );
  }
}
