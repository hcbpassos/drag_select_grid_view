import 'dart:async';

import 'package:drag_select_grid_view/auto_scroller/auto_scroll.dart';
import 'package:drag_select_grid_view/auto_scroller/auto_scroller.dart';
import 'package:flutter/widgets.dart';

mixin AutoScrollerMixin<T extends StatefulWidget> on State<T> {
  AutoScroll _autoScroll = AutoScroll.stopped();

  ScrollController get controller;

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    AutoScroller scroller = AutoScroller(_autoScroll, controller);
    if (scroller.mustPerformAutoScroll()) scroller.performAutoScroll();
    return null;
  }

  void startAutoScrollingUp() {
    _updateAutoScroll(
      AutoScroll(
        direction: AutoScrollDirection.up,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void startAutoScrollingDown() {
    _updateAutoScroll(
      AutoScroll(
        direction: AutoScrollDirection.down,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void stopScrolling() {
    if (!_autoScroll.isStopped) {
      _updateAutoScroll(
        AutoScroll.stopped(direction: _autoScroll.direction),
      );
    }
  }

  void _updateAutoScroll(AutoScroll newAutoScroll) {
    if (newAutoScroll != this._autoScroll) {
      setState(() => this._autoScroll = newAutoScroll);
    }
  }
}
