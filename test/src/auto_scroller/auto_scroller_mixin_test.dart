import 'package:drag_select_grid_view/src/auto_scroller/auto_scroll.dart';
import 'package:drag_select_grid_view/src/auto_scroller/auto_scroller_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final dragSelectGridViewFinder = find.byType(DragSelectGridViewTest);

  Widget createWidget() {
    return MaterialApp(
      home: DragSelectGridViewTest(
        grid: GridView.extent(
          maxCrossAxisExtent: 1,
          children: [],
          controller: ScrollController(),
        ),
      ),
    );
  }

  testWidgets(
    "Auto-scroll direction is updated "
    "when `DragSelectGridView` starts to scroll up, "
    "but auto-scroll doesn't change "
    "when trying to scroll up again.",
    (WidgetTester tester) async {
      final widget = createWidget();
      await tester.pumpWidget(widget);

      expect(dragSelectGridViewFinder, findsOneWidget);

      final dragSelectGridViewState =
          tester.state(dragSelectGridViewFinder) as DragSelectGridViewTestState;

      // First scroll up attempt.

      expect(dragSelectGridViewState.autoScroll.isScrolling, isFalse);
      expect(dragSelectGridViewState.autoScroll.direction, null);

      dragSelectGridViewState.startAutoScrollingUp();

      expect(dragSelectGridViewState.autoScroll.isScrolling, isTrue);
      expect(
        dragSelectGridViewState.autoScroll.direction,
        AutoScrollDirection.up,
      );

      // Second scroll up attempt.

      final oldAutoScroll = dragSelectGridViewState.autoScroll;

      dragSelectGridViewState.startAutoScrollingUp();

      expect(
        identical(oldAutoScroll, dragSelectGridViewState.autoScroll),
        isTrue,
      );
    },
  );

  testWidgets(
    "Auto-scroll direction is updated "
    "when `DragSelectGridView` starts to scroll down, "
    "but auto-scroll doesn't change "
    "when trying to scroll down again.",
    (WidgetTester tester) async {
      final widget = createWidget();
      await tester.pumpWidget(widget);

      expect(dragSelectGridViewFinder, findsOneWidget);

      final dragSelectGridViewState =
          tester.state(dragSelectGridViewFinder) as DragSelectGridViewTestState;

      // First scroll down attempt.

      expect(dragSelectGridViewState.autoScroll.isScrolling, isFalse);
      expect(dragSelectGridViewState.autoScroll.direction, null);

      dragSelectGridViewState.startAutoScrollingDown();

      expect(dragSelectGridViewState.autoScroll.isScrolling, isTrue);
      expect(
        dragSelectGridViewState.autoScroll.direction,
        AutoScrollDirection.down,
      );

      // Second scroll down attempt.

      final oldAutoScroll = dragSelectGridViewState.autoScroll;

      dragSelectGridViewState.startAutoScrollingDown();

      expect(
        identical(oldAutoScroll, dragSelectGridViewState.autoScroll),
        isTrue,
      );
    },
  );

  testWidgets(
    "Auto-scroll is updated "
    "when stop scrolling, "
    "but auto-scroll doesn't change "
    "when trying to stop scrolling again.",
    (WidgetTester tester) async {
      final widget = createWidget();
      await tester.pumpWidget(widget);

      expect(dragSelectGridViewFinder, findsOneWidget);

      final dragSelectGridViewState =
          tester.state(dragSelectGridViewFinder) as DragSelectGridViewTestState;

      dragSelectGridViewState.startAutoScrollingDown();

      // First stop attempt.

      expect(dragSelectGridViewState.autoScroll.isScrolling, isTrue);
      expect(
        dragSelectGridViewState.autoScroll.direction,
        AutoScrollDirection.down,
      );

      dragSelectGridViewState.stopScrolling();

      expect(dragSelectGridViewState.autoScroll.isScrolling, isFalse);
      expect(
        dragSelectGridViewState.autoScroll.direction,
        AutoScrollDirection.down,
      );

      // Second stop attempt.

      final oldAutoScroll = dragSelectGridViewState.autoScroll;

      dragSelectGridViewState.stopScrolling();

      expect(
        identical(oldAutoScroll, dragSelectGridViewState.autoScroll),
        isTrue,
      );
    },
  );
}

class DragSelectGridViewTest extends StatefulWidget {
  final GridView grid;

  DragSelectGridViewTest({
    @required this.grid,
  })  : assert(grid != null),
        assert(grid.gridDelegate is SliverGridDelegateWithMaxCrossAxisExtent);

  @override
  DragSelectGridViewTestState createState() => DragSelectGridViewTestState();
}

class DragSelectGridViewTestState extends State<DragSelectGridViewTest>
    with AutoScrollerMixin<DragSelectGridViewTest> {
  GridView get grid => widget.grid;

  @override
  ScrollController get controller => grid.controller;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return grid;
  }
}
