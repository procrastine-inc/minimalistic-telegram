import 'dart:collection';
import 'dart:developer';
import 'package:change_case/change_case.dart';
import 'package:event_bus/event_bus.dart';
import 'package:minimalistic_telegram/models/ordered_chat.dart';
import 'package:palestine_console/palestine_console.dart';
import 'package:tdlib/td_api.dart' as td_api;

import '../controllers/tdlib_controller.dart';

class FileStore extends EventBus {
  static final FileStore _fileStore = FileStore._internal();

  late Map<int, td_api.File> items;
  late Map<Type, dynamic> eventHandlers = {};

  factory FileStore() {
    return _fileStore;
  }

  FileStore._internal() {
    reset();
    eventHandlers = _initEventHandlers();

    addTdLibListener();
  }

  void reset() {
    items = {};
  }

  void addTdLibListener() {
    TdLibController().on('event', onUpdate);
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

  _initEventHandlers() {
    return {
      td_api.UpdateAuthorizationState: _handleAuthorizationStateUpdate,
      td_api.UpdateFile: _handleUpdateFile,
    };
  }

  _handleUpdateFile(td_api.UpdateFile event) {
    Print.yellow('_handleUpdateFile');
    final file = event.file;
    final fileId = file.id;
    items[fileId] = file;
  }

  downloadFile(td_api.File file, {td_api.User? user}) async {
    Print.green(
        'Request to downloadFile'); // firing, because we don't have files in store at this point. it's okay to have it here
    final fileId = file.id;
    var response = await TdLibController().send(td_api.DownloadFile(
        fileId: fileId, limit: 0, priority: 1, offset: 0, synchronous: true));
    if (response is td_api.File) {
      Print.green('File downloaded');
      items[fileId] = response;
      fire(td_api.UpdateFile(file: response));
    }
    Print.magenta(response.toString());
  }
}
