import 'dart:async';

import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/stores/message_store.dart';
import 'package:palestine_console/palestine_console.dart';
import 'package:provider/provider.dart';

import 'package:tdlib/td_api.dart' as td_api;

class GlobalSearchPage extends StatefulWidget {
  const GlobalSearchPage({Key? key}) : super(key: key);

  @override
  State<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage> {
  final searchFieldController = TextEditingController();

  List<StreamSubscription> subscriptions = [];

  @override
  void initState() {
    super.initState();
    // subscriptions.add();
  }

  @override
  void dispose() {
    searchFieldController.dispose();
    for (var element in subscriptions) {
      element.cancel();
    }
    subscriptions = [];
    super.dispose();
  }

  void onAuthStateChange(event) {
    setState(() {});
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
        title: TextField(
          controller: searchFieldController,
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
      body: SearchPageBody(searchController: searchFieldController),
    );
  }
}

class SearchPageBody extends StatefulWidget {
  TextEditingController searchController;
  late bool loading = false;
  late MessageStore messageStore;
  // state for result of chats search

  // result of users search
  // result of messages search

  SearchPageBody({super.key, required this.searchController});

  @override
  State<SearchPageBody> createState() => _SearchPageBodyState();
}

class _SearchPageBodyState extends State<SearchPageBody> {
  void clearSearchResult() {}

  void getSearchResult() async {
    // td_api.searchChatsOnServer to get chats 100%
    //searchMessages to get messages 100%
    var result = await widget.messageStore.searchAllMessages(
      searchQuery: widget.searchController.text,
      offsetDate: 0,
      limit: 100,
      offsetMessageId: 0,
      offsetChatId: 0,
      minDate: 0,
      maxDate: 0,
    );
    if (result is td_api.TdError) {
      return;
    }
    Print.magenta('result is recieved');
    setState(() {
      widget.loading = false;
    });
  }

  void searchControllerListener() {
    if (widget.searchController.text.isEmpty) {
      clearSearchResult();
      setState(() {
        widget.loading = false;
      });
    } else {
      setState(() {
        widget.loading = true;
      });
      getSearchResult();
    }
  }

  @override
  void initState() {
    widget.messageStore = context.read<MessageStore>();
    widget.searchController.addListener(searchControllerListener);

    super.initState();
  }

  @override
  void dispose() {
    widget.searchController.removeListener(searchControllerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('recent chats'),
        Text('search results'),
        //debug
        Text(widget.loading ? 'loading' : ''),
        Text(widget.searchController.text),
      ],
    );
  }
}
