import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/pages/contacts_page.dart';
import 'package:minimalistic_telegram/services/locator.dart';
import 'package:minimalistic_telegram/stores/application_store.dart';
import 'package:minimalistic_telegram/stores/user_store.dart';
import 'package:minimalistic_telegram/utils/const.dart';
import 'package:palestine_console/palestine_console.dart';
import 'package:provider/provider.dart';
import 'package:tdlib/td_api.dart' as td_api;
import '../../components/ChatsList/index.dart';
import '../SettingsPage/index.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Map<int, TdApi.Chat>? mainChatsList;
  String authState = '';
  List<StreamSubscription> subscriptions = [];
  @override
  void initState() {
    super.initState();
    authState = '';
    var appStore = context.read<ApplicationStore>();
    var subscription = appStore
        .on<td_api.UpdateAuthorizationState>()
        .listen(onAuthStateChange);
    subscriptions.add(subscription);
  }

  @override
  void dispose() {
    authState = '';
    for (var element in subscriptions) {
      element.cancel();
    }
    subscriptions = [];
    super.dispose();
  }

  void onAuthStateChange(event) {
    setState(() {
      // TODO: this is debug. remove it or change somehow.
      authState = (event)?.authorizationState?.getConstructor() ?? '';
      Print.green(authState);
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 18,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(authState),
        actions: [
          IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                locator<NavigationService>().navigator.pushNamed(searchRoute);
              }),
        ],
      ),
      body: const Center(
        child: ChatsList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'New chat',
        child: const Icon(Icons.edit_outlined),
      ),
      drawer: const NavigationDrawer(),
    );
  }
}

class NavigationDrawer extends StatefulWidget {
  const NavigationDrawer({super.key});

  @override
  State<NavigationDrawer> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  String? firstName;

  @override
  void initState() {
    loadUsername();
    super.initState();
  }

  void loadUsername() async {
    var userStore = context.read<UserStore>();
    var myId = await userStore.getMyId();

    var myInfo = await userStore.get(myId ?? 0);
    var firstName = myInfo?.firstName;
    if (firstName != null) {
      setState(() {
        this.firstName = firstName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: SingleChildScrollView(
            child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        buildHeader(context, firstName ?? 'Username'),
        buildMenuItems(context),
      ],
    )));
  }

  Widget buildHeader(BuildContext context, String username) {
    var theme = Theme.of(context);

    return SafeArea(
        child: Container(
      color: theme.primaryColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Text(
          username,
          style: TextStyle(color: theme.colorScheme.onPrimary),
        ),
        // ElevatedButton(
        //   onPressed: () {},
        //   style: ElevatedButton.styleFrom(
        //     padding: const EdgeInsets.all(0.0),
        //     shape: const CircleBorder(),
        //     backgroundColor: theme.primaryColorDark,
        //     elevation: 0,
        //   ),
        //   child: Icon(
        //     Icons.bookmark_outline,
        //     color: theme.colorScheme.onPrimary,
        //   ),
        // ),
      ),
    ));
  }

  Widget buildMenuItems(BuildContext context) => Column(
        children: [
          ListTile(
            enabled: false,
            leading: const Icon(Icons.group_outlined),
            title: const Text("New group"),
            onTap: () {},
          ),
          ListTile(
            enabled: false,
            leading: const Icon(Icons.lock_outline),
            title: const Text("New secret chat"),
            onTap: () {},
          ),
          ListTile(
            enabled: false,
            leading: const Icon(Icons.cancel_presentation_sharp),
            title: const Text("New channel"),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text("Contacts"),
            onTap: () {
              locator<NavigationService>().navigator.pop(context);
              locator<NavigationService>().navigator.pushNamed(contactsRoute);
            },
          ),
          ListTile(
            enabled: false,
            leading: const Icon(Icons.download_outlined),
            title: const Text("Downloads"),
            onTap: () {},
          ),
          ListTile(
            enabled: false,
            leading: const Icon(Icons.location_on_outlined),
            title: const Text("People around"),
            onTap: () {},
          ),
          ListTile(
            enabled: false,
            leading: const Icon(Icons.phone_outlined),
            title: const Text("Calls"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_outline),
            title: const Text("Saved Messages"),
            onTap: () {
              // locator<NavigationService>()
              //     .navigator
              //     .pushNamed(chatRoute, arguments: chat);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              locator<NavigationService>().navigator.pop(context);
              locator<NavigationService>().navigator.pushNamed(settingsRoute);
            },
          ),
        ],
      );
}
