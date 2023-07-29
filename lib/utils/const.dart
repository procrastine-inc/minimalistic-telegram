import 'package:flutter/material.dart' show GlobalKey, NavigatorState;

const String initRoute = '/splash';
const String loginRoute = '/login';
const String otpRoute = '/code_entry';
const String homeRoute = '/';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  Future<dynamic> navigateTo(String routeName) {
    return navigatorKey.currentState!.pushNamed(routeName);
  }

  Future<dynamic> navigateToReplacement(String routeName) {
    return navigatorKey.currentState!.pushReplacementNamed(routeName);
  }

  Future<dynamic> navigateToAndRemoveUntil(String routeName) {
    return navigatorKey.currentState!
        .pushNamedAndRemoveUntil(routeName, (route) => false);
  }
}
