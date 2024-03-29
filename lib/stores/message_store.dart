import 'dart:collection';
import 'dart:developer';

import 'package:minimalistic_telegram/models/ordered_chat.dart';
import 'package:minimalistic_telegram/stores/event_emitter.dart';
import 'package:palestine_console/palestine_console.dart';
import 'package:tdlib/td_api.dart' as td_api;
import 'package:change_case/change_case.dart';

import '../controllers/tdlib_controller.dart';

// TODO: make it singleTon
class MessageStore extends EventEmitter {
  Map<int, SplayTreeMap<int, td_api.Message>> items = {};

  late Map media;

  late Map selectedItems;

  late Map<Type, dynamic> eventHandlers = {};

  MessageStore() {
    reset();
    eventHandlers = _initEventHandlers();

    addTdLibListener();
  }

  _makeCorrectMessageJson(td_api.Message message, td_api.TdObject event) {
    return {
      ...message.toJson(),
      /**
         * this part exists because of a bug in tdlib
         * mediaAlbimId is in fact int, but in source code it tries to
         * int.parse(int), which causes error. So we cast it to string
         */
      'media_album_id': message.mediaAlbumId.toString(),
      ...event.toJson()
    };
    ;
  }

  _handleUpdateNewMessage(td_api.UpdateNewMessage updateNewMessage) {
    Print.yellow('_handleUpdateNewMessage');
    final message = updateNewMessage.message;
    final chatId = message.chatId;
    var chat = items[chatId];
    chat ??= SplayTreeMap();
    items[chatId] = chat;
    chat[message.id] = message;
  }

  _handlerNotImplemented(td_api.TdObject event) {
    Print.red('Handler for ${event.runtimeType.toString()} is not implemented');
  }

  void reset() {
    items = {};
    media = {};
    selectedItems = {};
  }

  void addTdLibListener() {
    TdLibController().on('event', onUpdate);
    // TdLibController().on('clientUpdate', onClientUpdate);
  }

  _handleUpdateMessageSendSucceeded(td_api.UpdateMessageSendSucceeded event) {
    Print.yellow('_handleUpdateMessageSendSucceeded');
    final message = event.message;
    final chatId = message.chatId;
    var chat = items[chatId];
    chat ??= SplayTreeMap();
    if (chat.containsKey(event.oldMessageId)) {
      chat.remove(event.oldMessageId);
    }

    _handleUpdateNewMessage(
        td_api.UpdateNewMessage(message: message, extra: event.extra));
  }

  _handleUpdateDeleteMessages(td_api.UpdateDeleteMessages event) {
    Print.yellow('_handleUpdateDeleteMessages');
    if (event.fromCache && !event.isPermanent) return;
    final chatId = event.chatId;

    var chat = items[chatId];
    chat ??= SplayTreeMap();
    for (final messageId in event.messageIds) {
      if (chat.containsKey(messageId)) {
        chat.remove(messageId);
      }
    }
  }

  _handleUpdateMessageEdited(td_api.UpdateMessageEdited event) {
    Print.yellow('_handleUpdateMessageEdited');
    final chatId = event.chatId;
    var chat = items[chatId];
    chat ??= SplayTreeMap();
    if (chat.containsKey(event.messageId) &&
        chat[event.messageId] is td_api.Message) {
      var json = _makeCorrectMessageJson(chat[event.messageId]!, event);

      var newMessage = td_api.Message.fromJson(json);
      _handleUpdateNewMessage(
          td_api.UpdateNewMessage(message: newMessage, extra: event.extra));
    }
  }

  _initEventHandlers() {
    return {
      td_api.UpdateAuthorizationState: handleAuthorizationStateUpdate,
      td_api.UpdateNewMessage: _handleUpdateNewMessage,
      td_api.UpdateAnimatedEmojiMessageClicked: _handlerNotImplemented,
      td_api.UpdateChatHasScheduledMessages: _handlerNotImplemented,
      td_api.UpdateChatMessageSender: _handlerNotImplemented,
      // td_api.UpdateChatMessageTtl: _handlerNotImplemented,
      td_api.UpdateDeleteMessages: _handleUpdateDeleteMessages,
      td_api.UpdateMessageContent: _handleUpdateMessageContent,
      td_api.UpdateMessageContentOpened: _handlerNotImplemented,
      td_api.UpdateMessageEdited: _handleUpdateMessageEdited,
      td_api.UpdateMessageInteractionInfo: _handlerNotImplemented,
      td_api.UpdateMessageIsPinned: _handlerNotImplemented,
      td_api.UpdateMessageLiveLocationViewed: _handlerNotImplemented,
      td_api.UpdateMessageMentionRead: _handlerNotImplemented,
      td_api.UpdateMessageSendAcknowledged: _handlerNotImplemented,
      td_api.UpdateMessageSendFailed: _handlerNotImplemented,
      td_api.UpdateMessageSendSucceeded: _handleUpdateMessageSendSucceeded,
      td_api.UpdateUnreadMessageCount: _handlerNotImplemented,
      // Add more mappings here
    };
  }

