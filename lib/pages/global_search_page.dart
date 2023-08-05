import 'dart:async';

import 'package:flutter/material.dart';

class GlobalSearchPage extends StatefulWidget {
  const GlobalSearchPage({Key? key}) : super(key: key);

  @override
  State<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage> {
  final searchFieldcontroler = TextEditingController();

  List<StreamSubscription> subscriptions = [];
  @override
  void initState() {
    super.initState();
    // subscriptions.add();
    searchFieldcontroler.addListener(_initiateSearch);
  }

  @override
  void dispose() {
    searchFieldcontroler.dispose();
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
          controller: searchFieldcontroler,
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
      body: const Center(
        child: Text('test search page'),
      ),
    );
  }

  void _initiateSearch() {}
}
