import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:drag_select_grid_view/src/drag_select_grid_view/selection.dart';
import 'package:test/test.dart';
import 'package:flutter_test/flutter_test.dart' show throwsAssertionError;

void main() {
  test(
    "When setting a new selection, "
    "then those who are listening the stream get notified about the new selection.",
    () {
      final controller = DragSelectGridViewController();

      expect(
        controller.selectionChangeStream,
        emits(Selection({0})),
      );

      controller.setSelection(Selection({0}));
    },
  );

  test(
    "When disposing the controller, "
    "then new selections cannot be set",
    () {
      final controller = DragSelectGridViewController()..dispose();

      expect(
        ()  => controller.setSelection(Selection({0})),
        throwsStateError,
      );
    },
  );
}
