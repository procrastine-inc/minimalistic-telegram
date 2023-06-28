import 'dart:async';

abstract class EventEmitter<DataGenericType> {
  final Map<String, List<Function>> _observers = {};
  final StreamController<Map<String, dynamic>> _controller =
      StreamController.broadcast();

  void on<T>(String events, Function(T) listener) {
    events.split(' ').forEach((event) {
      _observers[event] = _observers[event] ?? [];
      _observers[event]!.add(listener);
    });
  }

  void off(String event, Function? listener) {
    if (_observers[event] == null) return;
    if (listener == null) {
      _observers.remove(event);
      return;
    }
    _observers[event]!.remove(listener);
  }

  void emit(String event, DataGenericType data) {
    final eventMap = {'event': event, 'data': data};
    _controller.add(eventMap);

    if (_observers[event] != null) {
      final cloned = List.from(_observers[event]!);
      for (var observer in cloned) {
        observer(data);
      }
    }

    if (_observers['*'] != null) {
      final cloned = List.from(_observers['*']!);
      for (var observer in cloned) {
        observer(eventMap);
      }
    }
  }

  Stream<Map<String, dynamic>> get stream => _controller.stream;
}
