import 'package:drag_select_grid_view/auto_scroller/auto_scroll.dart';
import 'package:drag_select_grid_view/auto_scroller/auto_scroller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Auto-scroll is disabled with correct direction '
        'when pointer goes up from lower hotspot.',
    (WidgetTester tester) async {
      AutoScroller autoScroller = AutoScroller(
        AutoScroll.stopped(),
        ScrollController(),
      );


    },
  );
}
