import 'package:drag_select_grid_view/src/auto_scroller/auto_scroll.dart';
import 'package:drag_select_grid_view/src/auto_scroller/auto_scroller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ScrollController controller;

  Widget createWidget() {
    controller = ScrollController();

    return MaterialApp(
      home: ListView(
        controller: controller,
        children: List.generate(90, (_) => Container(height: 200)),
      ),
    );
  }

  group('Is able to perform auto-scroll.', () {
    testWidgets(
      'Auto-scroller is able to scroll '
      'when it is attached to a `ScrollView` '
      'and a scrolling-direction is specified.',
      (WidgetTester tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        final autoScroller = AutoScroller(
          AutoScroll.stopped(direction: AutoScrollDirection.up),
          controller,
        );

        expect(autoScroller.isAbleToScroll, isTrue);
      },
    );

    testWidgets(
      "Auto-scroller won't be able to scroll "
      "when it isn't attached to any `ScrollView`.",
      (WidgetTester tester) async {
        final autoScroller = AutoScroller(
          AutoScroll.stopped(direction: AutoScrollDirection.up),
          ScrollController(),
        );

        expect(autoScroller.isAbleToScroll, isFalse);
      },
    );

    testWidgets(
      "Auto-scroller won't be able to scroll "
      "when NO scrolling-direction was specified.",
      (WidgetTester tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        final autoScroller = AutoScroller(
          AutoScroll.stopped(),
          controller,
        );

        expect(autoScroller.isAbleToScroll, isFalse);
      },
    );
  });

  group('Has nothing left to scroll.', () {
    testWidgets(
      "Auto-scroller still has something to scroll "
      "when it is trying to scroll down "
      "and it isn't at the end of the `ScrollView`.",
      (WidgetTester tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        controller.jumpTo(controller.position.maxScrollExtent - 1);

        final autoScroller = AutoScroller(
          AutoScroll.stopped(direction: AutoScrollDirection.down),
          controller,
        );

        expect(autoScroller.hasAnythingLeftToScroll, isTrue);
      },
    );

    testWidgets(
      "Auto-scroller still has something to scroll "
      "when it is trying to scroll up "
      "and it isn't at the beginning of the `ScrollView`.",
      (WidgetTester tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        controller.jumpTo(1);

        final autoScroller = AutoScroller(
          AutoScroll.stopped(direction: AutoScrollDirection.up),
          controller,
        );

        expect(autoScroller.hasAnythingLeftToScroll, isTrue);
      },
    );

    testWidgets(
      'Auto-scroller nothing left to scroll '
      'when it is trying to scroll down '
      'and it is at the end of the `ScrollView`.',
      (WidgetTester tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        controller.jumpTo(controller.position.maxScrollExtent);

        final autoScroller = AutoScroller(
          AutoScroll.stopped(direction: AutoScrollDirection.down),
          controller,
        );

        expect(autoScroller.hasAnythingLeftToScroll, isFalse);
      },
    );

    testWidgets(
      'Auto-scroller nothing left to scroll '
      'when it is trying to scroll up '
      'and it is at the beginning of the `ScrollView`.',
      (WidgetTester tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        controller.jumpTo(0);

        final autoScroller = AutoScroller(
          AutoScroll.stopped(direction: AutoScrollDirection.up),
          controller,
        );

        expect(autoScroller.hasAnythingLeftToScroll, isFalse);
      },
    );
  });

  group('Must scroll.', () {
    testWidgets(
      "Auto-scroll must be performed "
      "when `AutoScroll.isScrolling` is `true`.",
      (WidgetTester tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        final autoScroller = AutoScroller(
          AutoScroll(
            direction: AutoScrollDirection.down,
            duration: const Duration(seconds: 1),
          ),
          controller,
        );

        expect(autoScroller.mustScroll, isTrue);
      },
    );

    testWidgets(
      "Auto-scroll must be performed "
      "when stop-event isn't consumed.",
      (WidgetTester tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        final autoScroller = AutoScroller(
          AutoScroll.stopped(direction: AutoScrollDirection.down),
          controller,
        );

        expect(autoScroller.mustScroll, isTrue);
      },
    );

    testWidgets(
      "Auto-scroll must NOT be performed "
      "when `AutoScroll.isScrolling` is `false` "
      "and stop-event is consumed.",
      (WidgetTester tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        final autoScroller = AutoScroller(
          AutoScroll.stopped(),
          controller,
        );

        expect(autoScroller.mustScroll, isFalse);
      },
    );
  });

  group('Scroll.', () {
    testWidgets(
      "Auto-scroll is performed "
      "when `AutoScroll.isScrolling` is `true`.",
      (WidgetTester tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        final mockAutoScroller = MockAutoScroller(
          AutoScroll(
            direction: AutoScrollDirection.down,
            duration: const Duration(seconds: 1),
          ),
          controller,
        );

        expect(mockAutoScroller.performScrollCount, 0);

        mockAutoScroller.scroll();

        expect(mockAutoScroller.performScrollCount, 1);
        expect(mockAutoScroller.performOverscrollOfScrollStopCount, 0);
      },
    );

    testWidgets(
      "Given that auto-scroll's direction is down, "
      "and the stop-event wasn't consumed, "
      ''
      'when auto-scroll is performed, '
      ''
      'a downward overscroll is performed.',
      (WidgetTester tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        final mockAutoScroller = MockAutoScroller(
          AutoScroll.stopped(direction: AutoScrollDirection.down),
          controller,
        );

        expect(mockAutoScroller.performOverscrollOfScrollStopCount, 0);

        mockAutoScroller.scroll();

        expect(mockAutoScroller.performOverscrollOfScrollStopCount, 1);
        expect(mockAutoScroller.performScrollCount, 0);
        expect(
          mockAutoScroller.positionAfterOverscroll,
          greaterThan(mockAutoScroller.currentPosition),
        );
      },
    );

    testWidgets(
      "Given that auto-scroll's direction is up, "
      "and the stop-event wasn't consumed, "
      ''
      'when auto-scroll is performed, '
      ''
      'an upward overscroll is performed.',
      (WidgetTester tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        controller.jumpTo(controller.position.maxScrollExtent);

        final mockAutoScroller = MockAutoScroller(
          AutoScroll.stopped(direction: AutoScrollDirection.up),
          controller,
        );

        expect(mockAutoScroller.performOverscrollOfScrollStopCount, 0);

        mockAutoScroller.scroll();

        expect(mockAutoScroller.performOverscrollOfScrollStopCount, 1);
        expect(mockAutoScroller.performScrollCount, 0);
        expect(
          mockAutoScroller.positionAfterOverscroll,
          lessThan(mockAutoScroller.currentPosition),
        );
      },
    );
  });
}

// ignore: must_be_immutable
class MockAutoScroller extends AutoScroller {
  int performOverscrollOfScrollStopCount = 0;
  int performScrollCount = 0;

  MockAutoScroller(AutoScroll autoScroll, ScrollController controller)
      : super(autoScroll, controller);

  @override
  Future<void> performOverscrollOfScrollStop() {
    performOverscrollOfScrollStopCount++;
    return super.performOverscrollOfScrollStop();
  }

  @override
  Future<void> performScroll() {
    performScrollCount++;
    return super.performScroll();
  }
}