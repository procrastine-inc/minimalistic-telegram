import 'dart:collection';
import 'dart:developer';

import 'package:minimalistic_telegram/stores/event_emitter.dart';
import 'package:minimalistic_telegram/stores/options_store.dart';
import 'package:tdlib/td_api.dart' as td_api;
import 'package:change_case/change_case.dart';
import '../controllers/tdlib_controller.dart';

class UserStore extends EventEmitter {
  Map<int, td_api.User> items = {};
  Map<int, td_api.UserFullInfo> fullInfoItems = {};

  late Map<Type, dynamic> eventHandlers = {};

  UserStore() {
    reset();
    eventHandlers = _initEventHandlers();

    addTdLibListener();
  }

  _initEventHandlers() {
    return {
      td_api.UpdateAuthorizationState: _handleAuthorizationStateUpdate,
      td_api.UpdateUser: _handleUpdateUser,
      td_api.UpdateUserFullInfo: _handleUpdateUserFullInfo,
      td_api.UpdateUserStatus: _handleUpdateUserStatus,

      // Add more mappings here
    };
  }

  _handleAuthorizationStateUpdate(
      td_api.UpdateAuthorizationState authorizationStateUpdate) async {
    final authorizationState = authorizationStateUpdate.authorizationState;
    switch (authorizationState.getConstructor()) {
      case td_api.AuthorizationStateClosed.CONSTRUCTOR:
        reset();
        break;
      default:
    }
  }

  _handleUpdateUser(td_api.UpdateUser updateUser) async {
    final user = updateUser.user;
    set(user);
    emit('updateUser', updateUser);
  }

  _handleUpdateUserFullInfo(
      td_api.UpdateUserFullInfo updateUserFullInfo) async {
    final userFullInfo = updateUserFullInfo.userFullInfo;
    final userId = updateUserFullInfo.userId;
    setFullInfo(userId, userFullInfo);
    emit('updateUserFullInfo', updateUserFullInfo);
  }

  _handleUpdateUserStatus(td_api.UpdateUserStatus updateUserStatus) async {
    final user = await get(updateUserStatus.userId);
    if (user != null) {
      var userCopyWithNewStatus = user.copyWith(
        status: updateUserStatus.status,
      );
      set(userCopyWithNewStatus);
    }
    emit('updateUserStatus', updateUserStatus);
  }

  void reset() {
    items = {};
    fullInfoItems = {};
  }

  void addTdLibListener() {
    TdLibController().on('event', onUpdate);
    // TdLibController().on('clientUpdate', onClientUpdate);
  }

  assign(source1, source2) {
    source1.assignAll(source2);
  }

  Future<int?> getMyId() async {
    td_api.OptionValue myIdOption = await optionStore.get('my_id');

    if (myIdOption is td_api.OptionValueInteger) {
      return myIdOption.value;
    }
  }

  Future<td_api.User?> get(int userId) async {
    if (items[userId] == null) {
      var user = await TdLibController()
          .send<td_api.User>(td_api.GetUser(userId: userId));
      set(user);
    }
    return items[userId];
  }

  void set(td_api.User user) {
    items[user.id] = user;
  }

  Future<td_api.UserFullInfo?> getFullInfo(int id) async {
    var fullInfo = await TdLibController().send(
      td_api.GetUserFullInfo(userId: id),
    );

    if (fullInfo is td_api.UserFullInfo) {
      setFullInfo(id, fullInfo);
    }

    return fullInfoItems[id];
  }

  void setFullInfo(int id, td_api.UserFullInfo fullInfo) {
    fullInfoItems[id] = fullInfo;
  }

  void onUpdate(td_api.TdObject event) async {
    final eventType = event.runtimeType;
    final handler = eventHandlers[eventType];
    if (handler != null) {
      await handler(event);
      emit(eventType.toString().toCamelCase(), event);
    } else {
      // Handle unknown event type
    }
  }

  // void onClientUpdate(td_api.TdObject event) {
  //   final eventType = event.runtimeType;

  //   if (eventType == td_api.ClientUpdateOpenUser) {
  //     emit(eventType.toString(), event);
  //   }
  // }
}
