// Singleton

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' show Random;

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:minimalistic_telegram/stores/event_emitter.dart';
import 'package:palestine_console/palestine_console.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';
import 'custom_thread.dart';

import 'package:tdlib/tdlib.dart';
import 'package:tdlib/td_api.dart' as td_api;

int _random() => Random().nextInt(10000000);

class TdLibController extends EventEmitter<td_api.TdObject> {
  static final TdLibController _singleton = TdLibController._internal();

  late int _client;
  late StreamController<td_api.TdObject> _eventController;
  late StreamSubscription<td_api.TdObject> _eventReceiver;

  Map results = <int, Completer>{};
  Map callbackResults = <int, Future<void>>{};
  late Directory appDocDir;
  late Directory appExtDir;
  // String lastRouteName;

  // separate thread for tdlib recieve calls
  // final ReceivePort _receivePort = ReceivePort();
  // late Isolate _isolate;
  late TestThread testThread;

  factory TdLibController() {
    return _singleton;
  }

  TdLibController._internal() {
    _eventController = StreamController();
    // _eventController.add(event)
    _eventController.stream.listen(_onEvent);
  }

  void initClient() async {
    _client = tdCreate();

    // ignore: unused_local_variable
    // bool storagePermission = await Permission.storage
    //     .request()
    //     .isGranted; // todo : handel storage permission
    /*try {
      PermissionStatus storagePermission =
          await SimplePermissions.requestPermission(
              Permission.WriteExternalStorage);
    } on PlatformException catch (e) {
      print(e);
    }
    */
    // appDocDir = await getApplicationDocumentsDirectory();
    // appExtDir = await getTemporaryDirectory();

    //execute(SetLogStream(logStream: LogStreamEmpty()));
    execute(const td_api.SetLogVerbosityLevel(newVerbosityLevel: 1));
    tdSend(_client, const td_api.GetCurrentState());

    // spawning a separate thread in order to have a while(true) loop there
    // TODO: extract this logic into separate file!!!
    // _isolate = await Isolate.spawn(_receive, _receivePort.sendPort,
    //     debugName: "isolated receive");
    testThread = TestThread();

    await testThread.init(TestThread.newInstance, _receiver);
    // _receivePort.listen(_receiver);
  }

  // static _receive(sendPortToMain) async {
  //   TdNativePlugin.registerWith();
  //   final tdlibPath = kIsWeb
  //       ? null
  //       : (Platform.isAndroid || Platform.isLinux || Platform.isWindows)
  //           ? 'libtdjson.so'
  //           : null;

  //   await TdPlugin.initialize(tdlibPath);

  //   //var x = _rawClient.td_json_client_create();
  //   while (true) {
  //     final s = TdPlugin.instance.tdReceive();
  //     if (s != null) {
  //       sendPortToMain.send(s);
  //     }
  //   }
  // }

  void _receiver(dynamic newEvent) async {
    final event = td_api.convertToObject(newEvent);
    if (event == null) {
      return;
    }
    if (event is td_api.Updates) {
      for (var event in event.updates) {
        _eventController.add(event);
      }
    } else {
      _eventController.add(event);
    }
    await _resolveEvent(event);
  }

  Future _resolveEvent(event) async {
    if (event.extra == null) {
      return;
    }
    final int extraId = event.extra;
    if (results.containsKey(extraId)) {
      results.remove(extraId).complete(event);
    } else if (callbackResults.containsKey(extraId)) {
      await callbackResults.remove(extraId);
    }
  }

  void stop() {
    _eventController.close();
    _eventReceiver.cancel();
    // _receivePort.close();
    // _isolate.kill(priority: Isolate.immediate);
    testThread.deInit();
  }

  void _onEvent(td_api.TdObject event) async {
    // try {
    //   Print.cyan('res =>>>> ${event.toJson()}');
    // } catch (NoSuchMethodError) {
    //   Print.cyan('res =>>>> ${event.getConstructor()}');
    // }
    emit('event', event);
  }

  void destroyClient() async {
    tdSend(_client, const td_api.Close());
  }

  /// Sends request to the TDLib client. May be called from any thread.
  Future<T> send<T extends td_api.TdObject>(dynamic event,
      {Future<void>? callback}) async {
    final rndId = _random();

    if (callback != null) {
      callbackResults[rndId] = callback;
      try {
        tdSend(_client, event, rndId);
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    } else {
      final completer = Completer<T>();
      results[rndId] = completer;
      tdSend(_client, event, rndId);
      return completer.future;
    }

    throw Exception('Invalid response');
  }

  Future sendTdLibParameters() {
    int apiId = int.parse(dotenv.env['API_ID']!);
    String apiHash = dotenv.env['API_HASH']!;

    return send(
      td_api.SetTdlibParameters(
        useTestDc: false,
        useSecretChats: false,
        useMessageDatabase: true,
        useFileDatabase: true,
        useChatInfoDatabase: true,
        ignoreFileNames: true,
        enableStorageOptimizer: true,
        systemLanguageCode: 'EN',
        filesDirectory: '${appExtDir.path}/tdlib',
        databaseDirectory: appDocDir.path,
        databaseEncryptionKey: base64Encode(utf8.encode('randomkey')),
        applicationVersion: '0.0.1',
        deviceModel: 'Unknown',
        systemVersion: 'Unknown',
        apiId: apiId,
        apiHash: apiHash,
      ),
    );
  }

  /// Synchronously executes TDLib request. May be called from any thread.
  /// Only a few requests can be executed synchronously.
  /// Returned pointer will be deallocated by TDLib during next call to clientReceive or clientExecute in the same thread, so it can't be used after that.
  td_api.TdObject execute(td_api.TdFunction event) => tdExecute(event)!;
}
