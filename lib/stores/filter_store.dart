import 'package:minimalistic_telegram/stores/event_emitter.dart';
import 'package:tdlib/td_api.dart' as td_api;

import '../controllers/tdlib_controller.dart';

// TODO: make it singleTon
class FilterStore extends EventEmitter {
  late List<td_api.ChatFilterInfo>? filters;
  late td_api.ChatList chatList;
  FilterStore() {
    reset();

    addTdLibListener();
  }

  void reset() {
    chatList = const td_api.ChatListMain();
    filters = null;
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
      case td_api.UpdateChatFilters.CONSTRUCTOR:
        filters = (event as td_api.UpdateChatFilters).chatFilters;
        emit('updateChatFilters', event);
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
}
