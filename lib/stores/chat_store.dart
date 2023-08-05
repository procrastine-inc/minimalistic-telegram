import 'dart:collection';
import 'dart:developer';
import 'package:change_case/change_case.dart';
import 'package:event_bus/event_bus.dart';
import 'package:minimalistic_telegram/models/ordered_chat.dart';
import 'package:minimalistic_telegram/stores/event_emitter.dart';
import 'package:palestine_console/palestine_console.dart';
import 'package:tdlib/td_api.dart' as td_api;

import '../controllers/tdlib_controller.dart';

// TODO: make it singleTon
class ChatStore extends EventBus {
  late List<td_api.ChatFilterInfo>? filters;

  late Map scrollPositions;

  late Map<int, td_api.Chat> items;

  late Map typingManagers;

  late Map onlineMemberCount;

  late Map counters;

  late List skippedUpdates;

  late td_api.BackgroundTypeWallpaper? wallpaper;

  late SplayTreeSet<OrderedChat> chatList;

  late bool haveFullMainChatList;

  late Map<Type, dynamic> eventHandlers = {};

  ChatStore() {
    reset();
    eventHandlers = _initEventHandlers();

    addTdLibListener();
  }

  void reset() {
    scrollPositions = {};
    items = {};
    typingManagers = {};
    onlineMemberCount = {};
    counters = {};
    skippedUpdates = [];
    chatList = SplayTreeSet<OrderedChat>();
    wallpaper = null;
    haveFullMainChatList = false;
  }

  void addTdLibListener() {
    TdLibController().on('event', onUpdate);
    // TdLibController().on('clientUpdate', onClientUpdate);
  }

  void addStatistics() {}
  onUpdate(td_api.TdObject event) async {
    final eventType = event.runtimeType;
    final handler = eventHandlers[eventType];
    if (handler != null) {
      await handler(event);
      fire(event);
    } else {
      // Handle unknown event type
    }
  }

  handleAuthorizationStateUpdate(
      td_api.UpdateAuthorizationState authorizationStateUpdate) async {
    final authorizationState = authorizationStateUpdate.authorizationState;
    switch (authorizationState.getConstructor()) {
      case td_api.AuthorizationStateClosed.CONSTRUCTOR:
        reset();
        break;
      default:
    }
  }

  onClientUpdate() {}

  void _updateNewChatController(td_api.UpdateNewChat chatUpdate) {
    var chat = chatUpdate.chat;
    items[chat.id] = chat;
    List<td_api.ChatPosition> positions = List.from(chat.positions);

    chat = chat.copyWith(positions: []);

    setChatPositions(chat, positions);
  }

  void setChatPositions(td_api.Chat chat, List<td_api.ChatPosition> positions) {
    // synchronized (mainChatList) {
    // synchronized (chat) {
    for (var position in chat.positions) {
      if (position.list.getConstructor() == td_api.ChatListMain.CONSTRUCTOR) {
        chatList.removeWhere(((element) => element.chatId == chat.id));
      }
    }

    // TODO: idk why we make this reassignment
    // the same is in Java example
    items[chat.id] = chat.copyWith(positions: [...positions]);

    for (var position in positions) {
      if (position.list.getConstructor() == td_api.ChatListMain.CONSTRUCTOR) {
        bool isAdded =
            chatList.add(OrderedChat(chatId: chat.id, position: position));
        assert(isAdded);
      }
    }

    // }
    // }
  }

  void _updateChatPositionController(td_api.UpdateChatPosition event) {
    // TODO: This implementation is kinda wrong.
    // Here we accept only updates for main list.
    // And also it's very imperative, we can write it in better style.
    td_api.UpdateChatPosition updateChat = event;
    if (updateChat.position.list.getConstructor() !=
        td_api.ChatListMain.CONSTRUCTOR) {
      return;
    }

    var chat = items[updateChat.chatId];
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
    // this if adds position that came from update
    if (updateChat.position.order != 0) {
      newPositions[pos++] = updateChat.position;
    }
    // this loop adds all existing positions
    for (int j = 0; j < chat.positions.length; j++) {
      if (j != i) {
        // this check skips mainList position(because it's added in previous if)
        newPositions[pos++] = chat.positions[j];
      }
    }
    assert(pos == newPositions.length); // this may become unnecessary
    Print.green(
        '${chat.title} has ${chat.positions.length.toString()} positions. Should become ${newPositions.length}');

    setChatPositions(chat, newPositions);
  }

