import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:drag_select_grid_view/src/auto_scroll_hotspot_presence_inspector/auto_scroll_hotspot_presence_inspector.dart';
import 'package:drag_select_grid_view/src/spacing_details/spacing_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const distanceFromTop = 80.0;
  const distanceFromLeft = 20.0;
  const distanceFromRight = 40.0;
  const distanceFromBottom = 60.0;
  const widgetHeight = 600.0;
  const widgetWidth = 800.0;

  final dragSelectFinder = find.byType(DragSelectGridView);

  DragSelectGridViewState dragSelectState;

  Widget createWidget() {
    return MaterialApp(
      home: DragSelectGridView(
        itemCount: 0,
        itemBuilder: (_, __, ___) => SizedBox(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
      ),
    );
  }

  setUpAll(() {
    SpacingDetails.mockAttributes(
      distanceFromTop: distanceFromTop,
      distanceFromLeft: distanceFromLeft,
      distanceFromRight: distanceFromRight,
      distanceFromBottom: distanceFromBottom,
      height: widgetHeight,
      width: widgetWidth,
    );
  });

  /// Notice that this is not a call to the the native [setUp] function.
  /// I could not use it because I need [WidgetTester] as a parameter to avoid
  /// creating the widget at every single [testWidgets].
  /// I get access to [WidgetTester], but in counterpart I have to call [setUp]
  /// manually at the initialization of every [testWidgets].
  /// Actually, this could be a [setUpAll], since I'm not interested in
  /// modifying the Widget once created in this test file. However, since I'd
  /// still have to call this method in a [testWidgets] function, it would be
  /// really weird having a [setUpAll] called in only one [testWidgets], apart
  /// from the fact that the tests are not going to work if I change their
  /// order.
  Future<void> setUp(WidgetTester tester) async {
    final widget = createWidget();
    await tester.pumpWidget(widget);
    dragSelectState = tester.state(dragSelectFinder);
  }

  testWidgets(
    "When an `AutoScrollHotspotPresenceInspector` is created "
    "with null `dragSelectState`, "
    "then an `AssertionError` is thrown.",
    (WidgetTester tester) async {
      expect(
        () => AutoScrollHotspotPresenceInspector(null, Offset(0, 0)),
        throwsAssertionError,
      );
    },
  );

  testWidgets(
    "When an `AutoScrollHotspotPresenceInspector` is created "
    "with null `position`, "
    "then an `AssertionError` is thrown.",
    (WidgetTester tester) async {
      expect(
        () => AutoScrollHotspotPresenceInspector(
          DragSelectGridViewState(),
          null,
        ),
        throwsAssertionError,
      );
    },
  );

  testWidgets(
    "When the pointer gets inside the UPPER hotspot, "
    "then `AutoScrollHotspotPresenceInspector` detects it.",
    (WidgetTester tester) async {
      await setUp(tester);

      final presenceInspector = AutoScrollHotspotPresenceInspector(
        dragSelectState,
        Offset(distanceFromLeft + 1, distanceFromTop + 1),
      );

      expect(presenceInspector.isInsideUpperAutoScrollHotspot, isTrue);
      expect(presenceInspector.isInsideLowerAutoScrollHotspot, isFalse);
    },
  );

  testWidgets(
    "When the pointer gets inside the LOWER hotspot, "
    "then `AutoScrollHotspotPresenceInspector` detects it.",
    (WidgetTester tester) async {
      await setUp(tester);

      final presenceInspector = AutoScrollHotspotPresenceInspector(
        dragSelectState,
        Offset(distanceFromLeft + 1, distanceFromTop + widgetHeight),
      );

      expect(presenceInspector.isInsideUpperAutoScrollHotspot, isFalse);
      expect(presenceInspector.isInsideLowerAutoScrollHotspot, isTrue);
    },
  );

  testWidgets(
    "When the pointer gets ABOVE both hotspots, "
    "then `AutoScrollHotspotPresenceInspector` doesn't detect any pointer.",
    (WidgetTester tester) async {
      await setUp(tester);

      final presenceInspector = AutoScrollHotspotPresenceInspector(
        dragSelectState,
        Offset(distanceFromLeft + 1, 0),
      );

      expect(presenceInspector.isInsideUpperAutoScrollHotspot, isFalse);
      expect(presenceInspector.isInsideLowerAutoScrollHotspot, isFalse);
    },
  );

  testWidgets(
    "When the pointer gets BELOW both hotspots, "
    "then `AutoScrollHotspotPresenceInspector` doesn't detect any pointer.",
    (WidgetTester tester) async {
      await setUp(tester);

      final presenceInspector = AutoScrollHotspotPresenceInspector(
        dragSelectState,
        Offset(distanceFromLeft + 1, distanceFromTop + widgetHeight + 1),
      );

      expect(presenceInspector.isInsideUpperAutoScrollHotspot, isFalse);
      expect(presenceInspector.isInsideLowerAutoScrollHotspot, isFalse);
    },
  );

  testWidgets(
    "When the pointer gets to the left side of both hotspots, "
    "then `AutoScrollHotspotPresenceInspector` doesn't detect any pointer.",
    (WidgetTester tester) async {
      await setUp(tester);

      final presenceInspector = AutoScrollHotspotPresenceInspector(
        dragSelectState,
        Offset(0, distanceFromTop + 1),
      );

      expect(presenceInspector.isInsideUpperAutoScrollHotspot, isFalse);
      expect(presenceInspector.isInsideLowerAutoScrollHotspot, isFalse);
    },
  );

  testWidgets(
    "When the pointer gets to the right side of both hotspots, "
    "then `AutoScrollHotspotPresenceInspector` doesn't detect any pointer.",
    (WidgetTester tester) async {
      await setUp(tester);

      final presenceInspector = AutoScrollHotspotPresenceInspector(
        dragSelectState,
        Offset(
          distanceFromLeft + widgetWidth + 1,
          distanceFromTop + widgetHeight,
        ),
      );

      expect(presenceInspector.isInsideUpperAutoScrollHotspot, isFalse);
      expect(presenceInspector.isInsideLowerAutoScrollHotspot, isFalse);
    },
  );
}
