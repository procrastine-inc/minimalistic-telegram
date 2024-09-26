import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/pages/ChatBasePage.dart';
import 'package:minimalistic_telegram/pages/SettingsPage/index.dart';
import 'package:minimalistic_telegram/pages/analytics_page.dart';
import 'package:minimalistic_telegram/pages/channel_search_page.dart';
import 'package:minimalistic_telegram/pages/contacts_page.dart';
import 'package:minimalistic_telegram/pages/global_search_page.dart';
import 'package:minimalistic_telegram/pages/homepage/homepage.dart';
import 'package:minimalistic_telegram/pages/login/code_entry.dart';
import 'package:minimalistic_telegram/pages/login/login.dart';
import 'package:minimalistic_telegram/pages/splash.dart';
import './const.dart';
import 'package:tdlib/td_api.dart' as td_api;

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case otpRoute:
        return MaterialPageRoute(
          builder: (_) => const CodeEntryScreen(),
        );
      case loginRoute:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      case initRoute:
        return MaterialPageRoute(
          builder: (_) => const Splash(),
        );
      case homeRoute:
        return MaterialPageRoute(
          builder: (_) => const MyHomePage(title: 'Minigram'),
        );
      case searchRoute:
        return MaterialPageRoute(
          builder: (_) => const GlobalSearchPage(),
        );
      case channelSearchRoute:
        return CupertinoPageRoute(
          builder: (_) => const ChannelSearchPage(),
        );
      case chatRoute:
        var chat = settings.arguments as td_api.Chat;
        return CupertinoPageRoute(builder: (context) {
          return ChatBasePage(chat: chat);
        });
      case settingsRoute:
        return CupertinoPageRoute(
          builder: (_) => const SettingsPage(),
        );
      case statsRoute:
        return CupertinoPageRoute(
          builder: (_) => const AppUsageStatsPage(),
        );
      case contactsRoute:
        return CupertinoPageRoute(
          builder: (_) => const ContactsPage(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
                child: Text(
              'No route defined for ${settings.name}',
            )),
          ),
        );
    }
  }
}
