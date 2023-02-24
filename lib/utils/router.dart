import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/pages/homepage/homepage.dart';
import 'package:minimalistic_telegram/pages/login/code_entry.dart';
import 'package:minimalistic_telegram/pages/login/login.dart';
import './const.dart';

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

      case homeRoute:
        return MaterialPageRoute(
          builder: (_) => const MyHomePage(title: 'Minigram'),
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
