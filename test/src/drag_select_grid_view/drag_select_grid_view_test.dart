import 'package:drag_select_grid_view/src/auto_scroller/auto_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';

import '../test_utils.dart';

void main() {
  final gridFinder = find.byType(DragSelectGridView);
  final emptySpaceFinder = find.byKey(const ValueKey('empty-space'));

  final firstItemFinder = find.byKey(const ValueKey('grid-item-0'));
  final secondItemFinder = find.byKey(const ValueKey('grid-item-1'));
  final fifthItemFinder = find.byKey(const ValueKey('grid-item-4'));

  Widget widget;
  DragSelectGridViewState dragSelectState;

  /// Creates a [DragSelectGridView] with 4 columns and 3 lines, based on
  /// [screenHeight] and [screenWidth].
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
              itemBuilder: (_, index, __) => Container(
                key: ValueKey('grid-item-$index'),
              ),
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
  Future<void> setUp(tester) async {
    widget = createWidget();
    await tester.pumpWidget(widget);
    dragSelectState = tester.state(gridFinder);
  }

  testWidgets(
    "An AssertionError is throw "
    "when creating a DragSelectGridView with null `itemBuilder`.",
    (tester) async {
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

  group("Drag-select-grid-view integration tests.", () {
    testWidgets(
      "When an item of DragSelectGridView is long-pressed down and up, "
      "then `isDragging` becomes true, and then false.",
      (tester) async {
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
      (tester) async {
        await setUp(tester);

        // Initially, `isDragging` is false.
        expect(dragSelectState.isDragging, isFalse);

        // When an empty space of DragSelectGridView is long-pressed.
        await tester.longPress(emptySpaceFinder);
        await tester.pump();

        // `isDragging` doesn't change.
        expect(dragSelectState.isDragging, isFalse);
      },
    );

    testWidgets(
      "Given that the grid has 4 columns and 3 lines, "
      "and that the first item of the grid is UNSELECTED, "
      ""
      "when the first item of the grid is long-pressed, "
      ""
      "then the item gets SELECTED.",
      (tester) async {
        // Given that the grid has 4 columns and 3 lines,
        await setUp(tester);

        // and that the first item of the grid is UNSELECTED,
        expect(dragSelectState.selectedIndexes, <int>{});

        // when the first item of the grid is long-pressed,
        await tester.longPress(firstItemFinder);
        await tester.pump();

        // then the item gets SELECTED.
        expect(dragSelectState.isSelecting, isTrue);
        expect(dragSelectState.selectedIndexes, {0});
      },
    );

    testWidgets(
      "Given that the grid has 4 columns and 3 lines, "
      "and that the first item of the grid is UNSELECTED, "
      ""
      "when the first item of the grid is tapped, "
      ""
      "then the item stills UNSELECTED.",
      (tester) async {
        // Given that the grid has 4 columns and 3 lines,
        await setUp(tester);

        // and that the first item of the grid is UNSELECTED,
        expect(dragSelectState.selectedIndexes, <int>{});

        // when the first item of the grid is tapped,
        await tester.tap(firstItemFinder);
        await tester.pump();

        // then the item stills UNSELECTED.
        expect(dragSelectState.isSelecting, isFalse);
        expect(dragSelectState.selectedIndexes, <int>{});
      },
    );

    testWidgets(
      "Given that the grid has 4 columns and 3 lines, "
      "and that the first item of the grid is SELECTED, "
      ""
      "when the first item is long-pressed, "
      ""
      "then the item stills SELECTED.",
      (tester) async {
        // Given that the grid has 4 columns and 3 lines,
        await setUp(tester);

        // and that the first item of the grid is SELECTED,
        await tester.longPress(firstItemFinder);
        await tester.pump();

        // when the first item is long-pressed,
        await tester.longPress(firstItemFinder);
        await tester.pump();

        // then the item stills SELECTED.
        expect(dragSelectState.isSelecting, isTrue);
        expect(dragSelectState.selectedIndexes, {0});
      },
    );

    testWidgets(
      "Given that the grid has 4 columns and 3 lines, "
      "and that the first item of the grid is SELECTED, "
      ""
      "when the item is tapped, "
      ""
      "then the item gets UNSELECTED.",
      (tester) async {
        // Given that the grid has 4 columns and 3 lines,
        await setUp(tester);

        // and that the first item of the grid is SELECTED,
        await tester.longPress(firstItemFinder);
        await tester.pump();

        // when the item is tapped,
        await tester.tap(firstItemFinder);
        await tester.pump();

        // then the item stills SELECTED.
        expect(dragSelectState.isSelecting, isFalse);
        expect(dragSelectState.selectedIndexes, <int>{});
      },
    );

    testWidgets(
      "Given that the grid has 4 columns and 3 lines, "
      "and that the first item was long-pressed and SELECTED, "
      ""
      "when dragging to the second item (at the right), "
      ""
      "then the second item gets SELECTED, "
      "and the first item stills SELECTED.",
      (tester) async {
        // Given that the grid has 4 columns and 3 lines,
        await setUp(tester);

        // and that the first item was long-pressed and SELECTED,
        var gesture = await longPressDown(
          tester: tester,
          finder: firstItemFinder,
        );
        await tester.pump();

        // when dragging to the second item (at the right),

        final distanceFromFirstToSecondItem =
            tester.getCenter(secondItemFinder) -
                tester.getCenter(firstItemFinder);

        gesture = await dragDown(
          tester: tester,
          previousGesture: gesture,
          offset: distanceFromFirstToSecondItem,
        );
        await gesture.up();
        await tester.pump();

        // then the second item gets SELECTED,
        // and the first item stills SELECTED.
        expect(dragSelectState.isSelecting, isTrue);
        expect(dragSelectState.selectedIndexes, {0, 1});
      },
    );

    testWidgets(
      "Given that the grid has 4 columns and 3 lines, "
      "and that the first item was long-pressed and SELECTED, "
      "and the second item was selected by dragging, "
      ""
      "when dragging back to the first item, "
      ""
      "then the second item gets UNSELECTED, "
      "and the first item stills SELECTED.",
      (tester) async {
        // Given that the grid has 4 columns and 3 lines,
        await setUp(tester);

        // and that the first item was long-pressed and SELECTED,
        var gesture = await longPressDown(
          tester: tester,
          finder: firstItemFinder,
        );
        await tester.pump();

        // and the second item was selected by dragging,

        final distanceFromFirstToSecondItem =
            tester.getCenter(secondItemFinder) -
                tester.getCenter(firstItemFinder);

        gesture = await longPressDownAndDrag(
          tester: tester,
          finder: firstItemFinder,
          offset: distanceFromFirstToSecondItem,
        );
        await tester.pump();

        // when dragging back to the first item,

        await dragDown(
          tester: tester,
          previousGesture: gesture,
          offset: -distanceFromFirstToSecondItem,
        );
        await gesture.up();
        await tester.pump();

        // then the second item gets UNSELECTED,
        // and the first item stills SELECTED.
        expect(dragSelectState.isSelecting, isTrue);
        expect(dragSelectState.selectedIndexes, {0});
      },
    );

    testWidgets(
      "Given that the grid has 4 columns and 3 lines, "
      "and that the first item was long-pressed and SELECTED, "
      ""
      "when dragging to the fifth item (at the bottom), "
      ""
      "then all items from the second to the fifth get SELECTED, "
      "and the first item stills SELECTED.",
      (tester) async {
        // Given that the grid has 4 columns and 3 lines,
        await setUp(tester);

        // and that the first item was long-pressed and SELECTED,
        var gesture = await longPressDown(
          tester: tester,
          finder: firstItemFinder,
        );
        await tester.pump();

        // when dragging to the fifth item (at the bottom),

        final distanceFromFirstToFifthItem = tester.getCenter(fifthItemFinder) -
            tester.getCenter(firstItemFinder);

        gesture = await dragDown(
          tester: tester,
          previousGesture: gesture,
          offset: distanceFromFirstToFifthItem,
        );
        await gesture.up();
        await tester.pump();

        // then all items from the second to the fifth get SELECTED,
        // and the first item stills SELECTED.
        expect(dragSelectState.isSelecting, isTrue);
        expect(dragSelectState.selectedIndexes, {0, 1, 2, 3, 4});
      },
    );

    testWidgets(
      "Given that the grid has 4 columns and 3 lines, "
      "and that the first item was long-pressed and SELECTED, "
      "and all items from the second to the fifth were SELECTED by dragging, "
      ""
      "when dragging back to the first item, "
      ""
      "then all items from the fifth to the second get UNSELECTED, "
      "and the first item stills SELECTED.",
      (tester) async {
        // Given that the grid has 4 columns and 3 lines,
        await setUp(tester);

        // and that the first item was long-pressed and SELECTED,
        var gesture = await longPressDown(
          tester: tester,
          finder: firstItemFinder,
        );
        await tester.pump();

        // and all items from the second to the fifth were SELECTED by dragging,

        final distanceFromFirstToFifthItem = tester.getCenter(fifthItemFinder) -
            tester.getCenter(firstItemFinder);

        gesture = await dragDown(
          tester: tester,
          previousGesture: gesture,
          offset: distanceFromFirstToFifthItem,
        );
        await tester.pump();

        // when dragging back to the first item,

        await dragDown(
          tester: tester,
          previousGesture: gesture,
          offset: -distanceFromFirstToFifthItem,
        );
        await gesture.up();
        await tester.pump();

        // then all items from the fifth to the second get UNSELECTED,
        // and the first item stills SELECTED.
        expect(dragSelectState.isSelecting, isTrue);
        expect(dragSelectState.selectedIndexes, {0});
      },
    );
  });

  group("Auto-scrolling integration tests.", () {
    testWidgets(
      "When there's a long-press and drag to the upper-hotspot, "
      "then auto-scroll is enabled.",
      (tester) async {
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
      (tester) async {
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
      (tester) async {
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
      (tester) async {
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
      (tester) async {
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
