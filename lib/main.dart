import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/services/locator.dart';
import 'package:minimalistic_telegram/services/telegram_service.dart';
import 'package:minimalistic_telegram/utils/const.dart';
import 'package:minimalistic_telegram/utils/router.dart' as util_router;
import 'package:provider/provider.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;
  setupLocator();
  runApp(
    MultiProvider(
      providers: [
        Provider<TelegramService>(
          create: (_) => TelegramService(lastRouteName: initRoute),
          lazy: false,
        ),
      ],
      child: const MyNewApp(),
    ),
  );
}

class MyNewApp extends StatelessWidget {
  const MyNewApp({Key? key}) : super(key: key);
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
