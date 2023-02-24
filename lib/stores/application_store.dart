import 'package:minimalistic_telegram/stores/event_emitter.dart';
import 'package:tdlib/td_api.dart' as td_api;

import '../controllers/tdlib_controller.dart';

// TODO: make it singleTon
class ApplicationStore extends EventEmitter {
  constructor() {
    reset();

    addTdLibListener();
    addStatistics();
  }

  void reset() {}

  void addTdLibListener() {
    TdLibController().on('update', onUpdate);
    // TdLibController().on('clientUpdate', onClientUpdate);
  }

  void addStatistics() {}
  //FIXME: update typings here
  onUpdate(event) async {
    switch (event.getConstructor()) {
      case td_api.UpdateAuthorizationState:
        await handleAuthorizationStateUpdate(event);
        emit('AnyTypeShouldFixThisToBeBasedOnTypesOnly', event);
        break;
      default:
    }
  }

  handleAuthorizationStateUpdate(td_api.UpdateAuthorizationState event) async {
    switch (event.getConstructor()) {
      case td_api.AuthorizationStateWaitTdlibParameters.CONSTRUCTOR:
        await TdLibController().sendTdLibParameters();
        return;
      case td_api.AuthorizationStateWaitEncryptionKey.CONSTRUCTOR:
        if ((event as td_api.AuthorizationStateWaitEncryptionKey).isEncrypted) {
          await TdLibController().send(
            const td_api.CheckDatabaseEncryptionKey(
              encryptionKey: 'mostrandomencryption',
            ),
          );
        } else {
          await TdLibController().send(
            const td_api.SetDatabaseEncryptionKey(
              newEncryptionKey: 'mostrandomencryption',
            ),
          );
        }
        return;
      case td_api.AuthorizationStateWaitPhoneNumber.CONSTRUCTOR:
      case td_api.AuthorizationStateClosed.CONSTRUCTOR:
        break;
      case td_api.AuthorizationStateReady.CONSTRUCTOR:
        break;
      case td_api.AuthorizationStateWaitCode.CONSTRUCTOR:
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
  }

  onClientUpdate() {}
}
