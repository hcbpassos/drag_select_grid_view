import 'package:meta/meta.dart';

/// Helper class that holds information created and used by [AutoScroller].
@immutable
class AutoScroll {
  /// Whether it is auto-scrolling or not.
  final bool isScrolling;

  /// Event to stop auto-scroll.
  final StopAutoScrollEvent stopEvent;

  /// The direction of the auto-scroll.
  final AutoScrollDirection direction;

  /// The duration of the auto-scroll.
  ///
  /// The longer the duration, the slower the scrolling.
  /// The shorter the duration, the faster the scrolling.
  final Duration duration;

  AutoScroll({@required this.direction, @required this.duration})
      : assert(direction != null),
        assert(duration != null),
        assert(duration != Duration.zero),
        isScrolling = true,
        stopEvent = StopAutoScrollEvent.consumed();

  /// Creates a stopped [AutoScroll].
  ///
  /// The parameter [direction] should be used to indicate the direction of the
  /// [AutoScroll] before it stopped. [AutoScroller] takes this information to
  /// decide whether it should make a stop-scrolling-animation and in which
  /// direction it should be done.
  ///
  /// If [direction] is not specified, [stopEvent] is going to initialize
  /// consumed, assuming that you don't want [AutoScroller] to make a
  /// stop-scrolling-animation.
  AutoScroll.stopped({this.direction})
      : isScrolling = false,
        duration = null,
        stopEvent = direction == null
            ? StopAutoScrollEvent.consumed()
            : StopAutoScrollEvent();

  @override
  String toString() => 'AutoScroll{'
      'isStopped: $isScrolling, '
      'stopEvent: $stopEvent, '
      'direction: $direction, '
      'duration: $duration'
      '}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutoScroll &&
          runtimeType == other.runtimeType &&
          isScrolling == other.isScrolling &&
          stopEvent == other.stopEvent &&
          direction == other.direction &&
          duration == other.duration;

  @override
  int get hashCode =>
      isScrolling.hashCode ^
      stopEvent.hashCode ^
      direction.hashCode ^
      duration.hashCode;
}

/// Possible directions of auto-scroll.
enum AutoScrollDirection { up, down }

/// Event to stop auto-scroll.
///
/// This works as an extension of [AutoScroll.isScrolling], helping
/// [AutoScroller] to decide whether it IS stopped or it SHOULD stop.
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
