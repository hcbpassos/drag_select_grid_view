import 'package:flutter/widgets.dart';

import 'auto_scroll.dart';
import 'auto_scroller.dart';

mixin AutoScrollerMixin<T extends StatefulWidget> on State<T> {
  @visibleForTesting
  AutoScroll autoScroll = AutoScroll.stopped();
  double _widgetHeight;
  double _widgetWidth;

  double get autoScrollHotspotHeight;

  ScrollController get controller;

  @override
  @mustCallSuper
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final widgetSize = context.size;
        _widgetHeight = widgetSize.height;
        _widgetWidth = widgetSize.width;
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
      _isInsideWidget(localPosition) &&
      localPosition.dy <= autoScrollHotspotHeight;

  bool isInsideLowerAutoScrollHotspot(Offset localPosition) =>
      _isInsideWidget(localPosition) &&
      localPosition.dy > (_widgetHeight - autoScrollHotspotHeight);

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

  bool _isInsideWidget(Offset localPosition) =>
      (localPosition.dy >= 0) &&
          (_widgetHeight - localPosition.dy >= 0) &&
          (localPosition.dx >= 0) &&
          (_widgetWidth - localPosition.dx >= 0);

  void _updateAutoScrollIfDifferent(AutoScroll newAutoScroll) {
    if (newAutoScroll != autoScroll) {
      setState(() => autoScroll = newAutoScroll);
    }
  }
}
