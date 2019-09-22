import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:drag_select_grid_view/src/auto_scroll/auto_scroll.dart';
import 'package:drag_select_grid_view/src/drag_select_grid_view/drag_select_grid_view.dart';

import '../test_utils.dart';

void main() {
  final gridFinder = find.byType(DragSelectGridView);
  final emptySpaceFinder = find.byKey(const ValueKey('empty-space'));

  final firstItemFinder = find.byKey(const ValueKey('grid-item-0'));
  final lastItemFinder = find.byKey(const ValueKey('grid-item-11'));
  final sixthItemFinder = find.byKey(const ValueKey('grid-item-5'));

  final secondItemFinder = find.byKey(const ValueKey('grid-item-1'));
  final fifthItemFinder = find.byKey(const ValueKey('grid-item-4'));

  Widget widget;
  DragSelectGridViewState dragSelectState;

  Offset horizontalDistanceBetweenItems;
  Offset verticalDistanceBetweenItems;

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
    horizontalDistanceBetweenItems =
        tester.getCenter(secondItemFinder) - tester.getCenter(firstItemFinder);
    verticalDistanceBetweenItems =
        tester.getCenter(fifthItemFinder) - tester.getCenter(firstItemFinder);
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
    skip: false,
  );

  group("Drag-select-grid-view integration tests.", () {
    group('Select by pressing.', () {
      testWidgets(
        "When an item of DragSelectGridView is long-pressed down, "
        "then `isDragging` becomes true.",
        (tester) async {
          await setUp(tester);

          // Initially, `isDragging` is false.
          expect(dragSelectState.isDragging, isFalse);

          // When an item of DragSelectGridView is long-pressed down,
          await longPressDown(tester: tester, finder: gridFinder);
          await tester.pump();

          // then `isDragging` becomes true.
          expect(dragSelectState.isDragging, isTrue);
        },
        skip: false,
      );

      testWidgets(
        "Given that an item of DragSelectGridView was long-pressed down, "
        "when the item is long-pressed up, "
        "then `isDragging` becomes false.",
        (tester) async {
          await setUp(tester);

          // Given that an item of DragSelectGridView was long-pressed down,
          final gesture =
              await longPressDown(tester: tester, finder: gridFinder);
          await tester.pump();

          // when the item is long-pressed up,
          await gesture.up();
          await tester.pump();

          // then `isDragging` becomes false.
          expect(dragSelectState.isDragging, isFalse);
        },
        skip: false,
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

          // then `isDragging` doesn't change.
          expect(dragSelectState.isDragging, isFalse);
        },
        skip: false,
      );

      testWidgets(
        "Given that the grid has 4 columns and 3 lines, "
        "and that the first item of the grid is UNSELECTED, "
        ""
        "when the first item of the grid is long-pressed, "
        ""
        "then the item gets SELECTED, "
        "and we get notified about selection change.",
        (tester) async {
          int selectionChangedCount = 0;
          Selection selection;

          // Given that the grid has 4 columns and 3 lines,
          await setUp(tester, onSelectionChanged: (newSelection) {
            selectionChangedCount++;
            selection = newSelection;
          });

          // and that the first item of the grid is UNSELECTED,
          expect(dragSelectState.selectedIndexes, <int>{});

          // when the first item of the grid is long-pressed,
          await tester.longPress(firstItemFinder);
          await tester.pump();

          // then the item gets SELECTED.
          expect(dragSelectState.isSelecting, isTrue);
          expect(dragSelectState.selectedIndexes, {0});
        },
        skip: false,
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
        skip: false,
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
        skip: false,
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
        skip: false,
      );
    });

    group('Select by dragging forward.', () {
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
          gesture = await dragDown(
            tester: tester,
            previousGesture: gesture,
            offset: horizontalDistanceBetweenItems,
          );
          await gesture.up();
          await tester.pump();

          // then the second item gets SELECTED,
          // and the first item stills SELECTED.
          expect(dragSelectState.isSelecting, isTrue);
          expect(dragSelectState.selectedIndexes, {0, 1});
        },
        skip: false,
      );

      testWidgets(
        "Given that the grid has 4 columns and 3 lines, "
        "and that the first item was long-pressed and SELECTED, "
        "and that the second item was selected by dragging, "
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

          // and that the second item was selected by dragging,
          gesture = await longPressDownAndDrag(
            tester: tester,
            finder: firstItemFinder,
            offset: horizontalDistanceBetweenItems,
          );
          await tester.pump();

          // when dragging back to the first item,
          gesture = await dragDown(
            tester: tester,
            previousGesture: gesture,
            offset: -horizontalDistanceBetweenItems,
          );
          await gesture.up();
          await tester.pump();

          // then the second item gets UNSELECTED,
          // and the first item stills SELECTED.
          expect(dragSelectState.isSelecting, isTrue);
          expect(dragSelectState.selectedIndexes, {0});
        },
        skip: false,
      );

      testWidgets(
        "Given that the grid has 4 columns and 3 lines, "
        "and that the first item was long-pressed and SELECTED, "
        ""
        "when dragging to the third item, passing through the second item, "
        ""
        "then the second and the third item get SELECTED, "
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

          // when dragging to the third item, passing through the second item,

          gesture = await dragDown(
            tester: tester,
            previousGesture: gesture,
            offset: horizontalDistanceBetweenItems,
          );
          await tester.pump();

          gesture = await dragDown(
            tester: tester,
            previousGesture: gesture,
            offset: horizontalDistanceBetweenItems,
          );
          await gesture.up();
          await tester.pump();

          // then the second and the third item get SELECTED,
          // and the first item stills SELECTED.
          expect(dragSelectState.isSelecting, isTrue);
          expect(dragSelectState.selectedIndexes, {0, 1, 2});
        },
        skip: false,
      );

      testWidgets(
        "Given that the grid has 4 columns and 3 lines, "
        "and that the first item was long-pressed and SELECTED, "
        "and that the second and third items were SELECTED by dragging, "
        ""
        "when dragging back to the first item, passing through the second item, "
        ""
        "then the third and the second item get UNSELECTED, "
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

          // and that the second and third items were SELECTED by dragging,
          gesture = await dragDown(
            tester: tester,
            previousGesture: gesture,
            offset: horizontalDistanceBetweenItems * 2,
          );
          await tester.pump();

          // when dragging back to the first item, passing through the second item,

          gesture = await dragDown(
            tester: tester,
            previousGesture: gesture,
            offset: -horizontalDistanceBetweenItems,
          );
          await tester.pump();

          gesture = await dragDown(
            tester: tester,
            previousGesture: gesture,
            offset: -horizontalDistanceBetweenItems,
          );
          await gesture.up();
          await tester.pump();

          // then the third and the second item get UNSELECTED,
          // and the first item stills SELECTED.
          expect(dragSelectState.isSelecting, isTrue);
          expect(dragSelectState.selectedIndexes, {0});
        },
        skip: false,
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
          gesture = await dragDown(
            tester: tester,
            previousGesture: gesture,
            offset: verticalDistanceBetweenItems,
          );
          await gesture.up();
          await tester.pump();

          // then all items from the second to the fifth get SELECTED,
          // and the first item stills SELECTED.
          expect(dragSelectState.isSelecting, isTrue);
          expect(dragSelectState.selectedIndexes, {0, 1, 2, 3, 4});
        },
        skip: false,
      );

      testWidgets(
        "Given that the grid has 4 columns and 3 lines, "
        "and that the first item was long-pressed and SELECTED, "
        "and that all items from the second to the fifth were SELECTED by dragging, "
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

          // and that all items from the second to the fifth were SELECTED by dragging,
          gesture = await dragDown(
            tester: tester,
            previousGesture: gesture,
            offset: verticalDistanceBetweenItems,
          );
          await tester.pump();

          // when dragging back to the first item,
          gesture = await dragDown(
            tester: tester,
            previousGesture: gesture,
            offset: -verticalDistanceBetweenItems,
          );
          await gesture.up();
          await tester.pump();

          // then all items from the fifth to the second get UNSELECTED,
          // and the first item stills SELECTED.
          expect(dragSelectState.isSelecting, isTrue);
          expect(dragSelectState.selectedIndexes, {0});
        },
        skip: false,
      );
    });

    group('Select by dragging backward.', () {
      testWidgets(
        "Given that the grid has 4 columns and 3 lines, "
        "and that the last item was long-pressed and SELECTED, "
        ""
        "when dragging to the second to last item (at the left), "
        ""
        "then the second to last item gets SELECTED, "
        "and the last item stills SELECTED.",
        (tester) async {
          // Given that the grid has 4 columns and 3 lines,
          await setUp(tester);

          // and that the last item was long-pressed and SELECTED,
          var gesture = await longPressDown(
            tester: tester,
            finder: lastItemFinder,
          );
          await tester.pump();

          // when dragging to the second to last item (at the left),
          gesture = await dragDown(
            tester: tester,
            previousGesture: gesture,
            offset: -horizontalDistanceBetweenItems,
          );
          await gesture.up();
          await tester.pump();

          // then the second to last item gets SELECTED,
          // and the last item stills SELECTED.
          expect(dragSelectState.isSelecting, isTrue);
          expect(dragSelectState.selectedIndexes, {10, 11});
        },
        skip: false,
      );

      testWidgets(
        "Given that the grid has 4 columns and 3 lines, "
        "and that the last item was long-pressed and SELECTED, "
        "and that the second to last item was selected by dragging, "
        ""
        "when dragging back to the last item, "
        ""
        "then the second to last item gets UNSELECTED, "
        "and the last item stills SELECTED.",
        (tester) async {
          // Given that the grid has 4 columns and 3 lines,
          await setUp(tester);

          // and that the last item was long-pressed and SELECTED,
          var gesture = await longPressDown(
            tester: tester,
            finder: lastItemFinder,
          );
          await tester.pump();

          // and that the second to last item was selected by dragging,
          gesture = await dragDown(
            tester: tester,
            previousGesture: gesture,
            offset: -horizontalDistanceBetweenItems,
          );
          await tester.pump();

          // when dragging back to the last item,
          gesture = await dragDown(
            tester: tester,
            previousGesture: gesture,
            offset: horizontalDistanceBetweenItems,
          );
          await gesture.up();
          await tester.pump();

          // then the second to last item gets UNSELECTED,
          // and the last item stills SELECTED.
          expect(dragSelectState.isSelecting, isTrue);
          expect(dragSelectState.selectedIndexes, {11});
        },
        skip: false,
      );

      testWidgets(
        "Given that the grid has 4 columns and 3 lines, "
        "and that the last item was long-pressed and SELECTED, "
        ""
        "when dragging to the third to last item, "
        "passing through the second to last item, "
        ""
        "then the second to last and the third to last item get SELECTED, "
        "and the last item stills SELECTED.",
        (tester) async {
          // Given that the grid has 4 columns and 3 lines,
          await setUp(tester);

          // and that the last item was long-pressed and SELECTED,
          var gesture =
              await longPressDown(tester: tester, finder: lastItemFinder);
          await tester.pump();

          // when dragging to the third to last item,
          // passing through the second to last item,

          gesture = await dragDown(
            tester: tester,
            previousGesture: gesture,
            offset: -horizontalDistanceBetweenItems,
          );
          await tester.pump();

          gesture = await dragDown(
            tester: tester,
            previousGesture: gesture,
            offset: -horizontalDistanceBetweenItems,
          );
          await gesture.up();
          await tester.pump();

          // then the second to last and the third to last item get SELECTED,
          // and the last item stills SELECTED.
          expect(dragSelectState.isSelecting, isTrue);
          expect(dragSelectState.selectedIndexes, {9, 10, 11});
        },
        skip: false,
      );

      testWidgets(
        "Given that the grid has 4 columns and 3 lines, "
        "and that the last item was long-pressed and SELECTED, "
        "and that the second to last and third to last item "
        "were SELECTED by dragging, "
        ""
        "when dragging back to the last item, "
        "passing through the second to last item, "
        ""
        "then the third to last and the second to last item get UNSELECTED, "
        "and the last item stills SELECTED.",
        (tester) async {
          // Given that the grid has 4 columns and 3 lines,
          await setUp(tester);

          // and that the last item was long-pressed and SELECTED,
          var gesture = await longPressDown(
            tester: tester,
            finder: lastItemFinder,
          );
          await tester.pump();

          // and that the second to last and third to last item
          // were SELECTED by dragging,

          gesture = await dragDown(
            tester: tester,
            previousGesture: gesture,
            offset: -horizontalDistanceBetweenItems * 2,
          );
          await tester.pump();

          // when dragging back to the last item,
          // passing through the second to last item,

          gesture = await dragDown(
            tester: tester,
            previousGesture: gesture,
            offset: horizontalDistanceBetweenItems,
          );
          await tester.pump();

          gesture = await dragDown(
            tester: tester,
            previousGesture: gesture,
            offset: horizontalDistanceBetweenItems,
          );
          await gesture.up();
          await tester.pump();

          // then the third to last and the second to last item get UNSELECTED,
          // and the last item stills SELECTED.
          expect(dragSelectState.isSelecting, isTrue);
          expect(dragSelectState.selectedIndexes, {11});
        },
        skip: false,
      );

      testWidgets(
        "Given that the grid has 4 columns and 3 lines, "
        "and that the last item was long-pressed and SELECTED, "
        ""
        "when dragging to the fifth to last item (at the top), "
        ""
        "then all items from the second to last to the fifth to last get SELECTED, "
        "and the last item stills SELECTED.",
        (tester) async {
          // Given that the grid has 4 columns and 3 lines,
          await setUp(tester);

          // and that the last item was long-pressed and SELECTED,
          var gesture = await longPressDown(
            tester: tester,
            finder: lastItemFinder,
          );
          await tester.pump();

          // when dragging to the fifth to last item (at the top),
          gesture = await dragDown(
            tester: tester,
            previousGesture: gesture,
            offset: -verticalDistanceBetweenItems,
          );
          await gesture.up();
          await tester.pump();

          // then all items from the second to last to the fifth to last get SELECTED,
          // and the last item stills SELECTED.
          expect(dragSelectState.isSelecting, isTrue);
          expect(dragSelectState.selectedIndexes, {7, 8, 9, 10, 11});
        },
        skip: false,
      );

      testWidgets(
        "Given that the grid has 4 columns and 3 lines, "
        "and that the last item was long-pressed and SELECTED, "
        "and that all items from the second to last to the fifth to last "
        "were SELECTED by dragging, "
        ""
        "when dragging back to the last item, "
        ""
        "then all items from the fifth to last to the second to last get UNSELECTED, "
        "and the last item stills SELECTED.",
        (tester) async {
          // Given that the grid has 4 columns and 3 lines,
          await setUp(tester);

          // and that the last item was long-pressed and SELECTED,
          var gesture = await longPressDown(
            tester: tester,
            finder: lastItemFinder,
          );
          await tester.pump();

          // and that all items from the second to last to the fifth to last
          // were SELECTED by dragging,
          gesture = await dragDown(
            tester: tester,
            previousGesture: gesture,
            offset: -verticalDistanceBetweenItems,
          );
          await tester.pump();

          // when dragging back to the last item,
          gesture = await dragDown(
            tester: tester,
            previousGesture: gesture,
            offset: verticalDistanceBetweenItems,
          );
          await gesture.up();
          await tester.pump();

          // then all items from the fifth to last to the second to last get UNSELECTED,
          // and the last item stills SELECTED.
          expect(dragSelectState.isSelecting, isTrue);
          expect(dragSelectState.selectedIndexes, {11});
        },
        skip: false,
      );
    });
  });

  group("Auto-scrolling integration tests.", () {
    testWidgets(
      "When there's a long-press and drag to the upper-hotspot, "
      "then auto-scroll is enabled.",
      (tester) async {
        await setUp(tester);

        // Initially, autoScroll is stopped.
        expect(dragSelectState.autoScroll, AutoScroll.stopped());

        // When there's a long-press and drag to the upper-hotspot,
        await longPressDownAndDrag(
          tester: tester,
          finder: gridFinder,
          offset: Offset(0, -(dragSelectState.context.size.height / 2) + 1),
        );
        await tester.pump();

        // then auto-scroll is enabled.
        expect(dragSelectState.autoScroll.direction, AutoScrollDirection.up);
      },
      skip: false,
    );

    testWidgets(
      "When there's a long-press and drag to the lower-hotspot, "
      "then auto-scroll is enabled.",
      (tester) async {
        await setUp(tester);

        await longPressDownAndDrag(
          tester: tester,
          finder: gridFinder,
          offset: Offset(0, (dragSelectState.context.size.height / 2)),
        );
        await tester.pump();
        expect(dragSelectState.autoScroll.direction, AutoScrollDirection.down);
      },
      skip: false,
    );

    testWidgets(
      "Given that there were a long-press and drag to the upper-hotspot, "
      "when the long-press is released, "
      "then the auto-scroll is disabled with `AutoScrollDirection.up` "
      "and stop-event unconsumed.",
      (tester) async {
        await setUp(tester);

        // Given that there were a long-press and drag to the upper-hotspot,
        final gesture = await longPressDownAndDrag(
          tester: tester,
          finder: gridFinder,
          offset: Offset(0, -(dragSelectState.context.size.height / 2) + 1),
        );
        await tester.pump();
        expect(dragSelectState.autoScroll.direction, AutoScrollDirection.up);

        // when the long-press is released,
        await gesture.up();
        await tester.pump();

        // then the auto-scroll is disabled with `AutoScrollDirection.up`
        // and stop-event unconsumed.
        expect(
          dragSelectState.autoScroll,
          AutoScroll.stopped(direction: AutoScrollDirection.up),
        );
      },
      skip: false,
    );

    testWidgets(
      "Given that there were a long-press and drag to the lower-hotspot, "
      "when the long-press is released, "
      "then the auto-scroll is disabled with `AutoScrollDirection.down` "
      "and stop-event unconsumed.",
      (tester) async {
        await setUp(tester);

        // Given that there were a long-press and drag to the lower-hotspot,
        final gesture = await longPressDownAndDrag(
          tester: tester,
          finder: gridFinder,
          offset: Offset(0, dragSelectState.context.size.height / 2),
        );
        await tester.pump();
        expect(dragSelectState.autoScroll.direction, AutoScrollDirection.down);

        // when the long-press is released,
        await gesture.up();
        await tester.pump();

        // then the auto-scroll is disabled with `AutoScrollDirection.down`
        // and stop-event unconsumed.
        expect(
          dragSelectState.autoScroll,
          AutoScroll.stopped(direction: AutoScrollDirection.down),
        );
      },
      skip: false,
    );

    testWidgets(
      "Given that there were a long-press and drag to the lower-hotspot, "
      "when dragged out of the lower-hotspot, "
      "then the auto-scroll is disabled with `AutoScrollDirection.down` "
      "and stop-event unconsumed.",
      (tester) async {
        await setUp(tester);

        // Given that there were a long-press and drag to the lower-hotspot,
        final gesture = await longPressDownAndDrag(
          tester: tester,
          finder: gridFinder,
          offset: Offset(0, dragSelectState.context.size.height / 2),
        );
        await tester.pump();
        expect(dragSelectState.autoScroll.direction, AutoScrollDirection.down);

        // when dragged out of the lower-hotspot,
        await gesture.moveTo(tester.getCenter(gridFinder));
        await tester.pump();

        // then the auto-scroll is disabled with `AutoScrollDirection.down`
        // and stop-event unconsumed.
        expect(
          dragSelectState.autoScroll,
          AutoScroll.stopped(direction: AutoScrollDirection.down),
        );
      },
      skip: false,
    );
  });
}
