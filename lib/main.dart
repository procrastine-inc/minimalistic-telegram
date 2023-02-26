import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/controllers/tdlib_controller.dart';
import 'package:minimalistic_telegram/services/locator.dart';
import 'package:minimalistic_telegram/stores/application_store.dart';
import 'package:minimalistic_telegram/stores/chat_store.dart';
import 'package:minimalistic_telegram/stores/filter_store.dart';
import 'package:minimalistic_telegram/utils/const.dart';
import 'package:minimalistic_telegram/utils/router.dart' as util_router;
import 'package:palestine_console/palestine_console.dart';
import 'package:provider/provider.dart';
import 'package:tdlib/td_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tdlib/td_api.dart' as td_api;

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;
  await TdPlugin.initialize();
  setupLocator();
  runApp(
    MultiProvider(
      providers: [
        Provider<TdLibController>(
          create: (_) => TdLibController(),
          lazy: false,
        ),
        Provider<ApplicationStore>(
          create: (_) => ApplicationStore(),
          lazy: false,
        ),
        Provider<ChatStore>(
          create: (_) => ChatStore(),
          lazy: false,
        ),
        Provider<FilterStore>(
          create: (_) => FilterStore(),
          lazy: false,
        ),
      ],
      child: const MyNewApp(),
    ),
  );
}

class MyNewApp extends StatefulWidget {
  const MyNewApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyNewAppState();
}

class _MyNewAppState extends State<MyNewApp> {
  String authState = '';
  String lastRoute = '';
  @override
  void initState() {
    super.initState();
    TdLibController().initClient();
    authState = '';
    var appStore = context.read<ApplicationStore>();
    appStore.on(td_api.UpdateAuthorizationState.CONSTRUCTOR, onAuthStateChange);
  }

  @override
  void dispose() {
    super.dispose();
    var controller = TdLibController();
    controller.stop();
    controller.destroyClient();
    var appStore = context.read<ApplicationStore>();
    authState = '';
    appStore.off(
        td_api.UpdateAuthorizationState.CONSTRUCTOR, onAuthStateChange);
  }

  void onAuthStateChange(event) {
    var route = lastRoute;
    setState(() {
      authState = (event).authorizationState.getConstructor();
    });

    // debugger();
    switch (event.authorizationState.getConstructor()) {
      case td_api.AuthorizationStateWaitPhoneNumber.CONSTRUCTOR:
      case td_api.AuthorizationStateClosed.CONSTRUCTOR:
        Print.green("im here, I have to work and assign");
        route = loginRoute;
        Print.green("new route is: $route");
        break;
      case td_api.AuthorizationStateReady.CONSTRUCTOR:
        route = homeRoute;
        break;
      case td_api.AuthorizationStateWaitCode.CONSTRUCTOR:
        route = otpRoute;
        break;
      default:
        break;
    }
    Print.red('route: $route');
    if (route == lastRoute) return;
    setState(() {
      lastRoute = route;
    });

    locator<NavigationService>().navigateTo(route);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: locator<NavigationService>().navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: util_router.Router.generateRoute,
      initialRoute: initRoute,
    );
  }
}
