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

import 'package:tdlib/tdlib.dart';
import 'package:tdlib/td_api.dart';

import './locator.dart';
import '../utils/const.dart';

int _random() => Random().nextInt(10000000);

class TelegramService extends ChangeNotifier {
  late int _client;
  late StreamController<TdObject> _eventController;
  late StreamSubscription<TdObject> _eventReceiver;
  Map results = <int, Completer>{};
  Map callbackResults = <int, Future<void>>{};
  late Directory appDocDir;
  late Directory appExtDir;
  String lastRouteName;
  late bool haveFullMainChatList = false;
  var mainChatsList = SplayTreeSet<OrderedChat>();
  Map<int, Chat> chats = {};

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
    _client = tdCreate();

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
    execute(const SetLogVerbosityLevel(newVerbosityLevel: 1));
    tdSend(_client, const GetCurrentState());
    _isolate = await Isolate.spawn(_receive, _receivePort.sendPort,
        debugName: "isolated receive");
    _receivePort.listen(_receiver);
  }

  static _receive(sendPortToMain) async {
    TdNativePlugin.registerWith();
    await TdPlugin.initialize();
    //var x = _rawClient.td_json_client_create();
    while (true) {
      final s = TdPlugin.instance.tdReceive();
      if (s != null) {
        sendPortToMain.send(s);
      }
    }
  }

  void _receiver(dynamic newEvent) async {
    final event = convertToObject(newEvent);
    if (event == null) {
      return;
    }
    if (event is Updates) {
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

  void _onEvent(TdObject event) async {
    // try {
    //   print('res =>>>> ${event.toJson()}');
    // } catch (NoSuchMethodError) {
    //   print('res =>>>> ${event.getConstructor()}');
    // }
    switch (event.getConstructor()) {
      case UpdateAuthorizationState.CONSTRUCTOR:
        await _authorizationController(
          (event as UpdateAuthorizationState).authorizationState,
          isOffline: true,
        );
        break;
      case UpdateNewChat.CONSTRUCTOR:
        _updateNewChatController((event as UpdateNewChat).chat);
        break;
      case UpdateChatPosition.CONSTRUCTOR:
        _updateChatPositionController(event as UpdateChatPosition);
        break;
      default:
        return;
    }
  }

  void _updateChatPositionController(UpdateChatPosition event) {
    UpdateChatPosition updateChat = event;
    if (updateChat.position.list.getConstructor() != ChatListMain.CONSTRUCTOR) {
      return;
    }

    var chat = chats[updateChat.chatId];
    if (chat == null) {
      return;
    }
    // synchronized(chat, () {
    int i;
    for (i = 0; i < chat.positions.length; i++) {
      if (chat.positions[i].list.getConstructor() == ChatListMain.CONSTRUCTOR) {
        break;
      }
    }
    var newPositions = List<ChatPosition>.filled(
      chat.positions.length +
          (updateChat.position.order == 0 ? 0 : 1) -
          (i < chat.positions.length ? 1 : 0),
      const ChatPosition(order: 0, list: ChatList(), isPinned: false),
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

  void _updateNewChatController(Chat chat) {
    chats[chat.id] = chat;
    List<ChatPosition> positions = List.from(chat.positions);

    chat = chat.copyWith(positions: []);

    setChatPositions(chat, positions);
  }

  void setChatPositions(Chat chat, List<ChatPosition> positions) {
    // synchronized (mainChatList) {
    // synchronized (chat) {
    for (var position in positions) {
      if (position.list.getConstructor() == ChatListMain.CONSTRUCTOR) {
        bool isRemoved = mainChatsList
            .remove(OrderedChat(chatId: chat.id, position: position));
        // assert(isRemoved);
      }
    }

    chat = chat.copyWith(positions: positions);

    for (var position in positions) {
      if (position.list.getConstructor() == ChatListMain.CONSTRUCTOR) {
        bool isAdded =
            mainChatsList.add(OrderedChat(chatId: chat.id, position: position));
        assert(isAdded);
      }
    }

    // }
    // }
  }

  Future _authorizationController(
    AuthorizationState authState, {
    bool isOffline = false,
  }) async {
    String route;
    int apiId = int.parse(dotenv.env['API_ID']!);
    String apiHash = dotenv.env['API_HASH']!;
    switch (authState.getConstructor()) {
      case AuthorizationStateWaitTdlibParameters.CONSTRUCTOR:
        await send(
          SetTdlibParameters(
            parameters: TdlibParameters(
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
      case AuthorizationStateWaitEncryptionKey.CONSTRUCTOR:
        if ((authState as AuthorizationStateWaitEncryptionKey).isEncrypted) {
          await send(
            const CheckDatabaseEncryptionKey(
              encryptionKey: 'mostrandomencryption',
            ),
          );
        } else {
          await send(
            const SetDatabaseEncryptionKey(
              newEncryptionKey: 'mostrandomencryption',
            ),
          );
        }
        return;
      case AuthorizationStateWaitPhoneNumber.CONSTRUCTOR:
      case AuthorizationStateClosed.CONSTRUCTOR:
        route = loginRoute;
        break;
      case AuthorizationStateReady.CONSTRUCTOR:
        route = homeRoute;
        break;
      case AuthorizationStateWaitCode.CONSTRUCTOR:
        route = otpRoute;
        break;
      case AuthorizationStateWaitOtherDeviceConfirmation.CONSTRUCTOR:
      case AuthorizationStateWaitRegistration.CONSTRUCTOR:
      case AuthorizationStateWaitPassword.CONSTRUCTOR:
      case AuthorizationStateLoggingOut.CONSTRUCTOR:
      case AuthorizationStateClosing.CONSTRUCTOR:
        return;
      default:
        return;
    }

    if (route == lastRouteName) return;
    lastRouteName = route;
    locator<NavigationService>().navigateTo(route);
  }

  void destroyClient() async {
    tdSend(_client, const Close());
  }

  /// Sends request to the TDLib client. May be called from any thread.
  Future<TdObject?> send(event, {Future<void>? callback}) async {
    // ignore: missing_return
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
      final completer = Completer<TdObject>();
      results[rndId] = completer;
      tdSend(_client, event, rndId);
      return completer.future;
    }
  }

  /// Synchronously executes TDLib request. May be called from any thread.
  /// Only a few requests can be executed synchronously.
  /// Returned pointer will be deallocated by TDLib during next call to clientReceive or clientExecute in the same thread, so it can't be used after that.
  TdObject execute(TdFunction event) => tdExecute(event)!;

  Future setAuthenticationPhoneNumber(
    String phoneNumber, {
    required void Function(TdError) onError,
  }) async {
    final result = await send(
      SetAuthenticationPhoneNumber(
        phoneNumber: phoneNumber,
        settings: const PhoneNumberAuthenticationSettings(
          allowFlashCall: false,
          isCurrentPhoneNumber: false,
          allowSmsRetrieverApi: false,
          allowMissedCall: true,
          authenticationTokens: [],
        ),
      ),
    );
    if (result != null && result is TdError) {
      onError(result);
    }
  }

  Future checkAuthenticationCode(
    String code, {
    required void Function(TdError) onError,
  }) async {
    final result = await send(
      CheckAuthenticationCode(
        code: code,
      ),
    );
    if (result != null && result is TdError) {
      onError(result);
    }
  }

  Future<Map<int, Chat>> getMainChatList(int limit) async {
    // _mainChatsListLock.synchronized(() async {
    if (!haveFullMainChatList && limit > mainChatsList.length) {
      // send LoadChats request if there are some unknown chats and have not enough known chats
      final result = await send(LoadChats(
          chatList: const ChatListMain(), limit: limit - mainChatsList.length));

      switch (result?.getConstructor()) {
        case TdError.CONSTRUCTOR:
          if ((result as TdError).code == 404) {
            // synchronized(mainChatList, () {
            haveFullMainChatList = true;
            // });
          } else {
            print("Receive an error for LoadChats:\n${result.toJson()}");
          }
          break;
        case Ok.CONSTRUCTOR:
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
