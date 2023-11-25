import 'package:isar/isar.dart';
import 'package:minimalistic_telegram/models/db/app_usage.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [AppUsageSchema],
        directory: dir.path,
        inspector: true,
      );
    }

    return Future.value(Isar.getInstance());
  }

  // Future<List<AppUsage>> getAppUsagesForTimeRange(
  //     DateTime from, DateTime to) async {
  //   final isar = await db;
  //   return await isar.appUsages.filter().timestampBetween(from, to).findAll();
  // }

  // Future<List<AppUsage>> getAppUsagesForDay(DateTime day) async {
  //   final startOfDay = DateTime(day.year, day.month, day.day);
  //   final endOfDay = startOfDay
  //       .add(const Duration(days: 1))
  //       .subtract(const Duration(milliseconds: 1));
  //   return await getAppUsagesForTimeRange(startOfDay, endOfDay);
  // }

  // Future<List<AppUsage>> getAppUsagesForActionType(String actionType) async {
  //   final isar = await db;
  //   return await isar.appUsages
  //       .filter()
  //       .actionTypeEqualTo(actionType)
  //       .findAll();
  // }

  // Future<int> getCountOfActionTypeForTimeRange(
  //     String actionType, DateTime from, DateTime to) async {
  //   final usages = await getAppUsagesForTimeRange(from, to);
  //   return usages.where((usage) => usage.actionType == actionType).length;
  // }

  // Future<int> getCountOfActionTypeForDay(
  //     String actionType, DateTime day) async {
  //   final usages = await getAppUsagesForDay(day);
  //   return usages.where((usage) => usage.actionType == actionType).length;
  // }

  // Future<Duration> getTotalTimeSpentInChatsForTimeRange(
  //     DateTime from, DateTime to) async {
  //   final usages = await getAppUsagesForTimeRange(from, to);
  //   final chatUsages = usages.where((usage) =>
  //       usage.actionType == 'ChatOpened' || usage.actionType == 'ChatClosed');

  //   Duration totalTime = Duration.zero;

  //   for (var i = 0; i < chatUsages.length - 1; i += 2) {
  //     final chatOpenTime = chatUsages[i].timestamp;
  //     final chatCloseTime = chatUsages[i + 1].timestamp;
  //     totalTime += chatCloseTime.difference(chatOpenTime);
  //   }

  //   return totalTime;
  // }

  // Future<int> getNumberOfTimesChatsOpenedForTimeRange(
  //     DateTime from, DateTime to) async {
  //   return await getCountOfActionTypeForTimeRange('ChatOpened', from, to);
  // }

  // // Calculate the total time spent in channels
  // Future<Duration> getTotalTimeSpentInChannelsForTimeRange(
  //     DateTime from, DateTime to) async {
  //   final usages = await getAppUsagesForTimeRange(from, to);
  //   final channelUsages = usages.where((usage) =>
  //       usage.actionType == 'ChannelOpened' ||
  //       usage.actionType == 'ChannelClosed');

  //   Duration totalTime = Duration.zero;

  //   for (var i = 0; i < channelUsages.length - 1; i += 2) {
  //     final channelOpenTime = channelUsages[i].timestamp;
  //     final channelCloseTime = channelUsages[i + 1].timestamp;
  //     totalTime += channelCloseTime.difference(channelOpenTime);
  //   }

  //   return totalTime;
  // }

  // // Calculate the total time spent in all chats
  // Future<Duration> getTotalTimeSpentInAllChatsForTimeRange(
  //     DateTime from, DateTime to) async {
  //   final usages = await getAppUsagesForTimeRange(from, to);
  //   final chatUsages = usages.where((usage) =>
  //       usage.actionType == 'ChatOpened' || usage.actionType == 'ChatClosed');

  //   Duration totalTime = Duration.zero;

  //   for (var i = 0; i < chatUsages.length - 1; i += 2) {
  //     final chatOpenTime = chatUsages[i].timestamp;
  //     final chatCloseTime = chatUsages[i + 1].timestamp;
  //     totalTime += chatCloseTime.difference(chatOpenTime);
  //   }

  //   return totalTime;
  // }

  // // Calculate the total time spent in all channels
  // Future<Duration> getTotalTimeSpentInAllChannelsForTimeRange(
  //     DateTime from, DateTime to) async {
  //   final usages = await getAppUsagesForTimeRange(from, to);
  //   final channelUsages = usages.where((usage) =>
  //       usage.actionType == 'ChannelOpened' ||
  //       usage.actionType == 'ChannelClosed');

  //   Duration totalTime = Duration.zero;

  //   for (var i = 0; i < channelUsages.length - 1; i += 2) {
  //     final channelOpenTime = channelUsages[i].timestamp;
  //     final channelCloseTime = channelUsages[i + 1].timestamp;
  //     totalTime += channelCloseTime.difference(channelOpenTime);
  //   }

  //   return totalTime;
  // }
}
