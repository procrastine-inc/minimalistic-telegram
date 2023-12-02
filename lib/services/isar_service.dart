import 'package:isar/isar.dart';
import 'package:minimalistic_telegram/models/db/app_usage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tdlib/td_api.dart' as td_api;

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [AppUsageSchema, ActionEntitySchema],
        directory: dir.path,
        inspector: true,
      );
    }

    return Future.value(Isar.getInstance());
  }

  // Method to add a new app usage entry to the database
  Future<void> addAppUsage(AppUsage appUsage) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.appUsages.put(appUsage);
    });
  }

  Future<void> addChatOpened(td_api.Chat chat) async {
    final isar = await db;
    var actionEntity = await isar.actionEntitys
        .where()
        .filter()
        .entityTypeEqualTo('Chat')
        .and()
        .entityIdEqualTo(chat.id)
        .findFirst();

    actionEntity ??= ActionEntity()
      ..entityType = 'Chat'
      ..entityId = chat.id;

    var appUsage = AppUsage()
      ..timestamp = DateTime.now()
      ..actionType = 'Open'
      ..actionEntitity.value = actionEntity;
    await isar.writeTxn(() async {
      await isar.appUsages.put(appUsage);
      await isar.actionEntitys.put(actionEntity!);
      await appUsage.actionEntitity.save();
    });
  }

  Future<void> addChatClosed(td_api.Chat chat) async {
    final isar = await db;
    var actionEntity = await isar.actionEntitys
        .where()
        .filter()
        .entityTypeEqualTo('Chat')
        .and()
        .entityIdEqualTo(chat.id)
        .findFirst();

    actionEntity ??= ActionEntity()
      ..entityType = 'Chat'
      ..entityId = chat.id;

    var appUsage = AppUsage()
      ..timestamp = DateTime.now()
      ..actionType = 'Close'
      ..actionEntitity.value = actionEntity;
    await isar.writeTxn(() async {
      await isar.appUsages.put(appUsage);
      await isar.actionEntitys.put(actionEntity!);
      await appUsage.actionEntitity.save();
    });
  }
}
