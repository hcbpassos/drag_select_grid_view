import 'package:meta/meta.dart';

class AutoScroll {
  final bool isStopped;
  final StopAutoScrollEvent stopEvent;
  final AutoScrollDirection direction;
  final Duration duration;

  AutoScroll({@required this.direction, @required this.duration})
      : assert(direction != null),
        assert(duration != null),
        assert(duration != Duration.zero),
        isStopped = false,
        stopEvent = StopAutoScrollEvent.consumed();

  /// If no direction is specified, this constructor assumes you don't want the
  /// stop animation, therefore [stopEvent] is going to initialize consumed.
  AutoScroll.stopped({this.direction})
      : isStopped = true,
        duration = null,
        stopEvent = direction == null
            ? StopAutoScrollEvent.consumed()
            : StopAutoScrollEvent();

  @override
  String toString() => 'AutoScroll{'
      'isStopped: $isStopped, '
      'stopEvent: $stopEvent, '
      'direction: $direction, '
      'duration: $duration}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutoScroll &&
          runtimeType == other.runtimeType &&
          direction == other.direction &&
          duration == other.duration;

  @override
  int get hashCode => direction.hashCode ^ duration.hashCode;
}

enum AutoScrollDirection { up, down }

class StopAutoScrollEvent {
  bool get isConsumed => _isConsumed;
  bool _isConsumed;

  StopAutoScrollEvent() : _isConsumed = false;

  StopAutoScrollEvent.consumed() : _isConsumed = true;

  bool consume() {
    if (_isConsumed) {
      return false;
    } else {
      _isConsumed = true;
      return true;
    }
  }

  @override
  String toString() => 'StopAutoScrollEvent{_isConsumed: $_isConsumed}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StopAutoScrollEvent &&
          runtimeType == other.runtimeType &&
          _isConsumed == other._isConsumed;

  @override
  int get hashCode => _isConsumed.hashCode;
}
