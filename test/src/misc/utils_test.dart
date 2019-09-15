import 'package:drag_select_grid_view/src/misc/utils.dart';
import 'package:test/test.dart';

void main() {
  group("intListFromRange().", () {
    test("Equal `start` and `end`.", () {
      expect(intListFromRange(1, 1), [1]);
    });

    test("`end` greater than `start`.", () {
      expect(intListFromRange(1, 3), [1, 2, 3]);
    });

    test("`start` greater than `end`.", () {
      expect(intListFromRange(3, 1), [1, 2, 3]);
    });
  });
}
