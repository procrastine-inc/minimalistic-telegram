class AppUsageStats {
  final int chatOpens;
  final int channelOpens;
  final int contactsOpens;
  final Duration totalTimeSpentInChats;
  final Duration totalTimeSpentInChannels;
  final List<TopUsageStats> topChats;
  final List<TopUsageStats> topChannels;

  AppUsageStats({
    required this.chatOpens,
    required this.channelOpens,
    required this.contactsOpens,
    required this.totalTimeSpentInChats,
    required this.totalTimeSpentInChannels,
    required this.topChats,
    required this.topChannels,
  });
}

class TopUsageStats {
  final String entityName;
  final Duration usageTime;
  final int usageCount;
  final int entityId;

  TopUsageStats({
    required this.entityName,
    required this.usageTime,
    required this.usageCount,
    required this.entityId,
  });
}

class DailyStats {
  final DateTime date;
  final int chatOpens;
  final int channelOpens;
  final int contactsOpens;
  final Duration totalTimeSpentInChats;
  final Duration totalTimeSpentInChannels;
  final List<PerEntityStats> perChatStats;
  final List<PerEntityStats> perChannelStats;

  DailyStats({
    required this.date,
    required this.chatOpens,
    required this.channelOpens,
    required this.contactsOpens,
    required this.totalTimeSpentInChats,
    required this.totalTimeSpentInChannels,
    required this.perChatStats,
    required this.perChannelStats,
  });
}

class PerEntityStats {
  final DateTime date;
  final String entityName;
  final Duration usageTime;
  final int usageCount;

  PerEntityStats({
    required this.date,
    required this.entityName,
    required this.usageTime,
    required this.usageCount,
  });
}

// Mock data for today's app usage statistics
final todayStats = AppUsageStats(
  chatOpens: 25,
  channelOpens: 15,
  contactsOpens: 10,
  totalTimeSpentInChats: const Duration(hours: 2, minutes: 30),
  totalTimeSpentInChannels: const Duration(hours: 1, minutes: 45),
  topChats: [
    TopUsageStats(
        entityName: "Chat 1",
        usageTime: const Duration(hours: 1),
        usageCount: 10,
        entityId: 1),
    TopUsageStats(
        entityName: "Chat 2",
        usageTime: const Duration(minutes: 45),
        usageCount: 8,
        entityId: 2),
    // Add more top chat usage stats...
  ],
  topChannels: [
    TopUsageStats(
        entityName: "Channel 1",
        usageTime: const Duration(hours: 1, minutes: 15),
        usageCount: 5,
        entityId: 1),
    TopUsageStats(
        entityName: "Channel 2",
        usageTime: const Duration(minutes: 30),
        usageCount: 3,
        entityId: 2),
    // Add more top channel usage stats...
  ],
);

// Mock data for daily app usage statistics for a particular day
final dailyStats = DailyStats(
  date: DateTime.now(), // Replace with the specific date
  chatOpens: 20,
  channelOpens: 10,
  contactsOpens: 8,
  totalTimeSpentInChats: const Duration(hours: 2),
  totalTimeSpentInChannels: const Duration(hours: 1, minutes: 15),
  perChatStats: [
    PerEntityStats(
        date: DateTime.now(),
        entityName: "Chat 1",
        usageTime: const Duration(hours: 1),
        usageCount: 8),
    PerEntityStats(
        date: DateTime.now(),
        entityName: "Chat 2",
        usageTime: const Duration(minutes: 45),
        usageCount: 7),
    // Add more per-chat usage stats...
  ],
  perChannelStats: [
    PerEntityStats(
        date: DateTime.now(),
        entityName: "Channel 1",
        usageTime: const Duration(hours: 1),
        usageCount: 5),
    PerEntityStats(
        date: DateTime.now(),
        entityName: "Channel 2",
        usageTime: const Duration(minutes: 30),
        usageCount: 3),
    // Add more per-channel usage stats...
  ],
);

// Mock data for a range of dates' app usage statistics
final dateRangeStats = [
  // DailyStats(/* ... */),
  // DailyStats(/* ... */),
  // Add more daily stats for the date range...
];
