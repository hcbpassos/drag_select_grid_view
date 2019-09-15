import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:test/test.dart';
import 'package:flutter_test/flutter_test.dart' show throwsAssertionError;

void main() {
  test(
    "When an `Selection` is created with null `selectedIndexes`, "
    "then an `AssertionError` is throw.",
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
    "When an `Selection` has empty `selectedIndexes`, "
    "then `isSelecting` is false.",
    () {
      expect(
        Selection.empty.isSelecting,
        isFalse,
      );
    },
  );

  test(
    "When an `Selection` has filled `selectedIndexes`, "
    "then `isSelecting` is true.",
    () {
      expect(
        Selection({0, 1}).isSelecting,
        isTrue,
      );
    },
  );

  test("toString().", () {
    expect(
      Selection.empty.toString(),
      isNot("Instance of 'Selection'"),
    );
  });

  test("`operator ==` and `hashCode`.", () {
    final selection = Selection({0, 1, 2});
    final equalSelection = Selection({0, 1, 2});
    final anotherEqualSelection = Selection({0, 1, 2});
    final differentSelection = Selection.empty;

    // Reflexivity
    expect(selection, selection);
    expect(selection.hashCode, selection.hashCode);

    // Symmetry
    expect(selection, isNot(differentSelection));
    expect(differentSelection, isNot(selection));

    // Transitivity
    expect(selection, equalSelection);
    expect(equalSelection, anotherEqualSelection);
    expect(selection, anotherEqualSelection);
    expect(selection.hashCode, equalSelection.hashCode);
    expect(equalSelection.hashCode, anotherEqualSelection.hashCode);
    expect(selection.hashCode, anotherEqualSelection.hashCode);
  });
}
