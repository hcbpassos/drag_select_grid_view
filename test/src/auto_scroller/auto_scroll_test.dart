import 'package:drag_select_grid_view/src/auto_scroll/auto_scroll.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("AutoScroll", () {
    test(
      "When an `AutoScroll` is created with null `direction`, "
      "then an `AssertionError` is thrown.",
      () {
        expect(
          () => AutoScroll(
            duration: const Duration(seconds: 1),
            direction: null,
          ),
          throwsAssertionError,
        );
      },
    );

    test(
      "When an `AutoScroll` is created with null `duration`, "
      "then an `AssertionError` is thrown.",
      () {
        expect(
          () => AutoScroll(
            direction: AutoScrollDirection.forward,
            duration: null,
          ),
          throwsAssertionError,
        );
      },
    );

    test(
      "When an `AutoScroll` is created with `duration` zero, "
      "then an `AssertionError` is thrown.",
      () {
        expect(
          () => AutoScroll(
            direction: AutoScrollDirection.forward,
            duration: Duration.zero,
          ),
          throwsAssertionError,
        );
      },
    );

    test("`isScrolling` initializes as `true`.", () {
      expect(
        AutoScroll(
          direction: AutoScrollDirection.forward,
          duration: const Duration(seconds: 1),
        ).isScrolling,
        isTrue,
      );
    });

    test("`stopEvent` initializes consumed.", () {
      expect(
        AutoScroll(
          direction: AutoScrollDirection.forward,
          duration: const Duration(seconds: 1),
        ).stopEvent,
        StopAutoScrollEvent.consumed(),
      );
    });

    test("`toString()`.", () {
      expect(
        AutoScroll(
          direction: AutoScrollDirection.forward,
          duration: const Duration(seconds: 1),
        ).toString(),
        isNot("Instance of 'AutoScroll'"),
      );
    });

    group("`operator ==` and `hashCode`.", () {
      final autoScroll =
          AutoScroll.stopped(direction: AutoScrollDirection.forward);

      final equalAutoScroll =
          AutoScroll.stopped(direction: AutoScrollDirection.forward);

      final anotherEqualAutoScroll =
          AutoScroll.stopped(direction: AutoScrollDirection.forward);

      final differentAutoScroll = AutoScroll(
        direction: AutoScrollDirection.forward,
        duration: const Duration(seconds: 1),
      );

      test('Reflexivity.', () {
        expect(autoScroll, autoScroll);
        expect(autoScroll.hashCode, autoScroll.hashCode);
      });

      test('Symmetry.', () {
        expect(autoScroll, isNot(differentAutoScroll));
        expect(differentAutoScroll, isNot(autoScroll));
      });

      test('Transitivity.', () {
        expect(autoScroll, equalAutoScroll);
        expect(equalAutoScroll, anotherEqualAutoScroll);
        expect(autoScroll, anotherEqualAutoScroll);
        expect(autoScroll.hashCode, equalAutoScroll.hashCode);
        expect(equalAutoScroll.hashCode, anotherEqualAutoScroll.hashCode);
        expect(autoScroll.hashCode, anotherEqualAutoScroll.hashCode);
      });
    });
  });

  group("StopAutoScrollEvent", () {
    test(
      "Given that a `StopAutoScrollEvent` was consumed, "
      "when `consume()` is called, "
      "then it returns false, since the event is already consumed.",
      () {
        var stopEvent = StopAutoScrollEvent();
        expect(stopEvent.consume(), isTrue);
        expect(stopEvent.consume(), isFalse);

        stopEvent = StopAutoScrollEvent.consumed();
        expect(stopEvent.consume(), isFalse);
      },
    );

    test("`isConsumed`.", () {
      final stopEvent = StopAutoScrollEvent();
      expect(stopEvent.isConsumed, isFalse);
      stopEvent.consume();
      expect(stopEvent.isConsumed, isTrue);
    });

    test("`isNotConsumed`.", () {
      final stopEvent = StopAutoScrollEvent();
      expect(stopEvent.isNotConsumed, isTrue);
      stopEvent.consume();
      expect(stopEvent.isNotConsumed, isFalse);
    });

    test("`toString()`.", () {
      expect(
        StopAutoScrollEvent().toString(),
        isNot("Instance of 'StopAutoScrollEvent'"),
      );
    });

    group("`operator ==` and `hashCode`.", () {
      final stopEvent = StopAutoScrollEvent();
      final equalStopEvent = StopAutoScrollEvent();
      final anotherEqualStopEvent = StopAutoScrollEvent();
      final differentStopEvent = StopAutoScrollEvent.consumed();

      test('Reflexivity.', () {
        expect(stopEvent, stopEvent);
        expect(stopEvent.hashCode, stopEvent.hashCode);
      });

      test('Symmetry.', () {
        expect(stopEvent, isNot(differentStopEvent));
        expect(differentStopEvent, isNot(stopEvent));
      });

      test('Transitivity.', () {
        expect(stopEvent, equalStopEvent);
        expect(equalStopEvent, anotherEqualStopEvent);
        expect(stopEvent, anotherEqualStopEvent);
        expect(stopEvent.hashCode, equalStopEvent.hashCode);
        expect(equalStopEvent.hashCode, anotherEqualStopEvent.hashCode);
        expect(stopEvent.hashCode, anotherEqualStopEvent.hashCode);
      });
    });
  });
}
