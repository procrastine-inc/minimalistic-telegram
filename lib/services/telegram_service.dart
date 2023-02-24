import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' show Random;

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:minimalistic_telegram/models/ordered_chat.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';

import 'package:tdlib/tdlib.dart' as td_lib;
import 'package:tdlib/td_api.dart' as td_api;

import './locator.dart';
import '../utils/const.dart';

int _random() => Random().nextInt(10000000);

class TelegramService extends ChangeNotifier {
  late int _client;
  late StreamController<td_api.TdObject> _eventController;
  late StreamSubscription<td_api.TdObject> _eventReceiver;
  Map results = <int, Completer>{};
  Map callbackResults = <int, Future<void>>{};
  late Directory appDocDir;
  late Directory appExtDir;
  String lastRouteName;
  late bool haveFullMainChatList = false;
  var mainChatsList = SplayTreeSet<OrderedChat>();
  Map<int, td_api.Chat> chats = {};

  final ReceivePort _receivePort = ReceivePort();
  late Isolate _isolate;

  TelegramService({this.lastRouteName = initRoute}) {
    _eventController = StreamController();
    _eventController.stream.listen(_onEvent);
    initClient();
  }

  /// Creates a new instance of TDLib.
  /// Returns Pointer to the created instance of TDLib.
  /// Pointer 0 mean No client instance.

  void initClient() async {
    _client = td_lib.tdCreate();

    // ignore: unused_local_variable
    bool storagePermission = await Permission.storage
        .request()
        .isGranted; // todo : handel storage permission
    /*try {
      PermissionStatus storagePermission =
          await SimplePermissions.requestPermission(
              Permission.WriteExternalStorage);
    } on PlatformException catch (e) {
      print(e);
    }
    */
    appDocDir = await getApplicationDocumentsDirectory();
    appExtDir = await getTemporaryDirectory();

    //execute(SetLogStream(logStream: LogStreamEmpty()));
    execute(const td_api.SetLogVerbosityLevel(newVerbosityLevel: 1));
    td_lib.tdSend(_client, const td_api.GetCurrentState());
    _isolate = await Isolate.spawn(_receive, _receivePort.sendPort,
        debugName: "isolated receive");
    _receivePort.listen(_receiver);
  }

