import 'package:drag_select_grid_view/auto_scroller/auto_scroll.dart';
import 'package:flutter_test/flutter_test.dart';

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

    test('`scrollDuration` cannot be null.', () {
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

    test('`scrollDuration` cannot be zero.', () {
      expect(
        () {
          AutoScroll(
            direction: AutoScrollDirection.down,
            duration: Duration.zero,
          );
        },
        throwsAssertionError,
      );

      expect(
        () {
          AutoScroll(
            direction: AutoScrollDirection.down,
            duration: Duration(minutes: 0),
          );
        },
        throwsAssertionError,
      );
    });

    test('`isStopped` getter returns correct value.', () {
      expect(
        AutoScroll(
          direction: AutoScrollDirection.down,
          duration: Duration(seconds: 1),
        ).isStopped,
        isFalse,
      );
    });

    test('`stopEvent` getter returns correct value.', () {
      expect(
        AutoScroll(
          direction: AutoScrollDirection.down,
          duration: Duration(seconds: 1),
        ).stopEvent,
        StopAutoScrollEvent.consumed(),
      );
    });

    test('`direction` getter returns correct value.', () {
      expect(
        AutoScroll(
          direction: AutoScrollDirection.down,
          duration: Duration(seconds: 1),
        ).direction,
        AutoScrollDirection.down,
      );
    });

    test('`scrollDuration` getter returns correct value.', () {
      expect(
        AutoScroll(
          direction: AutoScrollDirection.down,
          duration: Duration(seconds: 1),
        ).duration,
        Duration(seconds: 1),
      );
    });

    test('toString().', () {
      expect(
        AutoScroll(
          direction: AutoScrollDirection.down,
          duration: Duration(seconds: 1),
        ).toString(),
        'AutoScroll{isStopped: false, '
            'stopEvent: StopAutoScrollEvent{_isConsumed: true}, '
            'direction: AutoScrollDirection.down, '
            'duration: 0:00:01.000000}',
      );
    });

    test('equals and hashCode.', () {
      AutoScroll autoScrollA = AutoScroll(
        direction: AutoScrollDirection.down,
        duration: Duration(seconds: 1),
      );

      AutoScroll autoScrollB = AutoScroll(
        direction: AutoScrollDirection.down,
        duration: Duration(seconds: 1),
      );

      expect(autoScrollA, autoScrollB);
      expect(autoScrollA.hashCode, autoScrollB.hashCode);

      AutoScroll autoScrollC =
          AutoScroll.stopped(direction: AutoScrollDirection.down);

      expect(autoScrollA, isNot(autoScrollC));
      expect(autoScrollA.hashCode, isNot(autoScrollC.hashCode));
    });
  });

  group('StopAutoScrollEvent', () {
    test('`consume()` for consumed stop events never return true.', () {
      StopAutoScrollEvent stopEvent = StopAutoScrollEvent();
      expect(stopEvent.consume(), isTrue);
      expect(stopEvent.consume(), isFalse);

      expect(StopAutoScrollEvent.consumed().consume(), isFalse);
    });

    test('toString().', () {
      // Already tested inside the group AutoScroll.
    });

    test('equals and hashCode.', () {
      StopAutoScrollEvent stopEventA = StopAutoScrollEvent();
      StopAutoScrollEvent stopEventB = StopAutoScrollEvent();

      expect(stopEventA, stopEventB);
      expect(stopEventA.hashCode, stopEventB.hashCode);

      StopAutoScrollEvent stopEventC = StopAutoScrollEvent.consumed();

      expect(stopEventA, isNot(stopEventC));
      expect(stopEventA.hashCode, isNot(stopEventC.hashCode));
    });
  });
}
