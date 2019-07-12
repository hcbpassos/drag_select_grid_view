import 'package:drag_select_grid_view/src/auto_scroller/auto_scroll.dart';
import 'package:test/test.dart';
import 'package:flutter_test/flutter_test.dart' show throwsAssertionError;

void main() {
  group('AutoScroll', () {
    test('`direction` cannot be null.', () {
      expect(
        () {
          AutoScroll(
            direction: null,
            duration: Duration(seconds: 1),
          );
        },
        throwsAssertionError,
      );
    });

    test('`duration` cannot be null.', () {
      expect(
        () {
          AutoScroll(
            direction: AutoScrollDirection.down,
            duration: null,
          );
        },
        throwsAssertionError,
      );
    });

    test('`duration` cannot be zero.', () {
      expect(
        () {
          AutoScroll(
            direction: AutoScrollDirection.down,
            duration: Duration.zero,
          );
        },
        throwsAssertionError,
      );
    });

    test('`isScrolling` initializes as `true`.', () {
      expect(
        AutoScroll(
          direction: AutoScrollDirection.down,
          duration: Duration(seconds: 1),
        ).isScrolling,
        isTrue,
      );
    });

    test('`stopEvent` initializes consumed.', () {
      expect(
        AutoScroll(
          direction: AutoScrollDirection.down,
          duration: Duration(seconds: 1),
        ).stopEvent,
        StopAutoScrollEvent.consumed(),
      );
    });

    test('toString().', () {
      expect(
        AutoScroll(
          direction: AutoScrollDirection.down,
          duration: Duration(seconds: 1),
        ).toString(),
        isNot("Instance of 'AutoScroll'"),
      );
    });

    test('`operator ==` and `hashCode`.', () {
      AutoScroll autoScroll = AutoScroll(
        direction: AutoScrollDirection.down,
        duration: Duration(seconds: 1),
      );

      AutoScroll equalAutoScroll = AutoScroll(
        direction: AutoScrollDirection.down,
        duration: Duration(seconds: 1),
      );

      AutoScroll differentAutoScroll =
          AutoScroll.stopped(direction: AutoScrollDirection.down);

      expect(autoScroll, equalAutoScroll);
      expect(autoScroll.hashCode, equalAutoScroll.hashCode);

      expect(autoScroll, isNot(differentAutoScroll));
      expect(autoScroll.hashCode, isNot(differentAutoScroll.hashCode));
    });
  });

  group('StopAutoScrollEvent', () {
    test('`consume()` for consumed events never return true.', () {
      StopAutoScrollEvent stopEvent = StopAutoScrollEvent();
      expect(stopEvent.consume(), isTrue);
      expect(stopEvent.consume(), isFalse);

      stopEvent = StopAutoScrollEvent.consumed();
      expect(stopEvent.consume(), isFalse);
    });

    test('toString().', () {
      expect(
        StopAutoScrollEvent().toString(),
        isNot("Instance of 'StopAutoScrollEvent'"),
      );
    });

    test('`operator ==` and `hashCode`.', () {
      StopAutoScrollEvent stopEvent = StopAutoScrollEvent();
      StopAutoScrollEvent equalStopEvent = StopAutoScrollEvent();
      StopAutoScrollEvent differentStopEvent = StopAutoScrollEvent.consumed();

      expect(stopEvent, equalStopEvent);
      expect(stopEvent.hashCode, equalStopEvent.hashCode);

      expect(stopEvent, isNot(differentStopEvent));
      expect(stopEvent.hashCode, isNot(differentStopEvent.hashCode));
    });
  });
}
