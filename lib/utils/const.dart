import 'package:flutter/material.dart' show GlobalKey, NavigatorState;

const String initRoute = '/splash';
const String loginRoute = '/login';
const String otpRoute = '/code_entry';
const String homeRoute = '/';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get navigator => navigatorKey.currentState!;
}
