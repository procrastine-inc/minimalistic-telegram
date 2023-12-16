import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/components/ChatBlock/index.dart';
import 'package:minimalistic_telegram/components/MessageSearchResult/index.dart';
import 'package:minimalistic_telegram/stores/chat_store.dart';
import 'package:minimalistic_telegram/stores/message_store.dart';
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
  // state for result of chats search

  // result of users search
  // result of messages search
  List<int> searchChatIdsResult = [];

  void clearSearchResult() {}

  void getSearchResult() async {
    var chatStore = context.read<ChatStore>();

    Print.magenta('getting search result for chats');

    var result = await chatStore.searchGlobalChats(
      searchQuery: widget.searchTextNotifier.value,
    );

    Print.magenta('chat search result is recieved');
    if (result is td_api.TdError) {
      return;
    }
    result as td_api.Chats;
    result.chatIds;
    Print.magenta('chat search result is not error');
    setState(() {
      loading = false;
      searchChatIdsResult = result.chatIds;
    });
  }

  void searchControllerListener() {
    Print.white('searchControllerListener');
    if (widget.searchTextNotifier.value.isEmpty) {
      clearSearchResult();
      setState(() {
        loading = false;
      });
    } else {
      setState(() {
        loading = true;
      });
      getSearchResult();
    }
  }

  @override
  void initState() {
    widget.searchTextNotifier.addListener(searchControllerListener);

    super.initState();
  }

  @override
  void dispose() {
    widget.searchTextNotifier.removeListener(searchControllerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var chatStore = context.read<ChatStore>();

    return Column(
      children: [
        //debug
        Text(loading ? 'loading' : ''),
        if (searchChatIdsResult.isNotEmpty && !loading)
          Expanded(
            child: ListView.builder(
                itemCount: searchChatIdsResult.length,
                itemBuilder: ((context, index) {
                  var chatId = searchChatIdsResult.elementAt(index);
                  return ChatBlock(
                      chat: chatStore.items[chatId]!, key: ValueKey(chatId));
                })),
          ),
      ],
    );
  }
}

class ContactBlock extends StatelessWidget {
  final td_api.User user;

  const ContactBlock({Key? key, required this.user}) : super(key: key);

  navigateToDialog(int chatId) {}

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(user.firstName[0]),
      ),
      title: Text(user.firstName),
      onTap: () {
        navigateToDialog(0);
      },
      // subtitle: Text(user.username ?? ''),
    );
  }
}
