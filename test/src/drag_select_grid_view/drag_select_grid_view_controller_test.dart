import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:drag_select_grid_view/src/drag_select_grid_view/selection.dart';
import 'package:test/test.dart';
import 'package:flutter_test/flutter_test.dart' show throwsAssertionError;

void main() {
  test(
    "When setting a new selection, "
    "then those who are listening get notified about the new selection.",
    () {
      var selectionChangeCount = 0;

      final controller = DragSelectGridViewController()
        ..addListener(() => selectionChangeCount++);

      controller.selection = Selection({0});
      expect(selectionChangeCount, 1);
    },
  );

  test(
    "When clearing the selection, "
    "then those who are listening get notified about the new selection.",
    () {
      var selectionChangeCount = 0;

      final controller = DragSelectGridViewController()
        ..addListener(() => selectionChangeCount++);

      controller.clear();
      expect(selectionChangeCount, 1);
    },
  );
}
