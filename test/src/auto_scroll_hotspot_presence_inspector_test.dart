import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:drag_select_grid_view/src/auto_scroll_hotspot_presence_inspector.dart';
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

  DragSelectGridViewState dragSelectState;

  Widget createWidget() {
    return MaterialApp(
      home: DragSelectGridView(
        grid: GridView.extent(
          maxCrossAxisExtent: 1,
          children: [],
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
    Widget widget = createWidget();
    await tester.pumpWidget(widget);

    Finder dragSelectFinder = find.byType(DragSelectGridView);
    dragSelectState = tester.state(dragSelectFinder);
  }

  testWidgets(
    'AutoScrollHotspotPresenceInspector inside to upper hotspot.',
    (WidgetTester tester) async {
      await setUp(tester);

      final inspector = AutoScrollHotspotPresenceInspector(
        dragSelectState,
        Offset(distanceFromLeft + 1, distanceFromTop + 1),
      );

      expect(inspector.isInsideUpperAutoScrollHotspot(), isTrue);
      expect(inspector.isInsideLowerAutoScrollHotspot(), isFalse);
    },
  );

  testWidgets(
    'AutoScrollHotspotPresenceInspector inside to lower hotspot.',
    (WidgetTester tester) async {
      await setUp(tester);

      final inspector = AutoScrollHotspotPresenceInspector(
        dragSelectState,
        Offset(distanceFromLeft + 1, distanceFromTop + widgetHeight),
      );

      expect(inspector.isInsideUpperAutoScrollHotspot(), isFalse);
      expect(inspector.isInsideLowerAutoScrollHotspot(), isTrue);
    },
  );

  testWidgets(
    'AutoScrollHotspotPresenceInspector above hotspots.',
    (WidgetTester tester) async {
      await setUp(tester);

      final inspector = AutoScrollHotspotPresenceInspector(
        dragSelectState,
        Offset(distanceFromLeft + 1, 0),
      );

      expect(inspector.isInsideUpperAutoScrollHotspot(), isFalse);
      expect(inspector.isInsideLowerAutoScrollHotspot(), isFalse);
    },
  );

  testWidgets(
    'AutoScrollHotspotPresenceInspector below hotspots.',
    (WidgetTester tester) async {
      await setUp(tester);

      final inspector = AutoScrollHotspotPresenceInspector(
        dragSelectState,
        Offset(distanceFromLeft + 1, distanceFromTop + widgetHeight + 1),
      );

      expect(inspector.isInsideUpperAutoScrollHotspot(), isFalse);
      expect(inspector.isInsideLowerAutoScrollHotspot(), isFalse);
    },
  );

  testWidgets(
    'AutoScrollHotspotPresenceInspector at the left of hotspots.',
    (WidgetTester tester) async {
      await setUp(tester);

      final inspector = AutoScrollHotspotPresenceInspector(
        dragSelectState,
        Offset(0, distanceFromTop + 1),
      );

      expect(inspector.isInsideUpperAutoScrollHotspot(), isFalse);
      expect(inspector.isInsideLowerAutoScrollHotspot(), isFalse);
    },
  );

  testWidgets(
    'AutoScrollHotspotPresenceInspector at the right of hotspots.',
    (WidgetTester tester) async {
      await setUp(tester);

      final inspector = AutoScrollHotspotPresenceInspector(
        dragSelectState,
        Offset(
            distanceFromLeft + widgetWidth + 1, distanceFromTop + widgetHeight),
      );

      expect(inspector.isInsideUpperAutoScrollHotspot(), isFalse);
      expect(inspector.isInsideLowerAutoScrollHotspot(), isFalse);
    },
  );
}
