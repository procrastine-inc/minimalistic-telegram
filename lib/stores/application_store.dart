import 'dart:developer';

import 'package:event_bus/event_bus.dart';
import 'package:minimalistic_telegram/stores/event_emitter.dart';
import 'package:tdlib/td_api.dart' as td_api;

import '../controllers/tdlib_controller.dart';

// TODO: make it singleTon
class ApplicationStore extends EventBus {
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
  onUpdate(td_api.TdObject event) {
    switch (event.getConstructor()) {
      case td_api.UpdateAuthorizationState.CONSTRUCTOR:
        handleAuthorizationStateUpdate(
            (event as td_api.UpdateAuthorizationState).authorizationState);
        fire(event);

        break;
      default:
    }
  }

  handleAuthorizationStateUpdate(event) {
    // print(event.toJSON());
    switch (event.getConstructor()) {
      case td_api.AuthorizationStateWaitTdlibParameters.CONSTRUCTOR:
        TdLibController().sendTdLibParameters();
        return;
      // case td_api.AuthorizationStateWaitEncryptionKey.CONSTRUCTOR:
      //   if ((event as td_api.AuthorizationStateWaitEncryptionKey).isEncrypted) {
      //     TdLibController().send(
      //       const td_api.CheckDatabaseEncryptionKey(
      //         encryptionKey: 'mostrandomencryption', // TODO: wtf, fix this
      //       ),
      //     );
      //   } else {
      //     TdLibController().send(
      //       const td_api.SetDatabaseEncryptionKey(
      //         newEncryptionKey: 'mostrandomencryption', // TODO: wtf, fix this
      //       ),
      //     );
      //   }
      //   // emit(td_api.UpdateAuthorizationState.CONSTRUCTOR, event);
      //   return;
      case td_api.AuthorizationStateWaitPhoneNumber.CONSTRUCTOR:
      case td_api.AuthorizationStateClosed.CONSTRUCTOR:
      case td_api.AuthorizationStateReady.CONSTRUCTOR:
      case td_api.AuthorizationStateWaitCode.CONSTRUCTOR:
        // emit(td_api.UpdateAuthorizationState.CONSTRUCTOR, event);
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

  Future setAuthenticationPhoneNumber(
    String phoneNumber, {
    required void Function(td_api.TdError) onError,
  }) async {
    final result = await TdLibController().send(
      td_api.SetAuthenticationPhoneNumber(
        phoneNumber: phoneNumber,
        settings: const td_api.PhoneNumberAuthenticationSettings(
          allowFlashCall: false,
          isCurrentPhoneNumber: false,
          allowSmsRetrieverApi: false,
          allowMissedCall: true,
          authenticationTokens: [],
        ),
      ),
    );
    if (result != null && result is td_api.TdError) {
      onError(result);
    }
  }

  Future checkAuthenticationCode(
    String code, {
    required void Function(td_api.TdError) onError,
  }) async {
    final result = await TdLibController().send(
      td_api.CheckAuthenticationCode(
        code: code,
      ),
    );
    if (result != null && result is td_api.TdError) {
      onError(result);
    }
  }

  onClientUpdate() {}
}
