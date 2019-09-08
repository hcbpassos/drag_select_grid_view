import 'package:drag_select_grid_view/src/auto_scroller/auto_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';

import 'test_utils.dart';

void main() {
  final gridFinder = find.byType(DragSelectGridView);
  final emptySpaceFinder = find.byKey(const ValueKey('empty-space'));

  Widget widget;
  DragSelectGridViewState dragSelectState;

  Widget createWidget() {
    return MaterialApp(
      home: Row(
        children: [
          SizedBox(
            key: const ValueKey('empty-space'),
            height: double.infinity,
            width: 10,
          ),
          Expanded(
            child: DragSelectGridView(
              itemCount: 12,
              itemBuilder: (_, __, ___) => Container(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),
            ),
          )
        ],
      ),
    );
  }

  /// Notice that this is not a call to the the native [setUp] function.
  /// I could not use it because I need [WidgetTester] as a parameter to avoid
  /// creating the widget at every single [testWidgets].
  /// I get access to [WidgetTester], but in counterpart I have to call [setUp]
  /// manually at the initialization of every [testWidgets].
  Future<void> setUp(WidgetTester tester) async {
    widget = createWidget();
    await tester.pumpWidget(widget);
    dragSelectState = tester.state(gridFinder);
  }

  testWidgets(
    "An AssertionError is throw "
    "when creating a DragSelectGridView with null `itemBuilder`.",
    (WidgetTester tester) async {
      expect(
        () => MaterialApp(
          home: DragSelectGridView(
            itemCount: 0,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 1,
            ),
          ),
        ),
        throwsAssertionError,
      );
    },
  );

  testWidgets(
    "When an item of DragSelectGridView is long-pressed down and up, "
    "then `isDragging` becomes true, and then false.",
    (WidgetTester tester) async {
      await setUp(tester);

      // Initially, `isDragging` is false.
      expect(dragSelectState.isDragging, isFalse);

      // When an item of DragSelectGridView is long-pressed down.
      final gesture = await longPressDown(tester: tester, finder: gridFinder);
      await tester.pump();

      // Then `isDragging` becomes true.
      expect(dragSelectState.isDragging, isTrue);

      // When an item of DragSelectGridView is long-pressed up.
      await gesture.up();
      await tester.pump();

      // `isDragging` becomes false.
      expect(dragSelectState.isDragging, isFalse);
    },
  );

  testWidgets(
    "When an empty space of DragSelectGridView is long-pressed, "
    "then `isDragging` doesn't change.",
    (WidgetTester tester) async {
      await setUp(tester);

      // Initially, `isDragging` is false.
      expect(dragSelectState.isDragging, isFalse);

      // When an empty space of DragSelectGridView is long-pressed.
      await longPressDown(tester: tester, finder: emptySpaceFinder);
      await tester.pump();

      // `isDragging` doesn't change.
      expect(dragSelectState.isDragging, isFalse);
    },
  );

  testWidgets(
    "When an empty space of DragSelectGridView is long-pressed, "
    "then `isDragging` doesn't change.",
    (WidgetTester tester) async {
      await setUp(tester);

      // Initially, `isDragging` is false.
      expect(dragSelectState.isDragging, isFalse);

      // When an empty space of DragSelectGridView is long-pressed.
      await longPressDown(tester: tester, finder: emptySpaceFinder);
      await tester.pump();

      // `isDragging` doesn't change.
      expect(dragSelectState.isDragging, isFalse);
    },
  );

  group('Auto-scroll tests', () {
    testWidgets(
      "When there's a long-press and drag to the upper-hotspot, "
      "then auto-scroll is enabled.",
      (WidgetTester tester) async {
        await setUp(tester);

        // Initially, autoScroll is stopped.
        expect(dragSelectState.autoScroll, AutoScroll.stopped());

        // When the user long-presses and drags to the upper-hotspot.
        await longPressDownAndDrag(
          tester: tester,
          finder: gridFinder,
          offset: Offset(0, -(dragSelectState.height / 2) + 1),
        );
        await tester.pump();

        // Then auto-scroll is enabled.
        expect(dragSelectState.autoScroll.direction, AutoScrollDirection.up);
      },
    );

    testWidgets(
      "When there's a long-press and drag to the lower-hotspot, "
      "then auto-scroll is enabled.",
      (WidgetTester tester) async {
        await setUp(tester);

        await longPressDownAndDrag(
          tester: tester,
          finder: gridFinder,
          offset: Offset(0, (dragSelectState.height / 2)),
        );
        await tester.pump();
        expect(dragSelectState.autoScroll.direction, AutoScrollDirection.down);
      },
    );

    testWidgets(
      "Given that there were a long-press and drag to the upper-hotspot, "
      "when the long-press is released, "
      "then the auto-scroll is disabled with `AutoScrollDirection.up` "
      "and stop-event unconsumed.",
      (WidgetTester tester) async {
        await setUp(tester);

        // Given that there were a long-press and drag to the upper-hotspot.
        final gesture = await longPressDownAndDrag(
          tester: tester,
          finder: gridFinder,
          offset: Offset(0, -(dragSelectState.height / 2) + 1),
        );
        await tester.pump();
        expect(dragSelectState.autoScroll.direction, AutoScrollDirection.up);

        // When the long-press is released.
        await gesture.up();
        await tester.pump();

        // Then the auto-scroll is disabled with `AutoScrollDirection.up`
        // and stop-event unconsumed.
        expect(
          dragSelectState.autoScroll,
          AutoScroll.stopped(direction: AutoScrollDirection.up),
        );
      },
    );

    testWidgets(
      "Given that there were a long-press and drag to the lower-hotspot, "
      "when the long-press is released, "
      "then the auto-scroll is disabled with `AutoScrollDirection.down` "
      "and stop-event unconsumed.",
      (WidgetTester tester) async {
        await setUp(tester);

        // Given that there were a long-press and drag to the lower-hotspot.
        final gesture = await longPressDownAndDrag(
          tester: tester,
          finder: gridFinder,
          offset: Offset(0, dragSelectState.height / 2),
        );
        await tester.pump();
        expect(dragSelectState.autoScroll.direction, AutoScrollDirection.down);

        // When the long-press is released.
        await gesture.up();
        await tester.pump();

        // Then the auto-scroll is disabled with `AutoScrollDirection.down`
        // and stop-event unconsumed.
        expect(
          dragSelectState.autoScroll,
          AutoScroll.stopped(direction: AutoScrollDirection.down),
        );
      },
    );

    testWidgets(
      "Given that there were a long-press and drag to the lower-hotspot, "
      "when dragged out of the lower-hotspot, "
      "then the auto-scroll is disabled with `AutoScrollDirection.down` "
      "and stop-event unconsumed.",
      (WidgetTester tester) async {
        await setUp(tester);

        // Given that there were a long-press and drag to the lower-hotspot.
        final gesture = await longPressDownAndDrag(
          tester: tester,
          finder: gridFinder,
          offset: Offset(0, dragSelectState.height / 2),
        );
        await tester.pump();
        expect(dragSelectState.autoScroll.direction, AutoScrollDirection.down);

        // When dragged out of the lower-hotspot.
        await gesture.moveTo(tester.getCenter(gridFinder));
        await tester.pump();

        // Then the auto-scroll is disabled with `AutoScrollDirection.down`
        // and stop-event unconsumed.
        expect(
          dragSelectState.autoScroll,
          AutoScroll.stopped(direction: AutoScrollDirection.down),
        );
      },
    );
  });
}