  //TODO: THIS IS HOW ALL UPDATES SHOULD BE HANDLED IN OTHER STORES

  onUpdate(td_api.TdObject event) async {
    final eventType = event.runtimeType;
    final handler = eventHandlers[eventType];
    if (handler != null) {
      await handler(event);
      emit(eventType.toString().toCamelCase(), event);
    } else {
      // Handle unknown event type
    }
  }

  handleAuthorizationStateUpdate(td_api.UpdateAuthorizationState update) async {
    var authorizationState = update.authorizationState;
    switch (authorizationState.getConstructor()) {
      case td_api.AuthorizationStateClosed.CONSTRUCTOR:
        reset();
        break;
      default:
    }
  }

  // _handleUpdateMessageInteractionInfo(
  //     td_api.UpdateMessageInteractionInfo event) {
  //   Print.yellow('_handleUpdateMessageInteractionInfo');
  //   final chatId = event.chatId;
  //   var chat = items[chatId];
  //   chat ??= SplayTreeMap();
  //   if (chat.containsKey(event.messageId) &&
  //       chat[event.messageId] is td_api.Message) {
  //     var json = _makeCorrectMessageJson(chat[event.messageId]!, event);

  //     var newMessage = td_api.Message.fromJson(json);
  //     _handleUpdateNewMessage(
  //         td_api.UpdateNewMessage(message: newMessage, extra: event.extra));
  //   }
  // }

  Future searchAllMessages({
    required String searchQuery,
    required int offsetDate,
    required int limit,
    required int offsetMessageId,
    required int offsetChatId,
    required int minDate,
    required int maxDate,
  }) async {
    var searchMessagesRequestBody = td_api.SearchMessages(
      query: searchQuery,
      offset: '',
      // offsetDate: offsetDate,
      limit: limit,
      // offsetMessageId: offsetMessageId,
      // offsetChatId: offsetChatId,
      minDate: minDate,
      maxDate: maxDate,
    );
    var messagesResponse = await TdLibController()
        .send<td_api.TdObject<dynamic>>(searchMessagesRequestBody);
    if (messagesResponse is td_api.TdError) {
      Print.red(messagesResponse.message);
    }
    return messagesResponse;
  }

  Future<void> getMessagesList(int chatId,
      {int fromMessageId = 0, int offset = 0, int limit = 100}) async {
    int receivedMessageCount = 0;
    int lastMessageId = fromMessageId;
    var chat = items[chatId];
    chat ??= SplayTreeMap();
    items[chatId] = chat;
    do {
      var getChatHistory = td_api.GetChatHistory(
          chatId: chatId,
          fromMessageId: lastMessageId,
          limit: limit,
          offset: offset,
          onlyLocal: false);
      Print.green('Request to get more messages happening');
      var messages = await TdLibController()
          .send<td_api.TdObject<dynamic>>(getChatHistory);

      if (messages is td_api.TdError) {
        Print.red(messages.message);
        return;
      } else {
        if ((messages as td_api.Messages).messages.isEmpty) {
          break;
        }
        lastMessageId = messages.messages.last.id;
        Print.blue(messages.totalCount.toString());

        for (var message in messages.messages) {
          chat[message.id] = message;
        }
        receivedMessageCount += (messages).messages.length;
        emit('messages', items);
      }
    } while (receivedMessageCount < limit);

    // TODO: find a better way to do this, cause this is a custom event
  }

  // send provided message of any content
  Future<void> sendMessage(
      int chatId, td_api.InputMessageContent content) async {
    var sendMessage = td_api.SendMessage(
        messageThreadId: 0,
        chatId: chatId,
        replyTo: null,
        replyMarkup: null,
        inputMessageContent: content);
    var tempMessage =
        await TdLibController().send<td_api.TdObject<dynamic>>(sendMessage);

    if (tempMessage is td_api.TdError) {
      Print.red((tempMessage).message);
      return;
    }
    _handleUpdateNewMessage(
        td_api.UpdateNewMessage(message: tempMessage as td_api.Message));
  }

  _handleUpdateMessageContent(td_api.UpdateMessageContent event) {
    Print.yellow('_handleUpdateMessageContent');
    final chatId = event.chatId;
    var chat = items[chatId];
    chat ??= SplayTreeMap();
    if (!chat.containsKey(event.messageId) ||
        (chat[event.messageId] is! td_api.Message)) {
      return;
    }
    var json = _makeCorrectMessageJson(chat[event.messageId]!, event);
    var newMessage = td_api.Message.fromJson(json);
    _handleUpdateNewMessage(
        td_api.UpdateNewMessage(message: newMessage, extra: event.extra));
  }
}
