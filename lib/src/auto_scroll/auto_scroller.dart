import 'dart:async';

import 'package:flutter/widgets.dart';

import 'auto_scroll.dart';

@immutable
class AutoScroller {
  static const overscrollDuration = const Duration(milliseconds: 300);
  static const amountOfOverscrollOnScrollStop = 100;
  static const minimumScrollDurationPerPixelInMs = 2;

  static bool _isScrollControllerAttached(ScrollController controller) {
    try {
      controller.position;
      return true;
    } on AssertionError {
      return false;
    }
  }

  AutoScroller(this.autoScroll, this.controller)
      : currentPosition = _isScrollControllerAttached(controller)
            ? controller.offset
            : null;

  final AutoScroll autoScroll;
  final ScrollController controller;
  final double currentPosition;

  /// Returns whether auto-scroll must be performed.
  bool get mustScroll =>
      !autoScroll.stopEvent.isConsumed || autoScroll.isScrolling;

  /// Returns the position in which the [controller] would be after performing
  /// an overscroll.
  @visibleForTesting
  double get positionAfterOverscroll =>
      autoScroll.direction == AutoScrollDirection.down
          ? currentPosition + amountOfOverscrollOnScrollStop
          : currentPosition - amountOfOverscrollOnScrollStop;

  /// Returns the target position of the auto-scroll.
  ///
  /// If the auto-scroll direction is down, we want to get the last position.
  /// If the auto-scroll direction is up, we want to get the first position.
  @visibleForTesting
  double get targetPositionOfTheAutoScroll =>
      autoScroll.direction == AutoScrollDirection.down
          ? controller.position.maxScrollExtent
          : 0;

  /// Returns whether it is able to perform auto-scroll.
  ///
  /// Rarely returns `false` (only when [ScrollController] has never been
  /// attached or the direction of auto-scroll in `null`).
  ///
  /// Errors are guaranteed to be thrown when trying to perform auto-scroll when
  /// this method returns `false`.
  @visibleForTesting
  bool get isAbleToScroll =>
      currentPosition != null && autoScroll.direction != null;

  /// Returns whether there's anything to scroll.
  ///
  /// In case of [AutoScrollDirection.down], we want to know whether we didn't
  /// reach the end of the [GridView].
  /// In case of [AutoScrollDirection.up], we want to know whether we didn't
  /// reach the top of the [GridView].
  @visibleForTesting
  bool get hasAnythingLeftToScroll =>
      ((autoScroll.direction == AutoScrollDirection.down) &&
          (currentPosition < controller.position.maxScrollExtent)) ||
      ((autoScroll.direction == AutoScrollDirection.up) &&
          (currentPosition > 0));

  Future<void> scroll() async {
    if (!isAbleToScroll) return;
    if (!hasAnythingLeftToScroll) return;

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
  /// period, then stops.
  ///
  /// The amount of overscroll is defined by [amountOfOverscrollOnScrollStop].
  @visibleForTesting
  Future<void> performOverscrollOfScrollStop() {
    return controller.animateTo(
      positionAfterOverscroll,
      duration: overscrollDuration,
      curve: Curves.easeOut,
    );
  }

  @visibleForTesting
  Future<void> performScroll() {
    return controller.animateTo(
      targetPositionOfTheAutoScroll,
      curve: Curves.linear,
      duration: calculateScrollDurationWithUniformScrollSpeed(
        targetPositionOfTheAutoScroll,
      ),
    );
  }

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
  @visibleForTesting
  Duration calculateScrollDurationWithUniformScrollSpeed(
    double targetPosition,
  ) {
    final amountToBeScrolled = (targetPosition - currentPosition).abs();

    final scrollDurationInMs =
        (amountToBeScrolled * minimumScrollDurationPerPixelInMs).toInt();

    return Duration(milliseconds: scrollDurationInMs);
  }
}
