import 'package:tdlib/td_api.dart';

class OrderedChat implements Comparable<OrderedChat> {
  final int chatId;
  final ChatPosition position;

  OrderedChat({required this.chatId, required this.position});

  @override
  int compareTo(OrderedChat other) {
    if (position.order != other.position.order) {
      return other.position.order < position.order ? -1 : 1;
    }
    if (chatId != other.chatId) {
      return other.chatId < chatId ? -1 : 1;
    }
    return 0;
  }

  @override
  bool operator ==(Object other) {
    if (other is OrderedChat) {
      return chatId == other.chatId && position.order == other.position.order;
    }
    return false;
  }

  @override
  int get hashCode => chatId.hashCode ^ position.order.hashCode;
}