  Future<Map<int, td_api.Chat>> getChatList(int limit) async {
    // _mainChatListLock.synchronized(() async {
    if (!haveFullMainChatList && limit > chatList.length) {
      // send LoadChats request if there are some unknown chats and have not enough known chats
      final result = await TdLibController().send(td_api.LoadChats(
          chatList: const td_api.ChatListMain(),
          limit: limit - chatList.length));

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
          getChatList(limit);
          break;
        default:
          print("Receive wrong response from TDLib:\n$result");
      }
      return items;
    }

    final iter = chatList.iterator;

    print('First $limit chat(s) out of ${chatList.length} known chat(s):');

    for (var i = 0; i < limit && i < chatList.length; i++) {
      iter.moveNext();

      final chatId = iter.current.chatId;
      final chat = items[chatId];
      // synchronized(chat, () {
      print('$chatId: ${chat?.title}');
      // });
    }
    return items;
  }

  void _updateChatLastMessageController(td_api.UpdateChatLastMessage event) {
    // Print.green(
    //     (event.lastMessage?.content as td_api.MessageText).text.text ?? '');
    // TODO: add actual lastMessage update to the MessageStore
    var chat = items[event.chatId];
    if (chat == null) {
      return;
    }
    var updatedChat = chat.copyWith(lastMessage: event.lastMessage);
    items[event.chatId] = updatedChat;
    setChatPositions(updatedChat, event.positions);
  }

  void _updateChatDraftMessageController(td_api.UpdateChatDraftMessage event) {
    var chat = items[event.chatId];
    if (chat == null) {
      return;
    }

    var chatCopy = td_api.Chat.fromJson(
      chat.toJson(),
    );
    setChatPositions(chatCopy, event.positions);
  }

  void _printChats() {
    Print.blue('Current Chats list:');
    for (var chat in chatList) {
      Print.green(items[chat.chatId]?.title ?? '');
    }
    Print.blue('Finished printing chats');
  }

  void _updateChatActionController(td_api.UpdateChatAction event) {
    var chat = items[event.chatId];

    if (chat == null) {
      return;
    }
    // TODO: implement typingListener
  }

  _initEventHandlers() {
    return {
      td_api.UpdateAuthorizationState: handleAuthorizationStateUpdate,
      td_api.UpdateNewChat: _updateNewChatController,
      td_api.UpdateChatPosition: _updateChatPositionController,
      td_api.UpdateChatLastMessage: _updateChatLastMessageController,
      td_api.UpdateChatDraftMessage: _updateChatDraftMessageController,
      td_api.UpdateChatAction: _updateChatActionController,
      td_api.UpdateChatReadOutbox: _updateChatReadOutboxHandler,
      td_api.UpdateChatReadInbox: _updateChatReadInboxHandler,
    };
  }

  _updateChatReadOutboxHandler(td_api.UpdateChatReadOutbox event) {
    var chat = items[event.chatId];

    if (chat == null) {
      return;
    }

    var updatedChat =
        chat.copyWith(lastReadOutboxMessageId: event.lastReadOutboxMessageId);
    items[event.chatId] = updatedChat;
  }

  _updateChatReadInboxHandler(td_api.UpdateChatReadInbox event) {
    var chat = items[event.chatId];

    if (chat == null) {
      return;
    }

    var updatedChat = chat.copyWith(
        lastReadInboxMessageId: event.lastReadInboxMessageId,
        unreadCount: event.unreadCount);
    items[event.chatId] = updatedChat;
  }
}
