# minimalistic_telegram

Minimalistic and multiplatform Telegram client.

## Getting Started

1. Install dart and flutter on your machine.
   ```yaml
   environment:
      sdk: ">=2.18.0 <4.0.0"
      flutter: ">=3.3.0"
   ```

3. Install Android SDK.
4. Create a `.env` file in root.
5. Fill in following:

    ```md
    API_ID=
    API_HASH=
    ```

6. Request keys from whoever has them and put them in.
7. Install dependencies.
8. Create android emulator(or connect your phone)
9. Build app as usual for development.
10. Check helpful resources if stuck on any stage.

## Core features

This table includes all the core user stories for Telegram. The crossed out functionality will not be implemented. Every story has multiple options and will be covered in a separate document.

| Title                           | Description                                                                                  |
| ------------------------------- | -------------------------------------------------------------------------------------------- |
| Sending Messages                | Send text messages to contacts or groups, ensuring prompt and reliable delivery.             |
| Creating Groups                 | Create and manage groups for easy communication and collaboration among members.             |
| Sharing Media                   | Share photos, videos, audio files, and documents in their original quality.                  |
| Voice and Video Calls           | Make high-quality voice and video calls with contacts in real-time.                          |
| End-to-End Encryption           | Ensure secure conversations with end-to-end encryption for messages and calls.               |
| Message Editing and Deletion    | Edit or delete sent messages to correct errors or remove sensitive information.              |
| Privacy Settings                | Fine-grained control over privacy settings, profile visibility, and group membership.        |
| Multiple Device Syncing         | Sync messages and media across devices for easy access from any connected device.            |
| *Channel Subscription*          | Subscribe to channels for updates, news, or content from favorite creators or organizations. |
| Bot Interaction                 | Interact with bots for automated responses, information access, or task execution.           |
| Voice Messages                  | Send voice messages to convey emotions or complex messages effectively.                      |
| Location Sharing                | Share real-time location with contacts or groups for coordination or safety purposes.        |
| *Notification Management*       | Control notification type and frequency to avoid overwhelming alerts.                        |
| Multi-platform Support          | Use Telegram on various devices, including mobile, desktop, and web.                         |
| Secret Chats                    | Initiate secure chats with end-to-end encryption for enhanced privacy.                       |
| File Sharing and Cloud Storage  | Share large files and store them in the Telegram cloud for easy access.                      |
| ~~Stickers and GIFs~~           | Use stickers and GIFs to express creativity in conversations.                                |
| *Username and Public Profile*   | Set a unique username and public profile to facilitate connections with others.              |
| Chat Backup and Restore         | Back up chats and media to prevent data loss and restore them on new devices.                |
| Group Admin Features            | Manage group settings, membership, and moderation to maintain a positive group environment.  |
| Voice Chats in Groups           | Participate in real-time audio conversations within groups.                                  |
| Message Pinning                 | Pin important messages in chats or groups for easy access.                                   |
| Mentions and Replies            | Mention specific contacts in group chats and reply to messages for context.                  |
| ~~Custom Themes and Emojis~~    | Customize app appearance with themes and use a variety of emojis.                            |
| Chat Bots ~~and Games~~         | Interact with chatbots for various services and play games in the app.                       |
| Live Location Sharing           | Share real-time location with contacts for a specific duration.                              |
| Polls                           | Create and participate in polls within groups.                                               |
| Channel Admin Features          | Manage channel settings, moderation, and member permissions.                                 |
| Passcode Lock                   | Set a passcode or use biometric authentication for app security.                             |
| Contact Integration             | Sync device contacts within the Telegram app for easier connections.                         |
| Message Drafts                  | Automatically save message drafts for future completion.                                     |
| In-App Camera                   | Access a built-in camera for capturing and sending photos or videos.                         |
| Mute Conversations              | Temporarily mute specific conversations or groups.                                           |
| Read Receipts Control           | Disable read receipts to maintain privacy.                                                   |
| Data Usage Management           | Monitor and control data usage for media downloads and calls.                                |
| Message Search                  | Easily find specific messages or media in chats or groups.                                   |
| Notification Customization      | Customize notification sounds, patterns, and settings.                                       |
| Message Forwarding              | Forward messages, media, or conversations to other contacts or groups.                       |
| Temporary Messages              | Send messages with a set lifespan before they disappear.                                     |
| Multi-account Support           | Use multiple Telegram accounts simultaneously.                                               |
| Integration with Other Apps     | Seamless sharing of content between Telegram and other apps or services.                     |
| Live Streaming                  | Live stream video broadcasts within groups or channels.                                      |
| Language Localization           | Support for multiple languages in the app's interface and content.                           |
| Message Formatting              | Format text in messages for emphasis and clarity.                                            |
| Reply and Forward with Caption  | Reply to messages with quotes and add comments, or forward with captions.                    |
| Contact Sharing                 | Share contact information easily with other users.                                           |
| ~~Message Translation~~         | Translate messages written in foreign languages.                                             |
| ~~Animated Stickers~~           | Access animated stickers for expressive conversations.                                       |
| Message Pinning in Channels     | Pin important messages in channels for visibility to all subscribers.                        |
| Channel Statistics              | Access statistics and insights about channel performance.                                    |
| ~~Voice Chat Recordings~~       | Record voice chats for later listening.                                                      |
| ~~Link Previews~~               | Generate previews with thumbnails and descriptions for shared links.                         |
| Message Scheduling              | Schedule messages for specific delivery times.                                               |
| ~~Chat Folders~~                | Organize chats into custom folders based on topics or priorities.                            |
| Archive Chats                   | Archive less active or important chats for a clutter-free chat list.                         |
| Live Location Control           | Control the duration of sharing live location with others.                                   |
| Two-Factor Authentication (2FA) | Enable 2FA for extra account security.                                                       |

## The "Why"

We don't implement the crossed out features, because from practical perspective you don't need them. They take your attention and time and don't bring any usefulness except joy. We strongly believe that modern apps take too much of our time and attention. We want to make an app that will be as useful as possible and will take as little of your time as possible.

There's a separate type of features, that we implement, but hard to reach from userflow perspective. For example, chanel subsription. We believe that you don't need chanels in telegram, but if it is a critical case(Air Raid Alerts, Storm or Hurricane alerts etc.) you still can subscribe and have a channel, but it will be harder than with usual telegram and it will have some addition limitation afterwards.

## Helpful resources

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Tdlib documentation](https://core.telegram.org/tdlib)
- [Flutter Course](https://github.com/hamza1331/ngrok/blob/master/FreeCourseSite.com-Udemy%20-%20Flutter%20%26%20Dart%20-%20The%20Complete%20Guide%20%5B2021%20Edition%5D.torrent)
- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
