import 'dart:collection';
import 'dart:developer';

import 'package:minimalistic_telegram/models/ordered_chat.dart';
import 'package:minimalistic_telegram/stores/event_emitter.dart';
import 'package:palestine_console/palestine_console.dart';
import 'package:tdlib/td_api.dart' as td_api;

import '../controllers/tdlib_controller.dart';

// TODO: make it singleTon
class ChatStore extends EventEmitter {
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

  ChatStore() {
    reset();

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
  //FIXME: update typings here
  onUpdate(td_api.TdObject event) async {
    switch (event.getConstructor()) {
      case td_api.UpdateAuthorizationState.CONSTRUCTOR:
        await handleAuthorizationStateUpdate(
            (event as td_api.UpdateAuthorizationState).authorizationState);
        emit(td_api.UpdateAuthorizationState.CONSTRUCTOR, event);
        break;

      case td_api.UpdateNewChat.CONSTRUCTOR:
        _updateNewChatController((event as td_api.UpdateNewChat).chat);
        emit(td_api.UpdateNewChat.CONSTRUCTOR, event);
        break;
      case td_api.UpdateChatPosition.CONSTRUCTOR:
        _updateChatPositionController(event as td_api.UpdateChatPosition);
        emit(td_api.UpdateChatPosition.CONSTRUCTOR, event);
        break;

      case td_api.UpdateChatLastMessage.CONSTRUCTOR:
        _updateChatLastMessageController(event as td_api.UpdateChatLastMessage);
        emit(td_api.UpdateChatLastMessage.CONSTRUCTOR, event);
        break;
      case td_api.UpdateChatDraftMessage.CONSTRUCTOR:
        _updateChatDraftMessageController(
            event as td_api.UpdateChatDraftMessage);
        emit(td_api.UpdateChatDraftMessage.CONSTRUCTOR, event);
        break;
      case td_api.UpdateChatAction.CONSTRUCTOR:
        _updateChatActionController(event as td_api.UpdateChatAction);
        emit(td_api.UpdateChatAction.CONSTRUCTOR, event);
        break;
      default:
    }
  }

  handleAuthorizationStateUpdate(
      td_api.AuthorizationState authorizationState) async {
    switch (authorizationState.getConstructor()) {
      case td_api.AuthorizationStateClosed.CONSTRUCTOR:
        reset();
        break;
      default:
    }
  }

  onClientUpdate() {}

  void _updateNewChatController(td_api.Chat chat) {
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
    // TODO: make util for copying objects
    var chatCopy = td_api.Chat(
      id: chat.id,
      type: chat.type,
      title: chat.title,
      photo: chat.photo,
      permissions: chat.permissions,
      lastMessage: chat.lastMessage,
      positions: chat.positions,
      messageSenderId: chat.messageSenderId,
      hasProtectedContent: chat.hasProtectedContent,
      isMarkedAsUnread: chat.isMarkedAsUnread,
      isBlocked: chat.isBlocked,
      hasScheduledMessages: chat.hasScheduledMessages,
      canBeDeletedOnlyForSelf: chat.canBeDeletedOnlyForSelf,
      canBeDeletedForAllUsers: chat.canBeDeletedForAllUsers,
      canBeReported: chat.canBeReported,
      defaultDisableNotification: chat.defaultDisableNotification,
      unreadCount: chat.unreadCount,
      lastReadInboxMessageId: chat.lastReadInboxMessageId,
      lastReadOutboxMessageId: chat.lastReadOutboxMessageId,
      unreadMentionCount: chat.unreadMentionCount,
      notificationSettings: chat.notificationSettings,
      messageTtl: chat.messageTtl,
      themeName: chat.themeName,
      actionBar: chat.actionBar,
      videoChat: chat.videoChat,
      pendingJoinRequests: chat.pendingJoinRequests,
      replyMarkupMessageId: chat.replyMarkupMessageId,
      draftMessage: event.draftMessage,
      clientData: chat.clientData,
      extra: chat.extra,
      clientId: chat.clientId,
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
}
