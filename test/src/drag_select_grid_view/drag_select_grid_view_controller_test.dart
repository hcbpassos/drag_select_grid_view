import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("No initial selection specified.", () {
    expect(DragSelectGridViewController().value, const Selection.empty());
  });

  test("Specified initial selection.", () {
    expect(
      DragSelectGridViewController(Selection(const {42})).value,
      Selection(const {42}),
    );
  });

  test("Clears the grid selection.", () {
    final controller = DragSelectGridViewController(Selection(const {42}))..clear();
    expect(controller.value, const Selection.empty());
  });
}
