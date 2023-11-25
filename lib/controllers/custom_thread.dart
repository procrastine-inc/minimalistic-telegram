// TODO: this is only web! make it work for all platforms
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:dart_thread/dart_thread.dart';
// import 'package:tdlib/tdlib.dart';
import 'package:tdlib/src/tdclient/platform_interfaces/td_web_plugin_real.dart';

class TestThread extends DartThread {
  // Need to mapping Class to super.init,
  // because dart did not allow override a static method
  static TestThread newInstance() => TestThread();

  @override
  // Running once in isolate or worker
  Future<void> onExecute(Function(dynamic message) sendMessage) async {
    print('Hello!');
    TdWebPlugin.registerWith();

    // TdNativePlugin.registerWith();
    final tdlibPath = kIsWeb
        ? null
        : (Platform.isAndroid || Platform.isLinux || Platform.isWindows)
            ? 'libtdjson.so'
            : null;

    print('Thread tdlibPath: $tdlibPath ');
    print('isWeb $kIsWeb');

    await TdWebPlugin.initialize();

    //var x = _rawClient.td_json_client_create();
    while (true) {
      const instance = TdWebPlugin();
      final s = instance.tdReceive();
      if (s != null) {
        sendMessage(s);
      }
    }
  }
}
