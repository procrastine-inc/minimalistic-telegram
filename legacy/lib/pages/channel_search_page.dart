import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/components/ChatBlock/index.dart';
import 'package:minimalistic_telegram/components/MessageSearchResult/index.dart';
import 'package:minimalistic_telegram/stores/chat_store.dart';
import 'package:minimalistic_telegram/stores/message_store.dart';
import 'package:palestine_console/palestine_console.dart';
import 'package:provider/provider.dart';

import 'package:tdlib/td_api.dart' as td_api;

class ChannelSearchPage extends StatefulWidget {
  const ChannelSearchPage({Key? key}) : super(key: key);

  @override
  State<ChannelSearchPage> createState() => _ChannelSearchPageState();
}

class _ChannelSearchPageState extends State<ChannelSearchPage> {
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
        title: TextField(
          onChanged: (value) {
            searchTextNotifier.value = value; // Update the SearchTextNotifier
          },
          autofocus: true,
          decoration: const InputDecoration(
            hintStyle: TextStyle(color: Colors.white60),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: "Search",
          ),
        ),
      ),
      body: SearchPageBody(searchTextNotifier: searchTextNotifier),
    );
  }
}

class SearchPageBody extends StatefulWidget {
  final ValueNotifier searchTextNotifier;

  const SearchPageBody({super.key, required this.searchTextNotifier});

  @override
  State<SearchPageBody> createState() => _SearchPageBodyState();
}

class _SearchPageBodyState extends State<SearchPageBody> {
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
