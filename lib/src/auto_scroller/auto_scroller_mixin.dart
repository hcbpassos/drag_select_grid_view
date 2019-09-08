import 'package:flutter/widgets.dart';

import 'auto_scroll.dart';
import 'auto_scroller.dart';

mixin AutoScrollerMixin<T extends StatefulWidget> on State<T> {
  @visibleForTesting
  AutoScroll autoScroll = AutoScroll.stopped();

  ScrollController get controller;

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    final scroller = AutoScroller(autoScroll, controller);
    if (scroller.mustScroll) scroller.scroll();
    return null;
  }

  void startAutoScrollingUp() {
    _updateAutoScrollIfDifferent(
      AutoScroll(
        direction: AutoScrollDirection.up,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void startAutoScrollingDown() {
    _updateAutoScrollIfDifferent(
      AutoScroll(
        direction: AutoScrollDirection.down,
        duration: const Duration(seconds: 3),
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
