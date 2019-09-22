import 'package:flutter/widgets.dart';

import 'auto_scroll.dart';
import 'auto_scroller.dart';

mixin AutoScrollerMixin<T extends StatefulWidget> on State<T> {
  @visibleForTesting
  AutoScroll autoScroll = AutoScroll.stopped();

  @visibleForTesting
  double widgetHeight;

  double get autoScrollHotspotHeight;

  ScrollController get controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final widgetSize = context.size;
        widgetHeight = widgetSize.height;
      },
    );
  }

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    final scroller = AutoScroller(autoScroll, controller);
    if (scroller.mustScroll) scroller.scroll();
    return null;
  }

  bool isInsideUpperAutoScrollHotspot(Offset localPosition) =>
      localPosition.dy <= autoScrollHotspotHeight;

  bool isInsideLowerAutoScrollHotspot(Offset localPosition) =>
      localPosition.dy > (widgetHeight - autoScrollHotspotHeight);

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
