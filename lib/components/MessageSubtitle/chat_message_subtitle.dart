import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/components/MessageSubtitle/draft_subtitle.dart';
import 'package:minimalistic_telegram/components/MessageSubtitle/text_subtitle.dart';
import 'package:minimalistic_telegram/components/MessageSubtitle/unsupported_subtitle.dart';

import 'package:palestine_console/palestine_console.dart';
import 'package:tdlib/td_api.dart' as td_api;

class ChatMessageSubtitle extends StatelessWidget {
  final td_api.Message? message;

  final td_api.DraftMessage? draftMessage;

  const ChatMessageSubtitle(
      {super.key, required this.message, required this.draftMessage});

  @override
  Widget build(BuildContext context) {
    var messageContent = message?.content;

    if (draftMessage != null) {
      return DraftSubtitle(
          text: (draftMessage?.inputMessageText as td_api.InputMessageText)
              .text
              .text);
    }

    switch (messageContent?.getConstructor() ?? '') {
      case td_api.MessageText.CONSTRUCTOR:
        return TextSubtitle(
            text: (messageContent as td_api.MessageText).text.text);
      case td_api.MessageAnimation.CONSTRUCTOR:
      case td_api.MessageAudio.CONSTRUCTOR:
      case td_api.MessageDocument.CONSTRUCTOR:
      case td_api.MessagePhoto.CONSTRUCTOR:
      case td_api.MessageExpiredPhoto.CONSTRUCTOR:
      case td_api.MessageSticker.CONSTRUCTOR:
      case td_api.MessageVideo.CONSTRUCTOR:
      case td_api.MessageExpiredVideo.CONSTRUCTOR:
      case td_api.MessageVideoNote.CONSTRUCTOR:
      case td_api.MessageVoiceNote.CONSTRUCTOR:
      case td_api.MessageLocation.CONSTRUCTOR:
      case td_api.MessageVenue.CONSTRUCTOR:
      case td_api.MessageContact.CONSTRUCTOR:
      case td_api.MessageAnimatedEmoji.CONSTRUCTOR:
      case td_api.MessageDice.CONSTRUCTOR:
      case td_api.MessageGame.CONSTRUCTOR:
      case td_api.MessagePoll.CONSTRUCTOR:
      case td_api.MessageInvoice.CONSTRUCTOR:
      case td_api.MessageCall.CONSTRUCTOR:
      case td_api.MessageVideoChatScheduled.CONSTRUCTOR:
      case td_api.MessageVideoChatStarted.CONSTRUCTOR:
      case td_api.MessageVideoChatEnded.CONSTRUCTOR:
      case td_api.MessageInviteVideoChatParticipants.CONSTRUCTOR:
      case td_api.MessageBasicGroupChatCreate.CONSTRUCTOR:
      case td_api.MessageSupergroupChatCreate.CONSTRUCTOR:
      case td_api.MessageChatChangeTitle.CONSTRUCTOR:
      case td_api.MessageChatChangePhoto.CONSTRUCTOR:
      case td_api.MessageChatDeletePhoto.CONSTRUCTOR:
      case td_api.MessageChatAddMembers.CONSTRUCTOR:
      case td_api.MessageChatJoinByLink.CONSTRUCTOR:
      case td_api.MessageChatJoinByRequest.CONSTRUCTOR:
      case td_api.MessageChatDeleteMember.CONSTRUCTOR:
      case td_api.MessageChatUpgradeTo.CONSTRUCTOR:
      case td_api.MessageChatUpgradeFrom.CONSTRUCTOR:
      case td_api.MessagePinMessage.CONSTRUCTOR:
      case td_api.MessageScreenshotTaken.CONSTRUCTOR:
      case td_api.MessageChatSetTheme.CONSTRUCTOR:
      case td_api.MessageChatSetTtl.CONSTRUCTOR:
      case td_api.MessageCustomServiceAction.CONSTRUCTOR:
      case td_api.MessageGameScore.CONSTRUCTOR:
      case td_api.MessagePaymentSuccessful.CONSTRUCTOR:
      case td_api.MessagePaymentSuccessfulBot.CONSTRUCTOR:
      case td_api.MessageContactRegistered.CONSTRUCTOR:
      case td_api.MessageWebsiteConnected.CONSTRUCTOR:
      case td_api.MessagePassportDataSent.CONSTRUCTOR:
      case td_api.MessagePassportDataReceived.CONSTRUCTOR:
      case td_api.MessageProximityAlertTriggered.CONSTRUCTOR:
      case td_api.MessageUnsupported.CONSTRUCTOR:
      default:
        return const UnsupportedSubtitle();
    }
  }
}