  static _receive(sendPortToMain) async {
    td_lib.TdNativePlugin.registerWith();
    await td_lib.TdPlugin.initialize();
    //var x = _rawClient.td_json_client_create();
    while (true) {
      final s = td_lib.TdPlugin.instance.tdReceive();
      if (s != null) {
        sendPortToMain.send(s);
      }
    }
  }

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
    _receivePort.close();
    _isolate.kill(priority: Isolate.immediate);
  }

  void _onEvent(td_api.TdObject event) async {
    // try {
    //   print('res =>>>> ${event.toJson()}');
    // } catch (NoSuchMethodError) {
    //   print('res =>>>> ${event.getConstructor()}');
    // }
    switch (event.getConstructor()) {
      case td_api.UpdateAuthorizationState.CONSTRUCTOR:
        await _authorizationController(
          (event as td_api.UpdateAuthorizationState).authorizationState,
          isOffline: true,
        );
        break;
      case td_api.UpdateNewChat.CONSTRUCTOR:
        _updateNewChatController((event as td_api.UpdateNewChat).chat);
        break;
      case td_api.UpdateChatPosition.CONSTRUCTOR:
        _updateChatPositionController(event as td_api.UpdateChatPosition);
        break;
      default:
        return;
    }
  }

  void _updateChatPositionController(td_api.UpdateChatPosition event) {
    td_api.UpdateChatPosition updateChat = event;
    if (updateChat.position.list.getConstructor() !=
        td_api.ChatListMain.CONSTRUCTOR) {
      return;
    }

    var chat = chats[updateChat.chatId];
    if (chat == null) {
      return;
    }
    // synchronized(chat, () {
    int i;
    for (i = 0; i < chat.positions.length; i++) {
      if (chat.positions[i].list.getConstructor() ==
          td_api.ChatListMain.CONSTRUCTOR) {
        break;
      }
    }
    var newPositions = List<td_api.ChatPosition>.filled(
      chat.positions.length +
          (updateChat.position.order == 0 ? 0 : 1) -
          (i < chat.positions.length ? 1 : 0),
      const td_api.ChatPosition(
          order: 0, list: td_api.ChatList(), isPinned: false),
    );
    int pos = 0;
    if (updateChat.position.order != 0) {
      newPositions[pos++] = updateChat.position;
    }
    for (int j = 0; j < chat.positions.length; j++) {
      if (j != i) {
        newPositions[pos++] = chat.positions[j];
      }
    }
    assert(pos == newPositions.length);

    setChatPositions(chat, newPositions);
    // });
  }

  void _updateNewChatController(td_api.Chat chat) {
    chats[chat.id] = chat;
    List<td_api.ChatPosition> positions = List.from(chat.positions);

    chat = chat.copyWith(positions: []);

    setChatPositions(chat, positions);
  }

  void setChatPositions(td_api.Chat chat, List<td_api.ChatPosition> positions) {
    // synchronized (mainChatList) {
    // synchronized (chat) {
    for (var position in positions) {
      if (position.list.getConstructor() == td_api.ChatListMain.CONSTRUCTOR) {
        // TODO: check what's going on here
        bool isRemoved = mainChatsList
            .remove(OrderedChat(chatId: chat.id, position: position));
        // assert(isRemoved);
      }
    }

    chat = chat.copyWith(positions: positions);

    for (var position in positions) {
      if (position.list.getConstructor() == td_api.ChatListMain.CONSTRUCTOR) {
        bool isAdded =
            mainChatsList.add(OrderedChat(chatId: chat.id, position: position));
        assert(isAdded);
      }
    }

    // }
    // }
  }

  Future _authorizationController(
    td_api.AuthorizationState authState, {
    bool isOffline = false,
  }) async {
    String route;
    int apiId = int.parse(dotenv.env['API_ID']!);
    String apiHash = dotenv.env['API_HASH']!;
    switch (authState.getConstructor()) {
      case td_api.AuthorizationStateWaitTdlibParameters.CONSTRUCTOR:
        await send(
          td_api.SetTdlibParameters(
            parameters: td_api.TdlibParameters(
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
              applicationVersion: '0.0.1',
              deviceModel: 'Unknown',
              systemVersion: 'Unknonw',
              apiId: apiId,
              apiHash: apiHash,
            ),
          ),
        );
        return;
      case td_api.AuthorizationStateWaitEncryptionKey.CONSTRUCTOR:
        if ((authState as td_api.AuthorizationStateWaitEncryptionKey)
            .isEncrypted) {
          await send(
            const td_api.CheckDatabaseEncryptionKey(
              encryptionKey: 'mostrandomencryption',
            ),
          );
        } else {
          await send(
            const td_api.SetDatabaseEncryptionKey(
              newEncryptionKey: 'mostrandomencryption',
            ),
          );
        }
        return;
      case td_api.AuthorizationStateWaitPhoneNumber.CONSTRUCTOR:
      case td_api.AuthorizationStateClosed.CONSTRUCTOR:
        route = loginRoute;
        break;
      case td_api.AuthorizationStateReady.CONSTRUCTOR:
        route = homeRoute;
        break;
      case td_api.AuthorizationStateWaitCode.CONSTRUCTOR:
        route = otpRoute;
        break;
      case td_api.AuthorizationStateWaitOtherDeviceConfirmation.CONSTRUCTOR:
      case td_api.AuthorizationStateWaitRegistration.CONSTRUCTOR:
      case td_api.AuthorizationStateWaitPassword.CONSTRUCTOR:
      case td_api.AuthorizationStateLoggingOut.CONSTRUCTOR:
      case td_api.AuthorizationStateClosing.CONSTRUCTOR:
        return;
      default:
        return;
    }

    if (route == lastRouteName) return;
    lastRouteName = route;
    locator<NavigationService>().navigateTo(route);
  }

  void destroyClient() async {
    td_lib.tdSend(_client, const td_api.Close());
  }

  /// Sends request to the TDLib client. May be called from any thread.
  Future<td_api.TdObject?> send(event, {Future<void>? callback}) async {
    // ignore: missing_return
    final rndId = _random();
    if (callback != null) {
      callbackResults[rndId] = callback;
      try {
        td_lib.tdSend(_client, event, rndId);
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    } else {
      final completer = Completer<td_api.TdObject>();
      results[rndId] = completer;
      td_lib.tdSend(_client, event, rndId);
      return completer.future;
    }
    return null;
  }

  /// Synchronously executes TDLib request. May be called from any thread.
  /// Only a few requests can be executed synchronously.
  /// Returned pointer will be deallocated by TDLib during next call to clientReceive or clientExecute in the same thread, so it can't be used after that.
  td_api.TdObject execute(td_api.TdFunction event) => td_lib.tdExecute(event)!;

  Future setAuthenticationPhoneNumber(
    String phoneNumber, {
    required void Function(td_api.TdError) onError,
  }) async {
    final result = await send(
      td_api.SetAuthenticationPhoneNumber(
        phoneNumber: phoneNumber,
        settings: const td_api.PhoneNumberAuthenticationSettings(
          allowFlashCall: false,
          isCurrentPhoneNumber: false,
          allowSmsRetrieverApi: false,
          allowMissedCall: true,
          authenticationTokens: [],
        ),
      ),
    );
    if (result != null && result is td_api.TdError) {
      onError(result);
    }
  }

  Future checkAuthenticationCode(
    String code, {
    required void Function(td_api.TdError) onError,
  }) async {
    final result = await send(
      td_api.CheckAuthenticationCode(
        code: code,
      ),
    );
    if (result != null && result is td_api.TdError) {
      onError(result);
    }
  }

  Future<Map<int, td_api.Chat>> getMainChatList(int limit) async {
    // _mainChatsListLock.synchronized(() async {
    if (!haveFullMainChatList && limit > mainChatsList.length) {
      // send LoadChats request if there are some unknown chats and have not enough known chats
      final result = await send(td_api.LoadChats(
          chatList: const td_api.ChatListMain(),
          limit: limit - mainChatsList.length));

      switch (result?.getConstructor()) {
        case td_api.TdError.CONSTRUCTOR:
          if ((result as td_api.TdError).code == 404) {
            // synchronized(mainChatList, () {
            haveFullMainChatList = true;
            // });
          } else {
            print("Receive an error for LoadChats:\n${result.toJson()}");
          }
          break;
        case td_api.Ok.CONSTRUCTOR:
          getMainChatList(limit);
          break;
        default:
          print("Receive wrong response from TDLib:\n$result");
      }
      return chats;
    }

    final iter = mainChatsList.iterator;

    print('First $limit chat(s) out of ${mainChatsList.length} known chat(s):');

    for (var i = 0; i < limit && i < mainChatsList.length; i++) {
      iter.moveNext();

      final chatId = iter.current.chatId;
      final chat = chats[chatId];
      // synchronized(chat, () {
      print('$chatId: ${chat?.title}');
      // });
    }
    return chats;
  }
}
