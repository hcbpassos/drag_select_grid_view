import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:drag_select_grid_view/src/drag_select_grid_view/selection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("No initial selection specified.", () {
    expect(DragSelectGridViewController().value, const Selection.empty());
  });

  test("Specified initial selection.", () {
    expect(
      DragSelectGridViewController(Selection({42})).value,
      Selection({42}),
    );
  });

  test("Clears the grid selection.", () {
    final controller = DragSelectGridViewController(Selection({42}))..clear();
    expect(controller.value, const Selection.empty());
  });
}
