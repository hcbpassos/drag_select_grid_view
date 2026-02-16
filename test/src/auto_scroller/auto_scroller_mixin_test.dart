import 'package:drag_select_grid_view/src/auto_scroll/auto_scroll.dart';
import 'package:drag_select_grid_view/src/drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_utils.dart';

void main() {
  const distanceFromTop = 80.0;
  const distanceFromRight = 40.0;
  const distanceFromBottom = 60.0;
  const distanceFromLeft = 20.0;
  const widgetHeight = screenHeight - (distanceFromTop + distanceFromBottom);
  const widgetWidth = screenWidth - (distanceFromRight + distanceFromLeft);

  final dragSelectGridViewFinder = find.byType(DragSelectGridView);

  Widget createWidget() {
    return MaterialApp(
      home: Column(children: [
        Container(height: distanceFromTop),
        Expanded(
          child: Row(children: [
            Container(width: distanceFromLeft),
            Expanded(
              child: DragSelectGridView(
                itemCount: 0,
                itemBuilder: (_, __, ___) => const SizedBox(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 1,
                ),
              ),
            ),
            Container(width: distanceFromRight),
          ]),
        ),
        Container(height: distanceFromBottom),
      ]),
    );
  }

  group('Horizontal hotspot presence tests', () {
    Widget createHorizontalWidget() {
      return MaterialApp(
        home: Column(children: [
          Container(height: distanceFromTop),
          Expanded(
            child: Row(children: [
              Container(width: distanceFromLeft),
              Expanded(
                child: DragSelectGridView(
                  scrollDirection: Axis.horizontal,
                  itemCount: 0,
                  itemBuilder: (_, __, ___) => const SizedBox(),
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 1,
                  ),
                ),
              ),
              Container(width: distanceFromRight),
            ]),
          ),
          Container(height: distanceFromBottom),
        ]),
      );
    }

    testWidgets(
      "Given a horizontal scroll direction, "
      "when the pointer gets inside the LEFT hotspot, "
      "then `AutoScroller` detects the pointer in the START hotspot.",
      (tester) async {
        final widget = createHorizontalWidget();
        await tester.pumpWidget(widget);

        expect(dragSelectGridViewFinder, findsOneWidget);
        final state =
            tester.state(dragSelectGridViewFinder) as DragSelectGridViewState;

        const offset = Offset(0, widgetHeight / 2);

        expect(state.isInsideStartAutoScrollHotspot(offset), isTrue);
        expect(state.isInsideEndAutoScrollHotspot(offset), isFalse);
      },
    );

    testWidgets(
      "Given a horizontal scroll direction, "
      "when the pointer gets inside the RIGHT hotspot, "
      "then `AutoScroller` detects the pointer in the END hotspot.",
      (tester) async {
        final widget = createHorizontalWidget();
        await tester.pumpWidget(widget);

        final state =
            tester.state(dragSelectGridViewFinder) as DragSelectGridViewState;
        const offset = Offset(widgetWidth, widgetHeight / 2);

        expect(state.isInsideStartAutoScrollHotspot(offset), isFalse);
        expect(state.isInsideEndAutoScrollHotspot(offset), isTrue);
      },
    );

    testWidgets(
      "Given a horizontal scroll direction, "
      "when the pointer is in the vertical middle of the widget, "
      "then `AutoScroller` detects the pointer in none of the hotspots.",
      (tester) async {
        final widget = createHorizontalWidget();
        await tester.pumpWidget(widget);

        final state =
            tester.state(dragSelectGridViewFinder) as DragSelectGridViewState;
        const offset = Offset(widgetWidth / 2, widgetHeight / 2);

        expect(state.isInsideStartAutoScrollHotspot(offset), isFalse);
        expect(state.isInsideEndAutoScrollHotspot(offset), isFalse);
      },
    );

    testWidgets(
      "Given a horizontal scroll direction, "
      "when the pointer gets to the left of the widget, "
      "then `AutoScroller` detects the pointer in none of the hotspots.",
      (tester) async {
        final widget = createHorizontalWidget();
        await tester.pumpWidget(widget);

        final state =
            tester.state(dragSelectGridViewFinder) as DragSelectGridViewState;
        const offset = Offset(-1, widgetHeight / 2);

        expect(state.isInsideStartAutoScrollHotspot(offset), isFalse);
        expect(state.isInsideEndAutoScrollHotspot(offset), isFalse);
      },
    );

    testWidgets(
      "Given a horizontal scroll direction, "
      "when the pointer gets past the right edge of the widget, "
      "then `AutoScroller` detects the pointer in none of the hotspots.",
      (tester) async {
        final widget = createHorizontalWidget();
        await tester.pumpWidget(widget);

        final state =
            tester.state(dragSelectGridViewFinder) as DragSelectGridViewState;
        const offset = Offset(widgetWidth + 1, widgetHeight / 2);

        expect(state.isInsideStartAutoScrollHotspot(offset), isFalse);
        expect(state.isInsideEndAutoScrollHotspot(offset), isFalse);
      },
    );
  });

  group('Hotspot presence tests', () {
    testWidgets(
      "When the pointer gets inside the UPPER hotspot, "
      "then `AutoScroller` detects the pointer in the UPPER hotspot.",
      (tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        expect(dragSelectGridViewFinder, findsOneWidget);
        final state =
            tester.state(dragSelectGridViewFinder) as DragSelectGridViewState;

        const offset = Offset(0, 0);

        expect(state.isInsideStartAutoScrollHotspot(offset), isTrue);
        expect(state.isInsideEndAutoScrollHotspot(offset), isFalse);
      },
    );

    testWidgets(
      "When the pointer gets inside the LOWER hotspot, "
      "then `AutoScroller` detects the pointer in the LOWER hotspot.",
      (tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        final state =
            tester.state(dragSelectGridViewFinder) as DragSelectGridViewState;
        const offset = Offset(0, widgetHeight);

        expect(state.isInsideStartAutoScrollHotspot(offset), isFalse);
        expect(state.isInsideEndAutoScrollHotspot(offset), isTrue);
      },
    );

    testWidgets(
      "When the pointer gets ABOVE both hotspots, "
      "then `AutoScroller` detects the pointer in none of the hotspots.",
      (tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        final state =
            tester.state(dragSelectGridViewFinder) as DragSelectGridViewState;
        const offset = Offset(0, -1);

        expect(state.isInsideStartAutoScrollHotspot(offset), isFalse);
        expect(state.isInsideEndAutoScrollHotspot(offset), isFalse);
      },
    );

    testWidgets(
      "When the pointer gets BELOW both hotspots, "
      "then `AutoScroller` detects the pointer in none of the hotspots.",
      (tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        final state =
            tester.state(dragSelectGridViewFinder) as DragSelectGridViewState;
        const offset = Offset(0, widgetHeight + 1);

        expect(state.isInsideStartAutoScrollHotspot(offset), isFalse);
        expect(state.isInsideEndAutoScrollHotspot(offset), isFalse);
      },
    );

    testWidgets(
      "When the pointer gets to the left side of both hotspots, "
      "then `AutoScroller` detects the pointer in none of the hotspots.",
      (tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        final state =
            tester.state(dragSelectGridViewFinder) as DragSelectGridViewState;
        const offset = Offset(-1, 0);

        expect(state.isInsideStartAutoScrollHotspot(offset), isFalse);
        expect(state.isInsideEndAutoScrollHotspot(offset), isFalse);
      },
    );

    testWidgets(
      "When the pointer gets to the right side of both hotspots, "
      "then `AutoScroller` detects the pointer in none of the hotspots.",
      (tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        final state =
            tester.state(dragSelectGridViewFinder) as DragSelectGridViewState;
        const offset = Offset(widgetWidth + 1, 0);

        expect(state.isInsideStartAutoScrollHotspot(offset), isFalse);
        expect(state.isInsideEndAutoScrollHotspot(offset), isFalse);
      },
    );
  });

  group('Auto-scroll tests', () {
    testWidgets(
      "Auto-scroll direction is updated "
      "when `DragSelectGridView` starts to scroll backward, "
      "but auto-scroll doesn't change "
      "when trying to scroll backward again.",
      (tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        final state =
            tester.state(dragSelectGridViewFinder) as DragSelectGridViewState;

        // First scroll backward attempt.

        expect(state.autoScroll.isScrolling, isFalse);
        expect(state.autoScroll.direction, null);
        state.startAutoScrollingBackward();
        expect(state.autoScroll.isScrolling, isTrue);
        expect(state.autoScroll.direction, AutoScrollDirection.backward);

        // Second scroll backward attempt.

        final oldAutoScroll = state.autoScroll;
        state.startAutoScrollingBackward();
        expect(identical(oldAutoScroll, state.autoScroll), isTrue);
      },
    );

    testWidgets(
      "Auto-scroll direction is updated "
      "when `DragSelectGridView` starts to scroll forward, "
      "but auto-scroll doesn't change "
      "when trying to scroll forward again.",
      (tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        final state =
            tester.state(dragSelectGridViewFinder) as DragSelectGridViewState;

        // First scroll forward attempt.

        expect(state.autoScroll.isScrolling, isFalse);
        expect(state.autoScroll.direction, null);
        state.startAutoScrollingForward();
        expect(state.autoScroll.isScrolling, isTrue);
        expect(state.autoScroll.direction, AutoScrollDirection.forward);

        // Second scroll forward attempt.

        final oldAutoScroll = state.autoScroll;
        state.startAutoScrollingForward();
        expect(identical(oldAutoScroll, state.autoScroll), isTrue);
      },
    );

    testWidgets(
      "Auto-scroll is updated "
      "when stop scrolling, "
      "but auto-scroll doesn't change "
      "when trying to stop scrolling again.",
      (tester) async {
        final widget = createWidget();
        await tester.pumpWidget(widget);

        final state =
            tester.state(dragSelectGridViewFinder) as DragSelectGridViewState;

        state.startAutoScrollingForward();

        // First stop attempt.

        expect(state.autoScroll.isScrolling, isTrue);
        expect(state.autoScroll.direction, AutoScrollDirection.forward);
        state.stopScrolling();
        expect(state.autoScroll.isScrolling, isFalse);
        expect(state.autoScroll.direction, AutoScrollDirection.forward);

        // Second stop attempt.

        final oldAutoScroll = state.autoScroll;
        state.stopScrolling();
        expect(identical(oldAutoScroll, state.autoScroll), isTrue);
      },
    );
  });
}
