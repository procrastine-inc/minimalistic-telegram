import 'package:isar/isar.dart';

part 'app_usage.g.dart';

@collection
class AppUsage {
  Id id = Isar.autoIncrement;

  late DateTime timestamp;
  late String actionType;

  // Linking to specific entities like Chat, Channel, Post, Profile, etc.
  var actionEntitity = IsarLink<ActionEntity>();
}

@collection
class ActionEntity {
  Id id = Isar.autoIncrement;

  late String
      entityType; // For example: 'Chat', 'Channel', 'Post', 'Profile', etc.
  late int
      entityId; // ID to specify the specific entity (chat ID, channel ID, etc.)
}
