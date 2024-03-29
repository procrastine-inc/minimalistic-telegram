import 'package:isar/isar.dart';
import 'package:minimalistic_telegram/models/db/app_usage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tdlib/td_api.dart' as td_api;
import "package:collection/collection.dart";

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

  Future<int> getEventsNumberPerTimeframe(
    String entityType,
    String actionType,
    DateTime start,
    DateTime end,
  ) async {
    final isar = await db;

    return await isar.appUsages
        .where()
        .filter()
        .timestampBetween(start, end)
        .and()
        .actionTypeEqualTo(actionType)
        .and()
        .actionEntitity((q) => q.entityTypeEqualTo(entityType))
        .count();
  }

  Future<int> getEventsNumberToday(
    String entityType,
    String actionType,
  ) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return getEventsNumberPerTimeframe(
        entityType, actionType, todayStart, todayEnd);
  }

  Future<int> getEventsNumberThisWeek(
    String entityType,
    String actionType,
  ) async {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day - now.weekday + 1);
    final weekEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return getEventsNumberPerTimeframe(
        entityType, actionType, weekStart, weekEnd);
  }

  Future<int> getEventsNumberThisMonth(
    String entityType,
    String actionType,
  ) async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return getEventsNumberPerTimeframe(
        entityType, actionType, monthStart, monthEnd);
  }

  Future<Duration> getTotalTimePerTimeframe(
    String entityType,
    String openActionType,
    String closeActionType,
    DateTime start,
    DateTime end,
  ) async {
    final isar = await db;

    final openEvents = await isar.appUsages
        .where()
        .filter()
        .timestampBetween(start, end)
        .and()
        .actionTypeEqualTo(openActionType)
        .and()
        .actionEntitity((q) => q.entityTypeEqualTo(entityType))
        .findAll();

    final closeEvents = await isar.appUsages
        .where()
        .filter()
        .timestampBetween(start, end)
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

  Future<Duration> getTotalTimeToday(
    String entityType,
    String openActionType,
    String closeActionType,
  ) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return getTotalTimePerTimeframe(
        entityType, openActionType, closeActionType, todayStart, todayEnd);
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

  Future<int> getChatOpenEventsNumberPerTimeframe(
    DateTime start,
    DateTime end,
  ) async {
    return await getEventsNumberPerTimeframe('Chat', 'Open', start, end);
  }

  Future<int> getChannelOpenEventsNumberPerTimeframe(
    DateTime start,
    DateTime end,
  ) async {
    return await getEventsNumberPerTimeframe('Channel', 'Open', start, end);
  }

  Future<int> getChatCloseEventsNumberPerTimeframe(
    DateTime start,
    DateTime end,
  ) async {
    return await getEventsNumberPerTimeframe('Chat', 'Close', start, end);
  }

  Future<int> getChannelCloseEventsNumberPerTimeframe(
    DateTime start,
    DateTime end,
  ) async {
    return await getEventsNumberPerTimeframe('Channel', 'Close', start, end);
  }

  Future<Duration> getChatTotalTimeOpenedPerTimeframe(
    DateTime start,
    DateTime end,
  ) async {
    return await getTotalTimePerTimeframe('Chat', 'Open', 'Close', start, end);
  }

  Future<Duration> getChannelTotalTimeOpenedPerTimeframe(
    DateTime start,
    DateTime end,
  ) async {
    return await getTotalTimePerTimeframe(
        'Channel', 'Open', 'Close', start, end);
  }

  Future<Map<int, Map<String, dynamic>>> getTopChatsPerTimeFrame(
      DateTime start, DateTime end,
      {int? limit}) async {
    final isar = await db;

    var chatActions = await isar.appUsages
        .where()
        .filter()
        .timestampBetween(start, end)
        .and()
        .group(
            (q) => q.actionTypeEqualTo('Open').or().actionTypeEqualTo('Close'))
        .and()
        .actionEntitity((q) => q.entityTypeEqualTo('Chat'))
        .findAll();

    var chatStats = <int, Map<String, dynamic>>{};

    // Group chat actions by chat ID
    var perChatMap = groupBy(
        chatActions, (element) => element.actionEntitity.value!.entityId);

    // Iterate through chat actions and calculate duration
    perChatMap.forEach((chatId, actions) {
      Duration totalDuration = Duration.zero;
      int usages = 0;

      for (int i = 0; i < actions.length - 1; i++) {
        var currentAction = actions[i];
        var nextAction = actions[i + 1];

        if (currentAction.actionType == 'Open' &&
            nextAction.actionType == 'Close') {
          totalDuration +=
              nextAction.timestamp.difference(currentAction.timestamp);
          usages++;
          i++; // Skip to the next open-close pair
        } else {
          throw Exception('Invalid action types');
        }
      }

      chatStats[chatId] = {
        'duration': totalDuration,
        'usages': usages,
      };
    });

    var sortedChatStats = chatStats.entries
        .sorted((a, b) => b.value['duration'].compareTo(a.value['duration']));

    var limitedChatStats =
        limit == null ? sortedChatStats : sortedChatStats.take(limit);

    return Map.fromEntries(limitedChatStats);
  }

  Future<Map<int, Map<String, dynamic>>> getTopChannelsPerTimeFrame(
      DateTime start, DateTime end,
      {int? limit}) async {
    final isar = await db;

    var channelActions = await isar.appUsages
        .where()
        .filter()
        .timestampBetween(start, end)
        .and()
        .group(
            (q) => q.actionTypeEqualTo('Open').or().actionTypeEqualTo('Close'))
        .and()
        .actionEntitity((q) => q.entityTypeEqualTo('Channel'))
        .findAll();

    var channelStats = <int, Map<String, dynamic>>{};

    // Group channel actions by channel ID
    var perChannelMap = groupBy(
        channelActions, (element) => element.actionEntitity.value!.entityId);

    // Iterate through channel actions and calculate duration
    perChannelMap.forEach((channelId, actions) {
      Duration totalDuration = Duration.zero;
      int usages = 0;

      for (int i = 0; i < actions.length - 1; i++) {
        var currentAction = actions[i];
        var nextAction = actions[i + 1];

        if (currentAction.actionType == 'Open' &&
            nextAction.actionType == 'Close') {
          totalDuration +=
              nextAction.timestamp.difference(currentAction.timestamp);
          usages++;
          i++; // Skip to the next open-close pair
        } else {
          throw Exception('Invalid action types');
        }
      }

      channelStats[channelId] = {
        'duration': totalDuration,
        'usages': usages,
      };
    });

    var sortedChannelStats = channelStats.entries
        .sorted((a, b) => b.value['duration'].compareTo(a.value['duration']));

    var limitedChannelStats =
        limit == null ? sortedChannelStats : sortedChannelStats.take(limit);

    return Map.fromEntries(limitedChannelStats);
  }

  Future<Map<int, Map<String, dynamic>>> getTopChatsToday({int? limit}) async {
    return await getTopChatsPerTimeFrame(
      DateTime.now(),
      DateTime.now().add(const Duration(days: 1)),
      limit: limit,
    );
  }

  Future<Map<int, Map<String, dynamic>>> getTopChatsThisWeek(
      {int? limit}) async {
    return await getTopChatsPerTimeFrame(
      DateTime.now(),
      DateTime.now().add(const Duration(days: 7)),
      limit: limit,
    );
  }

  Future<Map<int, Map<String, dynamic>>> getTopChatsThisMonth(
      {int? limit}) async {
    return await getTopChatsPerTimeFrame(
      DateTime.now(),
      DateTime.now().add(const Duration(days: 30)),
      limit: limit,
    );
  }

  Future<Map<int, Map<String, dynamic>>> getTopChannelsToday(
      {int? limit}) async {
    return await getTopChannelsPerTimeFrame(
      DateTime.now(),
      DateTime.now().add(const Duration(days: 1)),
      limit: limit,
    );
  }

  Future<Map<int, Map<String, dynamic>>> getTopChannelsThisWeek(
      {int? limit}) async {
    return await getTopChannelsPerTimeFrame(
      DateTime.now(),
      DateTime.now().add(const Duration(days: 7)),
      limit: limit,
    );
  }

  Future<Map<int, Map<String, dynamic>>> getTopChannelsThisMonth(
      {int? limit}) async {
    return await getTopChannelsPerTimeFrame(
      DateTime.now(),
      DateTime.now().add(const Duration(days: 30)),
      limit: limit,
    );
  }
}
