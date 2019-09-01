import 'dart:async';

import 'package:drag_select_grid_view/src/auto_scroller/auto_scroll.dart';
import 'package:flutter/widgets.dart';

@immutable
class AutoScroller {
  static const minimumScrollDurationPerPixelInMs = 2;
  static const amountOfOverscrollOnScrollStop = 100;

  AutoScroller(this.autoScroll, this.controller)
      : currentPosition = _hasScrollControllerBeenAttached(controller)
      ? controller.offset
      : null;

  final AutoScroll autoScroll;
  final ScrollController controller;
  final double currentPosition;

  static bool _hasScrollControllerBeenAttached(ScrollController controller) {
    bool hasBeenAttached = true;

    try {
      controller.position;
    } on AssertionError {
      hasBeenAttached = false;
    }

    return hasBeenAttached;
  }

  bool mustScroll() =>
      !autoScroll.stopEvent.isConsumed || autoScroll.isScrolling;

  Future<void> scroll() async {
    if (!isAbleToScroll()) return;
    if (hasNothingLeftToScroll()) return;

    if (autoScroll.stopEvent.consume()) {
      await performOverscrollOfScrollStop();
    } else if (autoScroll.isScrolling) {
      await performScroll();
    }
  }

  /// Performs an elegant overscroll.
  ///
  /// This is supposed to run when the user leaves the auto-scroll-hotspot.
  /// Instead of suddenly stopping the auto-scroll, it continues for a short
  /// time, then stops.
  ///
  /// The amount of overscroll is defined by [amountOfOverscrollOnScrollStop].
  @visibleForTesting
  Future<void> performOverscrollOfScrollStop() {
    return controller.animateTo(
      _currentPositionIncrementOrDecrementDependingOnTheScrollDirection(),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  double _currentPositionIncrementOrDecrementDependingOnTheScrollDirection() =>
      autoScroll.direction == AutoScrollDirection.down
          ? currentPosition + amountOfOverscrollOnScrollStop
          : currentPosition - amountOfOverscrollOnScrollStop;

  @visibleForTesting
  Future<void> performScroll() {
    double targetPosition = _getMinOrMaxPositionDependingOnTheScrollDirection();

    return controller.animateTo(
      targetPosition,
      duration: _calculateScrollDurationWithUniformScrollSpeed(targetPosition),
      curve: Curves.linear,
    );
  }

  /// Gets the minimum or maximum position of the [ScrollController].
  ///
  /// In case of [AutoScrollDirection.down], we want to get the last position.
  /// In case of [AutoScrollDirection.up], we want to get the first position.
  double _getMinOrMaxPositionDependingOnTheScrollDirection() =>
      autoScroll.direction == AutoScrollDirection.down
          ? controller.position.maxScrollExtent
          : 0;

  /// Calculates an scroll duration that makes the scroll speed consistent.
  ///
  /// [ScrollController.animateTo] expects a position and a duration.
  /// Considering that the position varies and the duration is constant, the
  /// scroll speed is going to vary, since it has the same time to perform a
  /// scroll to longer and shorter distances.
  ///
  /// However, we don't want the scroll speed to change according to the current
  /// position or the size of the list.
  ///
  /// To solve this problem, the duration cannot be constant, so when the
  /// position changes, the duration is also going to change in order to make
  /// the scroll speed constant.
  Duration _calculateScrollDurationWithUniformScrollSpeed(
    double targetPosition,
  ) {
    double amountToBeScrolled = (targetPosition - currentPosition).abs();

    int scrollDurationInMs =
        (amountToBeScrolled * minimumScrollDurationPerPixelInMs).toInt();

    return Duration(milliseconds: scrollDurationInMs);
  }

  /// Checks whether it is able to perform auto-scroll.
  ///
  /// Rarely returns `false`, only when [ScrollController] has never been
  /// attached or the direction of auto-scroll in `null`.
  ///
  /// Errors are guaranteed to be thrown when trying to perform auto-scroll when
  /// this method returns `false`.
  @visibleForTesting
  bool isAbleToScroll() =>
      currentPosition != null && autoScroll.direction != null;

  /// Checks whether there's anything to scroll.
  ///
  /// In case of [AutoScrollDirection.down], we want to know whether we already
  /// are at the end of the [GridView].
  /// In case of [AutoScrollDirection.up], we want to know whether we already
  /// are at the top of the [GridView].
  @visibleForTesting
  bool hasNothingLeftToScroll() =>
      ((autoScroll.direction == AutoScrollDirection.down) &&
          (currentPosition == controller.position.maxScrollExtent)) ||
      ((autoScroll.direction == AutoScrollDirection.up) &&
          (currentPosition == 0));
}
