import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:tdlib/tdlib.dart';
import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/controllers/tdlib_controller.dart';
import 'package:minimalistic_telegram/services/locator.dart';
import 'package:minimalistic_telegram/stores/application_store.dart';
import 'package:minimalistic_telegram/stores/chat_store.dart';
import 'package:minimalistic_telegram/stores/file_store.dart';
import 'package:minimalistic_telegram/stores/filter_store.dart';
import 'package:minimalistic_telegram/stores/message_store.dart';
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
  final tdlibPath = kIsWeb
      ? null
      : (Platform.isAndroid || Platform.isLinux || Platform.isWindows)
          ? 'libtdjson.so'
          : null;

  print(tdlibPath);
  await TdPlugin.initialize(tdlibPath);
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
        Provider<MessageStore>(
          create: (_) => MessageStore(),
          lazy: false,
        ),
        Provider<FilterStore>(
          create: (_) => FilterStore(),
          lazy: false,
        ),
        Provider<FileStore>(
          create: (_) => FileStore(),
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
  String lastRoute = '';
  List<StreamSubscription> subscriptions = [];
  @override
  void initState() {
    super.initState();
    TdLibController().initClient();
    var appStore = context.read<ApplicationStore>();

    var subscription = appStore
        .on<td_api.UpdateAuthorizationState>()
        .listen(onAuthStateChange);
    subscriptions.add(subscription);
  }

  @override
  void dispose() {
    var controller = TdLibController();
    controller.stop();
    controller.destroyClient();

    for (var element in subscriptions) {
      element.cancel();
    }
    subscriptions = [];

    super.dispose();
  }

  void onAuthStateChange(event) {
    final constructorToAction = {
      td_api.AuthorizationStateWaitPhoneNumber: navigateToLogin,
      td_api.AuthorizationStateClosed: navigateToLogin,
      td_api.AuthorizationStateReady: goToMainPage,
      td_api.AuthorizationStateWaitCode: goToOtpPage,
    };

    final type = event.authorizationState.runtimeType;
    final action = constructorToAction[type];
    action?.call();
  }

  void goToOtpPage() {
    setState(() {
      lastRoute = otpRoute;
    });
    locator<NavigationService>().navigator.pushNamed(otpRoute);
    return;
  }

  void goToMainPage() {
    setState(() {
      lastRoute = homeRoute;
    });
    locator<NavigationService>()
        .navigator
        .pushNamedAndRemoveUntil(homeRoute, (route) => false);
  }

  void navigateToLogin() {
    setState(() {
      lastRoute = loginRoute;
    });
    locator<NavigationService>()
        .navigator
        .pushNamedAndRemoveUntil(loginRoute, (route) => false);
    Print.green("new route is: $loginRoute");
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
