import 'package:drag_select_grid_view/src/auto_scroll/auto_scroll.dart';
import 'package:drag_select_grid_view/src/auto_scroll/auto_scroller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ScrollController controller;

  Widget createWidget() {
    controller = ScrollController();

    return MaterialApp(
      home: ListView(
        controller: controller,
        children: List.generate(90, (_) => Container(height: 200)),
      ),
    );
  }

  group("Is able to perform auto-scroll.", () {
    testWidgets(
      "When an auto-scroller is attached to a `ScrollView`, "
      "and a scrolling-direction is specified, "
      "then the auto-scroller is able to scroll.",
      (tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        final autoScroller = AutoScroller(
          AutoScroll.stopped(direction: AutoScrollDirection.backward),
          controller,
        );

        expect(autoScroller.isAbleToScroll, isTrue);
      },
    );

    testWidgets(
      "When an auto-scroller isn't attached to a `ScrollView`, "
      "then the auto-scroller isn't able to scroll.",
      (tester) async {
        final autoScroller = AutoScroller(
          AutoScroll.stopped(direction: AutoScrollDirection.backward),
          ScrollController(),
        );

        expect(autoScroller.isAbleToScroll, isFalse);
      },
    );

    testWidgets(
      "When a scrolling-direction isn't specified to the auto-scroller, "
      "then the auto-scroller isn't able to scroll.",
      (tester) async {
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

  group("Has nothing left to scroll.", () {
    testWidgets(
      "Auto-scroller still has something to scroll "
      "when it is trying to scroll forward "
      "and it isn't at the end of the `ScrollView`.",
      (tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        controller.jumpTo(controller.position.maxScrollExtent - 1);

        final autoScroller = AutoScroller(
          AutoScroll.stopped(direction: AutoScrollDirection.forward),
          controller,
        );

        expect(autoScroller.hasAnythingLeftToScroll, isTrue);
      },
    );

    testWidgets(
      "Auto-scroller still has something to scroll "
      "when it is trying to scroll backward "
      "and it isn't at the beginning of the `ScrollView`.",
      (tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        controller.jumpTo(1);

        final autoScroller = AutoScroller(
          AutoScroll.stopped(direction: AutoScrollDirection.backward),
          controller,
        );

        expect(autoScroller.hasAnythingLeftToScroll, isTrue);
      },
    );

    testWidgets(
      "Auto-scroller nothing left to scroll "
      "when it is trying to scroll forward "
      "and it is at the end of the `ScrollView`.",
      (tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        controller.jumpTo(controller.position.maxScrollExtent);

        final autoScroller = AutoScroller(
          AutoScroll.stopped(direction: AutoScrollDirection.forward),
          controller,
        );

        expect(autoScroller.hasAnythingLeftToScroll, isFalse);
      },
    );

    testWidgets(
      "Auto-scroller nothing left to scroll "
      "when it is trying to scroll backward "
      "and it is at the beginning of the `ScrollView`.",
      (tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        controller.jumpTo(0);

        final autoScroller = AutoScroller(
          AutoScroll.stopped(direction: AutoScrollDirection.backward),
          controller,
        );

        expect(autoScroller.hasAnythingLeftToScroll, isFalse);
      },
    );
  });

  group("Must scroll.", () {
    testWidgets(
      "Auto-scroll must be performed "
      "when `AutoScroll.isScrolling` is `true`.",
      (tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        final autoScroller = AutoScroller(
          AutoScroll(
            direction: AutoScrollDirection.forward,
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
      (tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        final autoScroller = AutoScroller(
          AutoScroll.stopped(direction: AutoScrollDirection.forward),
          controller,
        );

        expect(autoScroller.mustScroll, isTrue);
      },
    );

    testWidgets(
      "Auto-scroll must NOT be performed "
      "when `AutoScroll.isScrolling` is `false` "
      "and stop-event is consumed.",
      (tester) async {
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

  group("Scroll.", () {
    testWidgets(
      "Auto-scroll is performed "
      "when `AutoScroll.isScrolling` is `true`.",
      (tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        final mockAutoScroller = MockAutoScroller(
          AutoScroll(
            direction: AutoScrollDirection.forward,
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
      "Given that auto-scroll's direction is forward, "
      "and the stop-event wasn't consumed, "
      ""
      "when auto-scroll is performed, "
      ""
      "a forward overscroll is performed.",
      (tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        final mockAutoScroller = MockAutoScroller(
          AutoScroll.stopped(direction: AutoScrollDirection.forward),
          controller,
        );

        expect(mockAutoScroller.performOverscrollOfScrollStopCount, 0);

        mockAutoScroller.scroll();

        expect(mockAutoScroller.performOverscrollOfScrollStopCount, 1);
        expect(mockAutoScroller.performScrollCount, 0);
        expect(
          mockAutoScroller.positionAfterOverscroll,
          greaterThan(mockAutoScroller.currentPosition ?? 0),
        );
      },
    );

    testWidgets(
      "Given that auto-scroll's direction is backward, "
      "and the stop-event wasn't consumed, "
      ""
      "when auto-scroll is performed, "
      ""
      "an backward overscroll is performed.",
      (tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        controller.jumpTo(controller.position.maxScrollExtent);

        final mockAutoScroller = MockAutoScroller(
          AutoScroll.stopped(direction: AutoScrollDirection.backward),
          controller,
        );

        expect(mockAutoScroller.performOverscrollOfScrollStopCount, 0);

        mockAutoScroller.scroll();

        expect(mockAutoScroller.performOverscrollOfScrollStopCount, 1);
        expect(mockAutoScroller.performScrollCount, 0);
        expect(
          mockAutoScroller.positionAfterOverscroll,
          lessThan(mockAutoScroller.currentPosition ?? 0),
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
