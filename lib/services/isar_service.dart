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

  Future<void> addEventForEntity(
    String entityType,
    int entityId,
    String actionType,
  ) async {
    final isar = await db;
    var actionEntity = await isar.actionEntitys
        .where()
        .filter()
        .entityTypeEqualTo(entityType)
        .and()
        .entityIdEqualTo(entityId)
        .findFirst();

    actionEntity ??= ActionEntity()
      ..entityType = entityType
      ..entityId = entityId;

    var appUsage = AppUsage()
      ..timestamp = DateTime.now()
      ..actionType = actionType
      ..actionEntitity.value = actionEntity;

    await isar.writeTxn(() async {
      await isar.appUsages.put(appUsage);
      await isar.actionEntitys.put(actionEntity!);
      await appUsage.actionEntitity.save();
    });
  }

  Future<int> getEventsNumberToday(
    String entityType,
    String actionType,
  ) async {
    final isar = await db;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return await isar.appUsages
        .where()
        .filter()
        .timestampBetween(todayStart, todayEnd)
        .and()
        .actionTypeEqualTo(actionType)
        .and()
        .actionEntitity((q) => q.entityTypeEqualTo(entityType))
        .count();
  }

  Future<Duration> getTotalTimeToday(
    String entityType,
    String openActionType,
    String closeActionType,
  ) async {
    final isar = await db;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final openEvents = await isar.appUsages
        .where()
        .filter()
        .timestampBetween(todayStart, todayEnd)
        .and()
        .actionTypeEqualTo(openActionType)
        .and()
        .actionEntitity((q) => q.entityTypeEqualTo(entityType))
        .findAll();

    final closeEvents = await isar.appUsages
        .where()
        .filter()
        .timestampBetween(todayStart, todayEnd)
        .and()
        .actionTypeEqualTo(closeActionType)
        .and()
        .actionEntitity((q) => q.entityTypeEqualTo(entityType))
        .findAll();

    if (openEvents.length != closeEvents.length) {
      if (openEvents.length > closeEvents.length) {
        openEvents.removeRange(closeEvents.length, openEvents.length);
      } else {
        closeEvents.removeRange(openEvents.length, closeEvents.length);
      }
    }

    var zipEvents = List.generate(openEvents.length, (index) {
      return [openEvents[index], closeEvents[index]];
    });

    var timeRanges = zipEvents.map((eventPair) {
      return eventPair[1].timestamp.difference(eventPair[0].timestamp);
    });

    var sum = timeRanges.fold(
      const Duration(),
      (previousValue, element) => previousValue + element,
    );

    return sum;
  }

  Future<void> addChatOpened(td_api.Chat chat) async {
    await addEventForEntity('Chat', chat.id, 'Open');
  }

  Future<void> addChatClosed(td_api.Chat chat) async {
    await addEventForEntity('Chat', chat.id, 'Close');
  }

  Future<void> addChannelOpened(td_api.Chat chat) async {
    await addEventForEntity('Channel', chat.id, 'Open');
  }

  Future<void> addChannelClosed(td_api.Chat chat) async {
    await addEventForEntity('Channel', chat.id, 'Close');
  }

  Future<int> getChatOpenEventsNumberToday() async {
    return await getEventsNumberToday('Chat', 'Open');
  }

  Future<int> getChatCloseEventsNumberToday() async {
    return await getEventsNumberToday('Chat', 'Close');
  }

  Future<Duration> getChatTotalTimeOpenedToday() async {
    return await getTotalTimeToday('Chat', 'Open', 'Close');
  }
}
