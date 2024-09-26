import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/components/ChatAvatar/index.dart';
import 'package:minimalistic_telegram/components/ChatBlock/index.dart';
import 'package:minimalistic_telegram/components/MessageSearchResult/index.dart';
import 'package:minimalistic_telegram/controllers/tdlib_controller.dart';
import 'package:minimalistic_telegram/stores/chat_store.dart';
import 'package:minimalistic_telegram/stores/message_store.dart';
import 'package:minimalistic_telegram/stores/user_store.dart';
import 'package:palestine_console/palestine_console.dart';
import 'package:provider/provider.dart';

import 'package:tdlib/td_api.dart' as td_api;

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final searchTextNotifier = ValueNotifier('');

  @override
  void dispose() {
    searchTextNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 18,
        title: const Text('Contacts'),
        // title: TextField(
        //   onChanged: (value) {
        //     searchTextNotifier.value = value; // Update the SearchTextNotifier
        //   },
        //   autofocus: true,
        //   decoration: const InputDecoration(
        //     hintStyle: TextStyle(color: Colors.white60),
        //     border: InputBorder.none,
        //     focusedBorder: InputBorder.none,
        //     enabledBorder: InputBorder.none,
        //     errorBorder: InputBorder.none,
        //     disabledBorder: InputBorder.none,
        //     hintText: "Search",
        //   ),
        // ),
      ),
      body: ContactsListBody(searchTextNotifier: searchTextNotifier),
    );
  }
}

class ContactsListBody extends StatefulWidget {
  final ValueNotifier searchTextNotifier;

  const ContactsListBody({super.key, required this.searchTextNotifier});

  @override
  State<ContactsListBody> createState() => _ContactsListBodyState();
}

class _ContactsListBodyState extends State<ContactsListBody> {
  late bool loading = false;
  List<int> contacts = [];

  loadContacts() async {
    var contactUsers = await TdLibController().send(td_api.GetContacts());
    if (contactUsers is td_api.TdError) {
      return;
    }
    if (contactUsers is td_api.Users) {
      setState(() {
        contacts = contactUsers.userIds;
      });
    }
  }
  // state for result of chats search

  // result of users search
  // result of messages search
  // List<int> searchChatIdsResult = [];

  // void clearSearchResult() {}

  // void getSearchResult() async {
  //   var chatStore = context.read<ChatStore>();

  //   Print.magenta('getting search result for chats');

  //   var result = await chatStore.searchGlobalChats(
  //     searchQuery: widget.searchTextNotifier.value,
  //   );

  //   Print.magenta('chat search result is recieved');
  //   if (result is td_api.TdError) {
  //     return;
  //   }
  //   result as td_api.Chats;
  //   result.chatIds;
  //   Print.magenta('chat search result is not error');
  //   setState(() {
  //     loading = false;
  //     searchChatIdsResult = result.chatIds;
  //   });
  // }

  // void searchControllerListener() {
  //   Print.white('searchControllerListener');
  //   if (widget.searchTextNotifier.value.isEmpty) {
  //     clearSearchResult();
  //     setState(() {
  //       loading = false;
  //     });
  //   } else {
  //     setState(() {
  //       loading = true;
  //     });
  //     getSearchResult();
  //   }
  // }

  @override
  void initState() {
    // widget.searchTextNotifier.addListener(searchControllerListener);
    loadContacts();
    super.initState();
  }

  @override
  void dispose() {
    // widget.searchTextNotifier.removeListener(searchControllerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //debug
        Text(loading ? 'loading' : ''),
        // if (searchChatIdsResult.isNotEmpty && !loading)
        Expanded(
          child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: ((context, index) {
                var userId = contacts.elementAt(index);
                return ContactBlock(userId: userId, key: ValueKey(userId));
              })),
        ),
      ],
    );
  }
}

class ContactBlock extends StatefulWidget {
  final int userId;

  td_api.User? user;

  ContactBlock({Key? key, required this.userId}) : super(key: key);

  @override
  State<ContactBlock> createState() => _ContactBlockState();
}

class _ContactBlockState extends State<ContactBlock> {
  navigateToDialog(int chatId) {}

  loadUser() async {
    var userStore = context.read<UserStore>();
    var user = await userStore.get(widget.userId);

    if (user is td_api.TdError) {
      return;
    }
    if (user is td_api.User) {
      setState(() {
        widget.user = user;
      });
    }
  }

  @override
  void initState() {
    loadUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) return const SizedBox.shrink();
    return ListTile(
      leading: ChatAvatar(
          smallPhoto: widget.user?.profilePhoto?.small,
          minithumbnail: widget.user?.profilePhoto?.minithumbnail),

      title: Text(
          widget.user?.firstName ?? widget.user?.phoneNumber ?? 'not found'),
      onTap: () {
        navigateToDialog(0);
      },
      // subtitle: Text(user.username ?? ''),
    );
  }
}
