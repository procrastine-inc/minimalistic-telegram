import 'package:flutter/material.dart';
import 'package:minimalistic_telegram/components/ChatAvatar/index.dart';
import 'package:minimalistic_telegram/components/ChatBlock/chat_top_row.dart';
import 'package:minimalistic_telegram/mock/usage_stats.dart';
import 'package:flutter/cupertino.dart';
import 'package:minimalistic_telegram/services/isar_service.dart';
import 'package:minimalistic_telegram/stores/chat_store.dart';
import 'package:palestine_console/palestine_console.dart';
import 'package:provider/provider.dart';

class AppUsageStatsPage extends StatefulWidget {
  const AppUsageStatsPage({super.key});

  @override
  _AppUsageStatsPageState createState() => _AppUsageStatsPageState();
}

class _AppUsageStatsPageState extends State<AppUsageStatsPage> {
  AppUsageStats? statsToDisplay;
  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now(),
  );
  int _selectedOptionIndex = 0; // Initialize this variable as per your needs

  int _getSelectedOptionIndex() {
    return _selectedOptionIndex;
  }

  @override
  void initState() {
    super.initState();
    initStats();
  }

  initStats() async {
    var dbservice = IsarService();
    var chatOpens = await dbservice.getChatOpenEventsNumberToday();
    var chatTotalTime = await dbservice.getChatTotalTimeOpenedToday();
    var channelOpens = await dbservice.getChannelOpenEventsNumberToday();
    var channelTotalTime = await dbservice.getChannelTotalTimeOpenedToday();
    var topChats = await dbservice.getTopChatsToday();

    var topChatsToRender = topChats.entries.map((entry) {
      var chatId = entry.key, chatOpenCount = entry.value;
      var topChat = TopUsageStats(
        entityName: chatId.toString(),
        entityId: chatId,
        usageTime: const Duration(),
        usageCount: chatOpenCount,
      );
      return topChat;
    }).toList();

    var todayStats = AppUsageStats(
        chatOpens: chatOpens,
        channelOpens: channelOpens,
        contactsOpens: 0,
        totalTimeSpentInChats: chatTotalTime,
        totalTimeSpentInChannels: channelTotalTime,
        topChats: topChatsToRender,
        topChannels: []);
    setState(() {
      statsToDisplay = todayStats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Usage Statistics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _buildDateSelectionWidget(),
            _buildTimeRangeSelectionWidget(),
            const SizedBox(height: 16),

            statsToDisplay == null
                ? const CircularProgressIndicator(
                    semanticsLabel: 'Linear progress indicator',
                  )
                : _buildStats(statsToDisplay!),

            // Add widgets for date range stats and selecting preset range...
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelectionWidget() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime startOfWeek = today.subtract(Duration(days: now.weekday - 1));
    DateTime startOfMonth = DateTime(now.year, now.month, 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Time Range:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: CupertinoSegmentedControl<int>(
            children: const {
              0: Text('Today'),
              1: Text('This Week'),
              2: Text('This Month'),
              3: Text('Custom'),
            },
            onValueChanged: (int? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedOptionIndex = newValue;
                  switch (newValue) {
                    case 0:
                      _selectedDateRange =
                          DateTimeRange(start: today, end: now);
                      break;
                    case 1:
                      _selectedDateRange =
                          DateTimeRange(start: startOfWeek, end: now);
                      break;
                    case 2:
                      _selectedDateRange =
                          DateTimeRange(start: startOfMonth, end: now);
                      break;
                    case 3:
                      showDateRangePicker(
                        context: context,
                        firstDate:
                            DateTime(2022), // Set your preferred first date
                        lastDate: DateTime.now(),
                      ).then((pickedDateRange) {
                        if (pickedDateRange != null &&
                            pickedDateRange.start != null &&
                            pickedDateRange.end != null) {
                          setState(() {
                            _selectedDateRange = pickedDateRange;
                          });
                        }
                      });
                      break;
                    default:
                      break;
                  }
                });
              }
            },
            groupValue: _getSelectedOptionIndex(),
          ),
        ),
        const SizedBox(height: 8),
        if (_selectedDateRange != null)
          Text(
            'Selected Date Range: ${_getSelectedDateRangeText()}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue, // Change color according to your theme
              fontStyle: FontStyle.italic, // Add italic style
            ),
          ),
      ],
    );
  }

  String _getSelectedDateRangeText() {
    if (_selectedDateRange == null) {
      return 'No date range selected';
    } else {
      if (_selectedOptionIndex == 0) {
        return 'Today';
      } else if (_selectedOptionIndex == 1) {
        return 'This Week';
      } else if (_selectedOptionIndex == 2) {
        return 'This Month';
      } else {
        return '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month}/${_selectedDateRange!.start.year} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}/${_selectedDateRange!.end.year}';
      }
    }
  }

  void _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
        // Update stats based on the selected date range
        // Fetch or update stats for the selected date range...
      });
    }
  }

  Widget _buildStats(AppUsageStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatItem('Chat Opens', stats.chatOpens.toString()),
        _buildStatItem('Channel Opens', stats.channelOpens.toString()),
        _buildStatItem('Contacts Opens', stats.contactsOpens.toString()),
        _buildStatItem('Total Time in Chats', stats.totalTimeSpentInChats),
        _buildStatItem(
            'Total Time in Channels', stats.totalTimeSpentInChannels),
        _buildTopUsageList('Top 5 Chats', stats.topChats),
        _buildTopUsageList('Top 5 Channels', stats.topChannels),
      ],
    );
  }

  Widget _buildStatItem(String title, dynamic value) {
    String formattedValue = '';

    if (value is Duration) {
      int hours = value.inHours;
      int minutes = value.inMinutes.remainder(60);
      formattedValue =
          '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    } else {
      formattedValue = value.toString();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            formattedValue,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTopUsageList(String title, List<TopUsageStats> statsList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Column(
          children: statsList.map((stats) {
            return TopChannelTile(
                id: stats.entityId,
                usageTime: stats.usageTime,
                usageCount: stats.usageCount);
          }).toList(),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            // Handle "Show more" button tap to open a subpage with list of all usage stats per chat or channel
            // You can navigate to the subpage here...
          },
          child: const Text(
            'Show more',
            style: TextStyle(color: Colors.blue),
          ),
        ),
        const Divider(),
      ],
    );
  }
}

class TopChannelTile extends StatelessWidget {
  final int id;
  final Duration usageTime;
  final int usageCount;
  const TopChannelTile({
    super.key,
    required this.id,
    required this.usageTime,
    required this.usageCount,
  });

  @override
  Widget build(BuildContext context) {
    var chatStore = context.read<ChatStore>();

    var chat = chatStore.items[id];
    if (chat == null) {
      return const SizedBox.shrink();
    }
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      leading: ChatAvatar(photo: chat.photo),
      title: ChatTitle(title: chat.title),
      subtitle: Text(
          'Usage Time: ${usageTime.toString()} | Usage Count: ${usageCount}'),
      // Add onTap functionality to navigate to the subpage with detailed stats...
    );
  }
}
