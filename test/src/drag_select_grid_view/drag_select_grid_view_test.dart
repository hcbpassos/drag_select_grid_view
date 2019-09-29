import 'package:flutter/material.dart' hide SelectionChangedCallback;
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

  final secondItemFinder = find.byKey(const ValueKey('grid-item-1'));
  final fifthItemFinder = find.byKey(const ValueKey('grid-item-4'));

  Widget widget;
  DragSelectGridViewState dragSelectState;

  Offset horizontalDistanceBetweenItems;
  Offset verticalDistanceBetweenItems;

  /// Creates a [DragSelectGridView] with 4 columns and 3 lines, based on
  /// [screenHeight] and [screenWidth].
  Widget createWidget([
    bool reverse,
    bool unselectOnWillPop,
    SelectionChangedCallback onSelectionChanged,
  ]) {
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
              onSelectionChanged: onSelectionChanged,
              unselectOnWillPop: unselectOnWillPop ?? true,
              reverse: reverse ?? false,
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
  Future<void> setUp(
    WidgetTester tester, {
    bool reverse,
    bool unselectOnWillPop,
    SelectionChangedCallback onSelectionChanged,
  }) async {
    widget = createWidget(reverse, unselectOnWillPop, onSelectionChanged);
    await tester.pumpWidget(widget);
    dragSelectState = tester.state(gridFinder);
    horizontalDistanceBetweenItems ??=
        tester.getCenter(secondItemFinder) - tester.getCenter(firstItemFinder);
    verticalDistanceBetweenItems ??=
        tester.getCenter(fifthItemFinder) - tester.getCenter(firstItemFinder);
  }

  testWidgets(
    "When creating a DragSelectGridView with null `itemBuilder`, "
    "then an AssertionError is thrown.",
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

  testWidgets(
    "Given that an item of DragSelectGridView was selected, "
    "and that we received a Selection object with a set of selected indexes, "
    "when modifying the set, "
    "then the set of selected indexes of the grid is not modified.",
    (tester) async {
      Selection selection;

      await setUp(
        tester,
        onSelectionChanged: (newSelection) => selection = newSelection,
      );

      // Given that an item of DragSelectGridView was selected,
      await tester.longPress(firstItemFinder);
      await tester.pump();

      // and that we received a Selection object with a set of selected indexes,
      expect(selection.selectedIndexes, {0});

      // when modifying the set,
      selection.selectedIndexes.clear();

      // then the set of selected indexes of the grid is not modified.
      expect(dragSelectState.selectedIndexes, {0});
    },
    skip: false,
  );

  group("Drag-select-grid-view integration tests.", () {
    group("Select by pressing.", () {
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
        "then the item gets selected, "
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

          // then the item gets selected.
          expect(dragSelectState.isSelecting, isTrue);
          expect(dragSelectState.selectedIndexes, {0});

          // and we get notified about selection change.
          expect(selectionChangedCount, 1);
          expect(selection.selectedIndexes, {0});
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
        "and that the first item of the grid is selected, "
        ""
        "when the first item is long-pressed, "
        ""
        "then the item stills selected.",
        (tester) async {
          // Given that the grid has 4 columns and 3 lines,
          await setUp(tester);

          // and that the first item of the grid is selected,
          await tester.longPress(firstItemFinder);
          await tester.pump();

          // when the first item is long-pressed,
          await tester.longPress(firstItemFinder);
          await tester.pump();

          // then the item stills selected.
          expect(dragSelectState.isSelecting, isTrue);
          expect(dragSelectState.selectedIndexes, {0});
        },
        skip: false,
      );

      testWidgets(
        "Given that the grid has 4 columns and 3 lines, "
        "and that the first item of the grid is selected, "
        ""
        "when the item is tapped, "
        ""
        "then the item gets UNSELECTED.",
        (tester) async {
          // Given that the grid has 4 columns and 3 lines,
          await setUp(tester);

          // and that the first item of the grid is selected,
          await tester.longPress(firstItemFinder);
          await tester.pump();

          // when the item is tapped,
          await tester.tap(firstItemFinder);
          await tester.pump();

          // then the item stills selected.
          expect(dragSelectState.isSelecting, isFalse);
          expect(dragSelectState.selectedIndexes, <int>{});
        },
        skip: false,
      );
    });

    group("Select by dragging forward.", () {
      testWidgets(
        "Given that the grid has 4 columns and 3 lines, "
        "and that the first item was long-pressed and selected, "
        ""
        "when dragging to the second item (at the right), "
        ""
        "then the second item gets selected, "
        "and the first item stills selected, "
        "and we get notified about selection changes.",
        (tester) async {
          int selectionChangedCount = 0;
          Selection selection;

          // Given that the grid has 4 columns and 3 lines,
          await setUp(tester, onSelectionChanged: (newSelection) {
            selectionChangedCount++;
            selection = newSelection;
          });

          // and that the first item was long-pressed and selected,
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

          // then the second item gets selected,
          // and the first item stills selected.
          expect(dragSelectState.isSelecting, isTrue);
          expect(dragSelectState.selectedIndexes, {0, 1});

          // and we get notified about selection changes.
          expect(selectionChangedCount, 2);
          expect(selection.selectedIndexes, {0, 1});
        },
        skip: false,
      );

      testWidgets(
        "Given that the grid has 4 columns and 3 lines, "
        "and that the first item was long-pressed and selected, "
        "and that the second item was selected by dragging, "
        ""
        "when dragging back to the first item, "
        ""
        "then the second item gets UNSELECTED, "
        "and the first item stills selected.",
        (tester) async {
          // Given that the grid has 4 columns and 3 lines,
          await setUp(tester);

          // and that the first item was long-pressed and selected,
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
          // and the first item stills selected.
          expect(dragSelectState.isSelecting, isTrue);
          expect(dragSelectState.selectedIndexes, {0});
        },
        skip: false,
      );

      testWidgets(
        "Given that the grid has 4 columns and 3 lines, "
        "and that the first item was long-pressed and selected, "
        ""
        "when dragging to the third item, passing through the second item, "
        ""
        "then the second and the third item get selected, "
        "and the first item stills selected.",
        (tester) async {
          // Given that the grid has 4 columns and 3 lines,
          await setUp(tester);

          // and that the first item was long-pressed and selected,
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

          // then the second and the third item get selected,
          // and the first item stills selected.
          expect(dragSelectState.isSelecting, isTrue);
          expect(dragSelectState.selectedIndexes, {0, 1, 2});
        },
        skip: false,
      );

      testWidgets(
        "Given that the grid has 4 columns and 3 lines, "
        "and that the first item was long-pressed and selected, "
        "and that the second and third items were selected by dragging, "
        ""
        "when dragging back to the first item, passing through the second item, "
        ""
        "then the third and the second item get UNSELECTED, "
        "and the first item stills selected.",
        (tester) async {
          // Given that the grid has 4 columns and 3 lines,
          await setUp(tester);

          // and that the first item was long-pressed and selected,
          var gesture = await longPressDown(
            tester: tester,
            finder: firstItemFinder,
          );
          await tester.pump();

          // and that the second and third items were selected by dragging,
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
          // and the first item stills selected.
          expect(dragSelectState.isSelecting, isTrue);
          expect(dragSelectState.selectedIndexes, {0});
        },
        skip: false,
      );

      testWidgets(
        "Given that the grid has 4 columns and 3 lines, "
        "and that the first item was long-pressed and selected, "
        ""
        "when dragging to the fifth item (at the bottom), "
        ""
        "then all items from the second to the fifth get selected, "
        "and the first item stills selected.",
        (tester) async {
          // Given that the grid has 4 columns and 3 lines,
          await setUp(tester);

          // and that the first item was long-pressed and selected,
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

          // then all items from the second to the fifth get selected,
          // and the first item stills selected.
          expect(dragSelectState.isSelecting, isTrue);
          expect(dragSelectState.selectedIndexes, {0, 1, 2, 3, 4});
        },
        skip: false,
      );

      testWidgets(
        "Given that the grid has 4 columns and 3 lines, "
        "and that the first item was long-pressed and selected, "
        "and that all items from the second to the fifth were selected by dragging, "
        ""
        "when dragging back to the first item, "
        ""
        "then all items from the fifth to the second get UNSELECTED, "
        "and the first item stills selected.",
        (tester) async {
          // Given that the grid has 4 columns and 3 lines,
          await setUp(tester);

          // and that the first item was long-pressed and selected,
          var gesture = await longPressDown(
            tester: tester,
            finder: firstItemFinder,
          );
          await tester.pump();

          // and that all items from the second to the fifth were selected by dragging,
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
          // and the first item stills selected.
          expect(dragSelectState.isSelecting, isTrue);
          expect(dragSelectState.selectedIndexes, {0});
        },
        skip: false,
      );
    });

    group("Select by dragging backward.", () {
      testWidgets(
        "Given that the grid has 4 columns and 3 lines, "
        "and that the last item was long-pressed and selected, "
        ""
        "when dragging to the second to last item (at the left), "
        ""
        "then the second to last item gets selected, "
        "and the last item stills selected, "
        "and we get notified about selection changes.",
        (tester) async {
          int selectionChangedCount = 0;
          Selection selection;

          // Given that the grid has 4 columns and 3 lines,
          await setUp(tester, onSelectionChanged: (newSelection) {
            selectionChangedCount++;
            selection = newSelection;
          });

          // and that the last item was long-pressed and selected,
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

          // then the second to last item gets selected,
          // and the last item stills selected.
          expect(dragSelectState.isSelecting, isTrue);
          expect(dragSelectState.selectedIndexes, {10, 11});

          // and we get notified about selection changes.
          expect(selectionChangedCount, 2);
          expect(selection.selectedIndexes, {10, 11});
        },
        skip: false,
      );

      testWidgets(
        "Given that the grid has 4 columns and 3 lines, "
        "and that the last item was long-pressed and selected, "
        "and that the second to last item was selected by dragging, "
        ""
        "when dragging back to the last item, "
        ""
        "then the second to last item gets UNSELECTED, "
        "and the last item stills selected.",
        (tester) async {
          // Given that the grid has 4 columns and 3 lines,
          await setUp(tester);

          // and that the last item was long-pressed and selected,
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
          // and the last item stills selected.
          expect(dragSelectState.isSelecting, isTrue);
          expect(dragSelectState.selectedIndexes, {11});
        },
        skip: false,
      );

      testWidgets(
        "Given that the grid has 4 columns and 3 lines, "
        "and that the last item was long-pressed and selected, "
        ""
        "when dragging to the third to last item, "
        "passing through the second to last item, "
        ""
        "then the second to last and the third to last item get selected, "
        "and the last item stills selected.",
        (tester) async {
          // Given that the grid has 4 columns and 3 lines,
          await setUp(tester);

          // and that the last item was long-pressed and selected,
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

          // then the second to last and the third to last item get selected,
          // and the last item stills selected.
          expect(dragSelectState.isSelecting, isTrue);
          expect(dragSelectState.selectedIndexes, {9, 10, 11});
        },
        skip: false,
      );

      testWidgets(
        "Given that the grid has 4 columns and 3 lines, "
        "and that the last item was long-pressed and selected, "
        "and that the second to last and third to last item "
        "were selected by dragging, "
        ""
        "when dragging back to the last item, "
        "passing through the second to last item, "
        ""
        "then the third to last and the second to last item get UNSELECTED, "
        "and the last item stills selected.",
        (tester) async {
          // Given that the grid has 4 columns and 3 lines,
          await setUp(tester);

          // and that the last item was long-pressed and selected,
          var gesture = await longPressDown(
            tester: tester,
            finder: lastItemFinder,
          );
          await tester.pump();

          // and that the second to last and third to last item
          // were selected by dragging,

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
          // and the last item stills selected.
          expect(dragSelectState.isSelecting, isTrue);
          expect(dragSelectState.selectedIndexes, {11});
        },
        skip: false,
      );

      testWidgets(
        "Given that the grid has 4 columns and 3 lines, "
        "and that the last item was long-pressed and selected, "
        ""
        "when dragging to the fifth to last item (at the top), "
        ""
        "then all items from the second to last to the fifth to last get selected, "
        "and the last item stills selected.",
        (tester) async {
          // Given that the grid has 4 columns and 3 lines,
          await setUp(tester);

          // and that the last item was long-pressed and selected,
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

          // then all items from the second to last to the fifth to last get selected,
          // and the last item stills selected.
          expect(dragSelectState.isSelecting, isTrue);
          expect(dragSelectState.selectedIndexes, {7, 8, 9, 10, 11});
        },
        skip: false,
      );

      testWidgets(
        "Given that the grid has 4 columns and 3 lines, "
        "and that the last item was long-pressed and selected, "
        "and that all items from the second to last to the fifth to last "
        "were selected by dragging, "
        ""
        "when dragging back to the last item, "
        ""
        "then all items from the fifth to last to the second to last get UNSELECTED, "
        "and the last item stills selected.",
        (tester) async {
          // Given that the grid has 4 columns and 3 lines,
          await setUp(tester);

          // and that the last item was long-pressed and selected,
          var gesture = await longPressDown(
            tester: tester,
            finder: lastItemFinder,
          );
          await tester.pump();

          // and that all items from the second to last to the fifth to last
          // were selected by dragging,
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
          // and the last item stills selected.
          expect(dragSelectState.isSelecting, isTrue);
          expect(dragSelectState.selectedIndexes, {11});
        },
        skip: false,
      );
    });

    testWidgets(
      "Given that the grid should unselect when trying to pop the route, "
      "and that an item of the grid was selected, "
      "when trying to pop the route, "
      "then the item gets UNSELECTED.",
      (tester) async {
        await setUp(tester, unselectOnWillPop: true);

        // Given that an item of the grid was selected,
        await tester.longPress(firstItemFinder);
        await tester.pump();

        // when trying to pop the route,
        await WidgetsBinding.instance.handlePopRoute();

        // then the item gets UNSELECTED.
        expect(dragSelectState.isSelecting, isFalse);
        expect(dragSelectState.selectedIndexes, <int>{});
      },
      skip: false,
    );

    testWidgets(
      "Given that the grid should NOT unselect when trying to pop the route, "
      "and that an item of the grid was selected, "
      "when trying to pop the route, "
      "then the item doesn't get UNSELECTED.",
      (tester) async {
        await setUp(tester, unselectOnWillPop: false);

        // Given that an item of the grid was selected,
        await tester.longPress(firstItemFinder);
        await tester.pump();

        // when trying to pop the route,
        await WidgetsBinding.instance.handlePopRoute();

        // then the item doesn't get UNSELECTED.
        expect(dragSelectState.isSelecting, isTrue);
        expect(dragSelectState.selectedIndexes, {0});
      },
      skip: false,
    );
  });

  group("Auto-scrolling integration tests.", () {
    testWidgets(
      "When there's a long-press and drag to the upper-hotspot, "
      "then backward auto-scroll is triggered.",
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

        // then backward auto-scroll is triggered.
        expect(
          dragSelectState.autoScroll.direction,
          AutoScrollDirection.backward,
        );
      },
      skip: false,
    );

    testWidgets(
      "Given that the scroll is reversed, "
      "when there's a long-press and drag to the upper-hotspot, "
      "then forward auto-scroll is triggered.",
      (tester) async {
        // Given that the scroll is reversed,
        await setUp(tester, reverse: true);

        // when there's a long-press and drag to the upper-hotspot,
        await longPressDownAndDrag(
          tester: tester,
          finder: gridFinder,
          offset: Offset(0, -(dragSelectState.context.size.height / 2) + 1),
        );
        await tester.pump();

        // then forward auto-scroll is triggered.
        expect(
          dragSelectState.autoScroll.direction,
          AutoScrollDirection.forward,
        );
      },
      skip: false,
    );

    testWidgets(
      "When there's a long-press and drag to the lower-hotspot, "
      "then forward auto-scroll is triggered.",
      (tester) async {
        await setUp(tester);

        // When there's a long-press and drag to the lower-hotspot,
        await longPressDownAndDrag(
          tester: tester,
          finder: gridFinder,
          offset: Offset(0, (dragSelectState.context.size.height / 2)),
        );
        await tester.pump();

        // then forward auto-scroll is triggered.
        expect(
          dragSelectState.autoScroll.direction,
          AutoScrollDirection.forward,
        );
      },
      skip: false,
    );

    testWidgets(
      "Given that the scroll is reversed, "
      "when there's a long-press and drag to the lower-hotspot, "
      "then backward auto-scroll is triggered.",
      (tester) async {
        // Given that the scroll is reversed,
        await setUp(tester, reverse: true);

        // When there's a long-press and drag to the lower-hotspot,
        await longPressDownAndDrag(
          tester: tester,
          finder: gridFinder,
          offset: Offset(0, (dragSelectState.context.size.height / 2)),
        );
        await tester.pump();

        // then backward auto-scroll is triggered.
        expect(
          dragSelectState.autoScroll.direction,
          AutoScrollDirection.backward,
        );
      },
      skip: false,
    );

    testWidgets(
      "Given that there were a long-press and drag to the upper-hotspot, "
      "when the long-press is released, "
      "then the auto-scroll is disabled with `AutoScrollDirection.backward` "
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
        expect(
          dragSelectState.autoScroll.direction,
          AutoScrollDirection.backward,
        );

        // when the long-press is released,
        await gesture.up();
        await tester.pump();

        // then the auto-scroll is disabled with `AutoScrollDirection.backward`
        // and stop-event unconsumed.
        expect(
          dragSelectState.autoScroll,
          AutoScroll.stopped(direction: AutoScrollDirection.backward),
        );
      },
      skip: false,
    );

    testWidgets(
      "Given that there were a long-press and drag to the lower-hotspot, "
      "when the long-press is released, "
      "then the auto-scroll is disabled with `AutoScrollDirection.forward` "
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
        expect(
          dragSelectState.autoScroll.direction,
          AutoScrollDirection.forward,
        );

        // when the long-press is released,
        await gesture.up();
        await tester.pump();

        // then the auto-scroll is disabled with `AutoScrollDirection.forward`
        // and stop-event unconsumed.
        expect(
          dragSelectState.autoScroll,
          AutoScroll.stopped(direction: AutoScrollDirection.forward),
        );
      },
      skip: false,
    );

    testWidgets(
      "Given that there were a long-press and drag to the lower-hotspot, "
      "when dragged out of the lower-hotspot, "
      "then the auto-scroll is disabled with `AutoScrollDirection.forward` "
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
        expect(
          dragSelectState.autoScroll.direction,
          AutoScrollDirection.forward,
        );

        // when dragged out of the lower-hotspot,
        await gesture.moveTo(tester.getCenter(gridFinder));
        await tester.pump();

        // then the auto-scroll is disabled with `AutoScrollDirection.forward`
        // and stop-event unconsumed.
        expect(
          dragSelectState.autoScroll,
          AutoScroll.stopped(direction: AutoScrollDirection.forward),
        );
      },
      skip: false,
    );
  });
}
