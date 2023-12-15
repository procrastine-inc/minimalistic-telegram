import 'package:flutter/material.dart' show GlobalKey, NavigatorState;

const String initRoute = '/splash';
const String loginRoute = '/login';
const String otpRoute = '/code_entry';
const String homeRoute = '/';
const String searchRoute = '/search';
const String chatRoute = '/chat';
const String settingsRoute = '/settings';
const String channelSearchRoute = '/channel_search';
const String statsRoute = '/stats_route';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get navigator => navigatorKey.currentState!;
}
