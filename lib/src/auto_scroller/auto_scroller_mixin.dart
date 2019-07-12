import 'package:drag_select_grid_view/src/auto_scroller/auto_scroll.dart';
import 'package:drag_select_grid_view/src/auto_scroller/auto_scroller.dart';
import 'package:flutter/widgets.dart';

mixin AutoScrollerMixin<T extends StatefulWidget> on State<T> {
  @visibleForTesting
  AutoScroll autoScroll = AutoScroll.stopped();

  ScrollController get controller;

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    AutoScroller scroller = AutoScroller(autoScroll, controller);
    if (scroller.mustPerformAutoScroll()) scroller.performAutoScroll();
    return null;
  }

  void startAutoScrollingUp() {
    _updateAutoScrollIfDifferent(
      AutoScroll(
        direction: AutoScrollDirection.up,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void startAutoScrollingDown() {
    _updateAutoScrollIfDifferent(
      AutoScroll(
        direction: AutoScrollDirection.down,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void stopScrolling() {
    if (autoScroll.isScrolling) {
      _updateAutoScrollIfDifferent(
        AutoScroll.stopped(direction: autoScroll.direction),
      );
    }
  }

  void _updateAutoScrollIfDifferent(AutoScroll newAutoScroll) {
    if (newAutoScroll != autoScroll) {
      setState(() => autoScroll = newAutoScroll);
    }
  }
}
