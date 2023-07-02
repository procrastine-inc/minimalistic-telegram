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
  Map<int, SplayTreeMap<int, td_api.Message>> items = SplayTreeMap();

  late Map media;

  late Map selectedItems;

  late Map<Type, dynamic> eventHandlers = {};

  MessageStore() {
    reset();
    eventHandlers = _initEventHandlers();

    addTdLibListener();
  }

  _handleUpdateNewMessage(td_api.UpdateNewMessage updateNewMessage) {
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
    items = SplayTreeMap();
    media = {};
    selectedItems = {};
  }

  void addTdLibListener() {
    TdLibController().on('event', onUpdate);
    // TdLibController().on('clientUpdate', onClientUpdate);
  }

  _handleUpdateMessageSendSucceeded(td_api.UpdateMessageSendSucceeded event) {
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

  _initEventHandlers() {
    return {
      td_api.UpdateAuthorizationState: handleAuthorizationStateUpdate,
      td_api.UpdateNewMessage: _handleUpdateNewMessage,
      td_api.UpdateAnimatedEmojiMessageClicked: _handlerNotImplemented,
      td_api.UpdateChatDraftMessage: _handlerNotImplemented,
      td_api.UpdateChatHasScheduledMessages: _handlerNotImplemented,
      td_api.UpdateChatMessageSender: _handlerNotImplemented,
      td_api.UpdateChatMessageTtl: _handlerNotImplemented,
      td_api.UpdateDeleteMessages: _handlerNotImplemented,
      td_api.UpdateMessageContent: _handlerNotImplemented,
      td_api.UpdateMessageContentOpened: _handlerNotImplemented,
      td_api.UpdateMessageEdited: _handlerNotImplemented,
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

  onUpdate(td_api.TdObject event) {
    final eventType = event.runtimeType;
    final handler = eventHandlers[eventType];
    if (handler != null) {
      handler(event);
      emit(eventType.toString().toCamelCase(),
          event); // TODO: camelCasing here is a hack, fix it
    } else {
      // Handle unknown event type
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

  Future<void> getMessagesList(int chatId,
      {int fromMessageId = 0, int offset = 0}) async {
    var getChatHistory = td_api.GetChatHistory(
        chatId: chatId,
        fromMessageId: fromMessageId,
        limit: 100,
        offset: offset,
        onlyLocal: false);
    var messages =
        await TdLibController().send<td_api.Messages>(getChatHistory);
    Print.blue(messages.totalCount.toString());
    var chat = items[chatId];
    chat ??= SplayTreeMap();
    items[chatId] = chat;
    for (var message in messages.messages) {
      chat[message.id] = message;
    }
    // TODO: find a better way to do this, cause this is a custom event
    emit('messages', items);
  }

  // send provided message of any content
  Future<void> sendMessage(
      int chatId, td_api.InputMessageContent content) async {
    var sendMessage = td_api.SendMessage(
        messageThreadId: 0,
        chatId: chatId,
        replyToMessageId: 0,
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
}
