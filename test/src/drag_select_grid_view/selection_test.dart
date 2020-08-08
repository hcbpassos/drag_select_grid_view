import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:drag_select_grid_view/src/drag_select_grid_view/selection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("`SelectionManager` tests", () {
    group("Select by tapping.", () {
      test(
        "When tapping the index 0, "
        "then the index 0 gets selected.",
        () {
          final manager = SelectionManager();
          expect(manager.selectedIndexes, <int>{});

          manager.tap(0);
          expect(manager.selectedIndexes, {0});
        },
      );

      test(
        "Given that the index 0 is selected, "
        "when tapping the index 0, "
        "then the index 0 gets UNSELECTED.",
        () {
          final manager = SelectionManager();

          manager.tap(0);
          expect(manager.selectedIndexes, {0});

          manager.tap(0);
          expect(manager.selectedIndexes, <int>{});
        },
      );

      test(
        "Given that the index 0 was UNSELECTED, "
        "when tapping the index 0, "
        "then the index 0 gets selected again.",
        () {
          final manager = SelectionManager();

          manager.tap(0);
          expect(manager.selectedIndexes, {0});

          manager.tap(0);
          expect(manager.selectedIndexes, <int>{});

          manager.tap(0);
          expect(manager.selectedIndexes, {0});
        },
      );
    });

    group("Select by dragging forward.", () {
      test(
        "When dragging from index 0 to index 2, "
        "then all indexes from 0 to 2 get selected.",
        () {
          final manager = SelectionManager();

          manager.startDrag(0);
          manager.updateDrag(1);
          manager.updateDrag(2);
          manager.endDrag();

          expect(manager.selectedIndexes, {0, 1, 2});
        },
      );

      test(
        "When directly dragging from index 0 to index 2, "
        "then all indexes from 0 to 2 get selected.",
        () {
          final manager = SelectionManager();

          manager.startDrag(0);
          manager.updateDrag(2);
          manager.endDrag();

          expect(manager.selectedIndexes, {0, 1, 2});
        },
      );

      test(
        "Given that all indexes from 0 to 2 were selected by dragging, "
        "when dragging back to the index 0, "
        "then the indexes 2 and 1 get UNSELECTED, "
        "and the index 0 stills selected.",
        () {
          final manager = SelectionManager();

          manager.startDrag(0);
          manager.updateDrag(1);
          manager.updateDrag(2);

          manager.updateDrag(1);
          manager.updateDrag(0);
          manager.endDrag();

          expect(manager.selectedIndexes, {0});
        },
      );

      test(
        "Given that all indexes from 0 to 2 were selected by dragging, "
        "when directly dragging back to the index 0, "
        "then the indexes 2 and 1 get UNSELECTED, "
        "and the index 0 stills selected.",
        () {
          final manager = SelectionManager();

          manager.startDrag(0);
          manager.updateDrag(2);
          manager.updateDrag(0);
          manager.endDrag();

          expect(manager.selectedIndexes, {0});
        },
      );

      test(
        "Given that all indexes from 2 to 4 were selected by dragging, "
        "when dragging back to the index 0, "
        "then the indexes 4 and 3 get UNSELECTED, "
        "and the index 2 stills selected, "
        "and the indexes 1 and 0 get selected.",
        () {
          final manager = SelectionManager();

          manager.startDrag(2);
          manager.updateDrag(3);
          manager.updateDrag(4);

          manager.updateDrag(3);
          manager.updateDrag(2);
          manager.updateDrag(1);
          manager.updateDrag(0);
          manager.endDrag();

          expect(manager.selectedIndexes, {0, 1, 2});
        },
      );

      test(
        "Given that all indexes from 2 to 4 were selected by dragging, "
        "and that all indexes from 2 to 0 were selected by dragging back, "
        "when dragging to the index 2, "
        "then the indexes 0 and 1 get UNSELECTED, "
        "and the index 2 stills selected.",
        () {
          final manager = SelectionManager();

          manager.startDrag(2);
          manager.updateDrag(3);
          manager.updateDrag(4);

          manager.updateDrag(3);
          manager.updateDrag(2);
          manager.updateDrag(1);
          manager.updateDrag(0);

          manager.updateDrag(1);
          manager.updateDrag(2);
          manager.endDrag();

          expect(manager.selectedIndexes, {2});
        },
      );

      test(
        "Given that all indexes from 2 to 4 were selected by dragging, "
        "when directly dragging back to the index 0, "
        "then the indexes 4 and 3 get UNSELECTED, "
        "and the index 2 stills selected, "
        "and the indexes 1 and 0 get selected.",
        () {
          final manager = SelectionManager();

          manager.startDrag(2);
          manager.updateDrag(4);
          manager.updateDrag(0);
          manager.endDrag();

          expect(manager.selectedIndexes, {0, 1, 2});
        },
      );

      test(
        "Given that all indexes from 2 to 4 were selected by dragging, "
        "and that all indexes from 2 to 0 were selected by dragging back, "
        "when directly dragging to the index 2, "
        "then the indexes 0 and 1 get UNSELECTED, "
        "and the index 2 stills selected.",
        () {
          final manager = SelectionManager();

          manager.startDrag(2);
          manager.updateDrag(4);
          manager.updateDrag(0);
          manager.updateDrag(2);
          manager.endDrag();

          expect(manager.selectedIndexes, {2});
        },
      );
    });

    group("Select by dragging backward.", () {
      test(
        "When dragging from index 2 to index 0, "
        "then all indexes from 2 to 0 get selected.",
        () {
          final manager = SelectionManager();

          manager.startDrag(2);
          manager.updateDrag(1);
          manager.updateDrag(0);
          manager.endDrag();

          expect(manager.selectedIndexes, {0, 1, 2});
        },
      );

      test(
        "When directly dragging from index 2 to index 0, "
        "then all indexes from 2 to 0 get selected.",
        () {
          final manager = SelectionManager();

          manager.startDrag(2);
          manager.updateDrag(0);
          manager.endDrag();

          expect(manager.selectedIndexes, {0, 1, 2});
        },
      );

      test(
        "Given that all indexes from 2 to 0 were selected by dragging, "
        "when dragging back to the index 2, "
        "then the indexes 0 and 1 get UNSELECTED, "
        "and the index 2 stills selected.",
        () {
          final manager = SelectionManager();

          manager.startDrag(2);
          manager.updateDrag(1);
          manager.updateDrag(0);

          manager.updateDrag(1);
          manager.updateDrag(2);
          manager.endDrag();

          expect(manager.selectedIndexes, {2});
        },
      );

      test(
        "Given that all indexes from 2 to 0 were selected by dragging, "
        "when directly dragging back to the index 2, "
        "then the indexes 0 and 1 get UNSELECTED, "
        "and the index 2 stills selected.",
        () {
          final manager = SelectionManager();

          manager.startDrag(2);
          manager.updateDrag(0);
          manager.updateDrag(2);
          manager.endDrag();

          expect(manager.selectedIndexes, {2});
        },
      );

      test(
        "Given that all indexes from 2 to 0 were selected by dragging, "
        "when dragging back to the index 4, "
        "then the indexes 0 and 1 get UNSELECTED, "
        "and the index 2 stills selected, "
        "and the indexes 3 and 4 get selected.",
        () {
          final manager = SelectionManager();

          manager.startDrag(2);
          manager.updateDrag(1);
          manager.updateDrag(0);

          manager.updateDrag(1);
          manager.updateDrag(2);
          manager.updateDrag(3);
          manager.updateDrag(4);
          manager.endDrag();

          expect(manager.selectedIndexes, {2, 3, 4});
        },
      );

      test(
        "Given that all indexes from 0 to 2 were selected by dragging, "
        "and that all indexes from 2 to 4 were selected by dragging back, "
        "when dragging to the index 2, "
        "then the indexes 4 and 3 get UNSELECTED, "
        "and the index 2 stills selected.",
        () {
          final manager = SelectionManager();

          manager.startDrag(2);
          manager.updateDrag(1);
          manager.updateDrag(0);

          manager.updateDrag(1);
          manager.updateDrag(2);
          manager.updateDrag(3);
          manager.updateDrag(4);

          manager.updateDrag(3);
          manager.updateDrag(2);
          manager.endDrag();

          expect(manager.selectedIndexes, {2});
        },
      );

      test(
        "Given that all indexes from 2 to 0 were selected by dragging, "
        "when directly dragging back to the index 4, "
        "then the indexes 0 and 1 get UNSELECTED, "
        "and the index 2 stills selected, "
        "and the indexes 3 and 4 get selected.",
        () {
          final manager = SelectionManager();

          manager.startDrag(2);
          manager.updateDrag(0);
          manager.updateDrag(4);
          manager.endDrag();

          expect(manager.selectedIndexes, {2, 3, 4});
        },
      );

      test(
        "Given that all indexes from 0 to 2 were selected by dragging, "
        "and that all indexes from 2 to 4 were selected by dragging back, "
        "when directly dragging to the index 2, "
        "then the indexes 4 and 3 get UNSELECTED, "
        "and the index 2 stills selected.",
        () {
          final manager = SelectionManager();

          manager.startDrag(2);
          manager.updateDrag(0);
          manager.updateDrag(4);
          manager.updateDrag(2);
          manager.endDrag();

          expect(manager.selectedIndexes, {2});
        },
      );

      test(
        "Given that the indexes 0 and 1 were selected by dragging, "
        "which stills activated, "
        "when clearing the selection, "
        "then all indexes get UNSELECTED, "
        "and the drag is interrupted.",
        () {
          final manager = SelectionManager();

          manager.startDrag(0);
          manager.updateDrag(1);
          manager.clear();

          expect(manager.selectedIndexes, <int>{});
          expect(manager.dragStartIndex, -1);
          expect(manager.dragEndIndex, -1);
        },
      );

      test(
        "Given that the indexes 0 and 1 were selected by dragging, "
        "which stills activated, "
        "when directly selecting indexes 2 and 3, "
        "then all indexes get UNSELECTED, "
        "then the indexes 2 and 3 get selected, "
        "and the drag is interrupted.",
        () {
          final manager = SelectionManager();

          manager.startDrag(0);
          manager.updateDrag(1);
          manager.selectedIndexes = {2, 3};

          expect(manager.selectedIndexes, {2, 3});
          expect(manager.dragStartIndex, -1);
          expect(manager.dragEndIndex, -1);
        },
      );
    });

    test(
      "When trying to drag by the index 0 without starting drag, "
      "then index 0 stills unselected.",
      () {
        final manager = SelectionManager();

        manager.updateDrag(0);
        expect(manager.selectedIndexes, <int>{});
      },
    );

    test(
      "When trying to drag by a negative index, "
      "then the negative index stills unselected.",
      () {
        final manager = SelectionManager();

        manager.startDrag(0);
        manager.updateDrag(-1);
        expect(manager.selectedIndexes, {0});
      },
    );
  });

  group("`Selection` tests", () {
    test(
      "When an `Selection` is created with null `selectedIndexes`, "
      "then an `AssertionError` is thrown.",
      () {
        expect(
          () => Selection(null),
          throwsAssertionError,
        );
      },
    );

    test("`Selection.empty` has empty `selectedIndexes`.", () {
      expect(Selection.empty.selectedIndexes, <int>{});
    });

    test(
      "When an `Selection` has an empty `selectedIndexes`, "
      "then `isSelecting` is false.",
      () {
        expect(
          Selection.empty.isSelecting,
          isFalse,
        );
      },
    );

    test(
      "When an `Selection` has a non-empty `selectedIndexes`, "
      "then `isSelecting` is true.",
      () {
        expect(
          Selection({0, 1}).isSelecting,
          isTrue,
        );
      },
    );

    test("`toString()`.", () {
      expect(
        Selection.empty.toString(),
        isNot("Instance of 'Selection'"),
      );
    });

    group("`operator ==` and `hashCode`.", () {
      final selection = Selection({0, 1, 2});
      final equalSelection = Selection({0, 1, 2});
      final anotherEqualSelection = Selection({0, 1, 2});
      const differentSelection = Selection.empty;

      test('Reflexivity.', () {
        expect(selection, selection);
        expect(selection.hashCode, selection.hashCode);
      });

      test('Symmetry.', () {
        expect(selection, isNot(differentSelection));
        expect(differentSelection, isNot(selection));
      });

      test('Transitivity.', () {
        expect(selection, equalSelection);
        expect(equalSelection, anotherEqualSelection);
        expect(selection, anotherEqualSelection);
        expect(selection.hashCode, equalSelection.hashCode);
        expect(equalSelection.hashCode, anotherEqualSelection.hashCode);
        expect(selection.hashCode, anotherEqualSelection.hashCode);
      });
    });
  });
}
