import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:drag_select_grid_view/src/spacing_details/spacing_details.dart';
import 'package:drag_select_grid_view/src/spacing_details/spacing_details_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_utils.dart';

/// Tests for both [SpacingDetails] and [SpacingDetailsMixin].
void main() {
  const distanceFromTop = 50.0;
  const distanceFromLeft = 20.0;
  const distanceFromRight = 40.0;
  const distanceFromBottom = 100.0;

  final dragSelectGridViewFinder = find.byType(DragSelectGridView);

  Widget createWidget() {
    return MaterialApp(
      home: Column(
        children: [
          SizedBox(height: distanceFromTop),
          Expanded(
            child: Row(
              children: [
                SizedBox(width: distanceFromLeft),
                Expanded(
                  child: DragSelectGridView(
                    itemCount: 0,
                    itemBuilder: (_, __, ___) => SizedBox(),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 1,
                    ),
                  ),
                ),
                SizedBox(width: distanceFromRight),
              ],
            ),
          ),
          SizedBox(height: distanceFromBottom),
        ],
      ),
    );
  }

  testWidgets(
    'An `AssertionError` is thrown '
    'when creating `SpacingDetails` with null `widgetKey`.',
    (WidgetTester tester) async {
      expect(
        () => SpacingDetails.calculateWith(
          widgetKey: null,
          context: StatelessElement(Container()),
        ),
        throwsAssertionError,
      );
    },
  );

  testWidgets(
    'An `AssertionError` is thrown '
    'when creating `SpacingDetails` with null `context`.',
    (WidgetTester tester) async {
      expect(
        () => SpacingDetails.calculateWith(
          widgetKey: GlobalKey(),
          context: null,
        ),
        throwsAssertionError,
      );
    },
  );

  testWidgets(
    'The correct height and width are calculated.',
    (WidgetTester tester) async {
      final widget = createWidget();
      await tester.pumpWidget(widget);

      final dragSelectGridViewState =
          tester.state(dragSelectGridViewFinder) as DragSelectGridViewState;

      expect(
        dragSelectGridViewState.height,
        screenHeight - (distanceFromTop + distanceFromBottom),
      );

      expect(
        dragSelectGridViewState.width,
        screenWidth - (distanceFromLeft + distanceFromRight),
      );
    },
  );

  testWidgets(
    'The correct distances from top, left, right and bottom are calculated.',
    (WidgetTester tester) async {
      final widget = createWidget();
      await tester.pumpWidget(widget);

      final dragSelectGridViewState =
          tester.state(dragSelectGridViewFinder) as DragSelectGridViewState;

      expect(dragSelectGridViewState.distanceFromTop, distanceFromTop);
      expect(dragSelectGridViewState.distanceFromLeft, distanceFromLeft);
      expect(dragSelectGridViewState.distanceFromRight, distanceFromRight);
      expect(dragSelectGridViewState.distanceFromBottom, distanceFromBottom);
    },
  );
}
