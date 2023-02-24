import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/controllers/tdlib_controller.dart';
import 'package:minimalistic_telegram/services/locator.dart';
import 'package:minimalistic_telegram/services/telegram_service.dart';
import 'package:minimalistic_telegram/stores/application_store.dart';
import 'package:minimalistic_telegram/utils/const.dart';
import 'package:minimalistic_telegram/utils/router.dart' as util_router;
import 'package:provider/provider.dart';
import 'package:tdlib/td_client.dart';
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
        Provider<TdLibController>(
          create: (_) => TdLibController(),
          lazy: false,
        ),
        Provider<ApplicationStore>(
          create: (_) => ApplicationStore(),
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
  @override
  void initState() {
    super.initState();
    TdLibController().initClient();
  }

  @override
  void dispose() {
    super.dispose();
    var controller = TdLibController();
    controller.stop();
    controller.destroyClient();
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
