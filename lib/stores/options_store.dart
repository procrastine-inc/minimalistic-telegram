import 'package:minimalistic_telegram/stores/event_emitter.dart';
import 'package:minimalistic_telegram/controllers/tdlib_controller.dart';
import 'package:tdlib/td_api.dart' as td_api;
import 'package:change_case/change_case.dart';

class OptionStore extends EventEmitter {
  Map<String, dynamic> items = {};

  late Map<Type, dynamic> eventHandlers = {};

  OptionStore() {
    reset();
    eventHandlers = _initEventHandlers();

    addTdLibListener();
  }

  _initEventHandlers() {
    return {
      td_api.UpdateAuthorizationState: _handleAuthorizationStateUpdate,
      td_api.UpdateOption: _handleUpdateOption,

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

  _handleUpdateOption(td_api.UpdateOption updateOption) async {
    final name = updateOption.name;
    final value = updateOption.value;
    set(name, value);
    // if (name == KEY_SUGGESTED_LANGUAGE_PACK_ID) {

    // }
    emit('updateOption', updateOption);
  }

  void reset() {
    items = {};
  }

  void addTdLibListener() {
    TdLibController().on('update', onUpdate);
  }

  void removeTdLibListener() {
    TdLibController().off('update', onUpdate);
  }

  void onUpdate(dynamic event) async {
    final eventType = event.runtimeType;
    final handler = eventHandlers[eventType];
    if (handler != null) {
      await handler(event);
      emit(eventType.toString().toCamelCase(), event);
    } else {
      // Handle unknown event type
    }
  }

  Future<dynamic> get(String name) async {
    var option = await TdLibController()
        .send<td_api.OptionValue>(td_api.GetOption(name: name));

    set(name, option);

    return items[name];
  }

  void set(String name, dynamic value) {
    items[name] = value;
  }
}

final OptionStore optionStore = OptionStore();
