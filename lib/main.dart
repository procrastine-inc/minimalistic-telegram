import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/pages/SettingsPage/index.dart';
import 'package:minimalistic_telegram/services/locator.dart';
import 'package:minimalistic_telegram/services/telegram_service.dart';
import 'package:minimalistic_telegram/utils/const.dart';
import 'package:minimalistic_telegram/utils/router.dart' as util_router;
import 'package:provider/provider.dart';
import 'package:tdlib/td_client.dart';
import 'components/ChatsList/index.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;
  await TdPlugin.initialize();
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
      theme: ThemeData.dark(),
      onGenerateRoute: util_router.Router.generateRoute,
      initialRoute: initRoute,
    );
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // Try running your application with "flutter run". You'll see the
//         // application has a blue toolbar. Then, without quitting the app, try
//         // changing the primarySwatch below to Colors.green and then invoke
//         // "hot reload" (press "r" in the console where you ran "flutter run",
//         // or simply save your changes to "hot reload" in a Flutter IDE).
//         // Notice that the counter didn't reset back to zero; the application
//         // is not restarted.
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'Minigram'),
//     );
//   }
// }

