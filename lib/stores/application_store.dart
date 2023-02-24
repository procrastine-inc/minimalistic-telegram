import 'package:minimalistic_telegram/stores/event_emitter.dart';
import 'package:tdlib/td_api.dart' as td_api;

import '../controllers/tdlib_controller.dart';

// TODO: make it singleTon
class ApplicationStore extends EventEmitter {
  ApplicationStore() {
    reset();

    addTdLibListener();
    addStatistics();
  }

  void reset() {}

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
        emit('AnyTypeShouldFixThisToBeBasedOnTypesOnly', event);
        break;
      default:
    }
  }

  handleAuthorizationStateUpdate(event) async {
    switch (event.getConstructor()) {
      case td_api.AuthorizationStateWaitTdlibParameters.CONSTRUCTOR:
        await TdLibController().sendTdLibParameters();
        return;
      case td_api.AuthorizationStateWaitEncryptionKey.CONSTRUCTOR:
        if ((event as td_api.AuthorizationStateWaitEncryptionKey).isEncrypted) {
          await TdLibController().send(
            const td_api.CheckDatabaseEncryptionKey(
              encryptionKey: 'mostrandomencryption', // TODO: wtf, fix this
            ),
          );
        } else {
          await TdLibController().send(
            const td_api.SetDatabaseEncryptionKey(
              newEncryptionKey: 'mostrandomencryption', // TODO: wtf, fix this
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
