import 'package:flutter/widgets.dart';

import 'auto_scroll.dart';
import 'auto_scroller.dart';

/// Mixin that collects UI information and gives them to UI-agnostic classes
/// that handle auto-scrolling.
mixin AutoScrollerMixin<T extends StatefulWidget> on State<T> {
  /// The duration of the auto-scroll animation from the current position
  /// to the edge of the scroll view.
  static const autoScrollDuration = Duration(seconds: 3);

  /// Information about the direction and duration of the scroll.
  @visibleForTesting
  AutoScroll autoScroll = AutoScroll.stopped();

  /// The height of the auto-scroll hotspot.
  ///
  /// Used to check whether an offset is in hotspot's bounds.
  double get autoScrollHotspotHeight;

  /// The scroll direction of the grid's scroll-view.
  ///
  /// Used to determine the axis along which the auto-scroll hotspots are
  /// placed.
  Axis get scrollDirection;

  /// The controller of the grid's scroll-view.
  ///
  /// Used to perform the auto-scroll and notify about scrolling.
  ScrollController get scrollController;

  /// Handles changes on scroll-position.
  ///
  /// Used in the grid to update the selected items when auto-scrolling.
  ///
  /// Cannot return null.
  ///
  /// Introduced in:
  /// https://github.com/hcbpassos/drag_select_grid_view/issues/2
  void handleScroll();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (callback) {
        if (scrollController.hasClients) {
          scrollController.position.addListener(handleScroll);
        }
      },
    );
  }

  @override
  void dispose() {
    if (scrollController.hasClients) {
      scrollController.position.removeListener(handleScroll);
    }
    super.dispose();
  }

  /// Triggers the auto-scroll based on the current [autoScroll] state.
  ///
  /// Must be called at the start of the subclass's [build] method, since
  /// the auto-scroll animation may be interrupted by rebuilds caused by
  /// selection changes during scrolling.
  @protected
  void triggerAutoScrollIfNeeded() {
    final scroller = AutoScroller(autoScroll, scrollController);
    if (scroller.mustScroll) scroller.scroll();
  }

  /// Returns whether the [localPosition] is in start-hotspot's bounds.
  ///
  /// For vertical scrolling, this is the top hotspot.
  /// For horizontal scrolling, this is the left hotspot.
  bool isInsideStartAutoScrollHotspot(Offset localPosition) {
    return switch (scrollDirection) {
      Axis.vertical => localPosition.dy <= autoScrollHotspotHeight,
      Axis.horizontal => localPosition.dx <= autoScrollHotspotHeight,
    };
  }

  /// Returns whether the [localPosition] is in end-hotspot's bounds.
  ///
  /// For vertical scrolling, this is the bottom hotspot.
  /// For horizontal scrolling, this is the right hotspot.
  bool isInsideEndAutoScrollHotspot(Offset localPosition) {
    final widgetSize = context.size;
    if (widgetSize == null) return false;
    return switch (scrollDirection) {
      Axis.vertical =>
        localPosition.dy > (widgetSize.height - autoScrollHotspotHeight),
      Axis.horizontal =>
        localPosition.dx > (widgetSize.width - autoScrollHotspotHeight),
    };
  }

  /// Scrolls forward indefinitely.
  ///
  /// Nothing is done if forward auto-scroll is already being performed.
  void startAutoScrollingForward() {
    _updateAutoScrollIfDifferent(
      AutoScroll(
        direction: AutoScrollDirection.forward,
        duration: autoScrollDuration,
      ),
    );
  }

  /// Scrolls backward indefinitely.
  ///
  /// Nothing is done if backward auto-scroll is already being performed.
  void startAutoScrollingBackward() {
    _updateAutoScrollIfDifferent(
      AutoScroll(
        direction: AutoScrollDirection.backward,
        duration: autoScrollDuration,
      ),
    );
  }

  /// Stops scrolling smoothly.
  ///
  /// Nothing is done if no auto-scroll is being performed.
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
