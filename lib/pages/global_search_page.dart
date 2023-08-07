import 'dart:async';

import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/stores/message_store.dart';
import 'package:palestine_console/palestine_console.dart';
import 'package:provider/provider.dart';

import 'package:tdlib/td_api.dart' as td_api;

class SearchTextNotifier extends ChangeNotifier {
  String _searchText = '';

  String get searchText => _searchText;

  set searchText(String value) {
    if (value == _searchText) return;
    _searchText = value;
    notifyListeners();
  }
}

class GlobalSearchPage extends StatefulWidget {
  const GlobalSearchPage({Key? key}) : super(key: key);

  @override
  State<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage> {
  final searchTextNotifier = SearchTextNotifier();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 18,
        title: TextField(
          onChanged: (value) {
            searchTextNotifier.searchText =
                value; // Update the SearchTextNotifier
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
  final SearchTextNotifier searchTextNotifier;

  const SearchPageBody({super.key, required this.searchTextNotifier});

  @override
  State<SearchPageBody> createState() => _SearchPageBodyState();
}

class _SearchPageBodyState extends State<SearchPageBody> {
  late bool loading = false;
  // state for result of chats search

  // result of users search
  // result of messages search
  List<td_api.Message> searchMessagesResult = [];

  void clearSearchResult() {}

  void getSearchResult() async {
    var messageStore = context.read<MessageStore>();

    Print.magenta('getting search result');
    // td_api.searchChatsOnServer to get chats 100%
    //searchMessages to get messages 100%
    var result = await messageStore.searchAllMessages(
      searchQuery: widget.searchTextNotifier._searchText,
      offsetDate: 0,
      limit: 20,
      offsetMessageId: 0,
      offsetChatId: 0,
      minDate: 0,
      maxDate: 0,
    );
    Print.magenta('result is recieved');
    if (result is td_api.TdError) {
      return;
    }
    Print.magenta('result is not error');
    setState(() {
      loading = false;
      searchMessagesResult = (result as td_api.Messages).messages;
    });
  }

  void searchControllerListener() {
    Print.white('searchControllerListener');
    if (widget.searchTextNotifier._searchText.isEmpty) {
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
    return Column(
      children: [
        Text('recent chats'),
        //debug
        Text(loading ? 'loading' : ''),
        if (searchMessagesResult.isNotEmpty && !loading)
          Expanded(
            child: ListView(
                children: searchMessagesResult
                    .map((message) => MessageSearchResult(message: message))
                    .toList()),
          ),
      ],
    );
  }
}

class MessageSearchResult extends StatelessWidget {
  td_api.Message message;

  MessageSearchResult({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // list item with avatar, title, message, date
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.person),
      ),
      title: Text(message.chatId.toString()),
      subtitle: Text(message.content.toString()),
      trailing: Text(message.date.toString()),
    );
  }
}
