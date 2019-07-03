import 'dart:async';

import 'package:drag_select_grid_view/src/auto_scroller/auto_scroll.dart';
import 'package:flutter/widgets.dart';

class AutoScroller {
  static const minimumScrollDurationPerPixelInMs = 2;
  static const amountOfOverscrollOnScrollStop = 100;

  final AutoScroll autoScroll;
  final ScrollController controller;
  final double _currentPosition;

  AutoScroller(this.autoScroll, this.controller)
      : _currentPosition = _hasScrollControllerBeenAttached(controller)
            ? controller.offset
            : null;

  static bool _hasScrollControllerBeenAttached(ScrollController controller) {
    bool hasBeenAttached = true;

    try {
      controller.position;
    } on AssertionError {
      hasBeenAttached = false;
    }

    return hasBeenAttached;
  }

  bool mustPerformAutoScroll() =>
      !autoScroll.stopEvent.isConsumed || !autoScroll.isStopped;

  Future<void> performAutoScroll() async {
    if (!isAbleToPerformAutoScroll()) return;
    if (hasNothingLeftToScroll()) return;

    if (autoScroll.stopEvent.consume()) {
      await _performScrollStopOverscroll();
    } else if (!autoScroll.isStopped) {
      await _performAutoScroll();
    }
  }

  Future<void> _performScrollStopOverscroll() {
    double targetPosition =
        _currentPositionIncrementOrDecrementDependingOnTheScrollDirection();

    return controller.animateTo(
      targetPosition,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  double _currentPositionIncrementOrDecrementDependingOnTheScrollDirection() =>
      autoScroll.direction == AutoScrollDirection.down
          ? _currentPosition + amountOfOverscrollOnScrollStop
          : _currentPosition - amountOfOverscrollOnScrollStop;

  Future<void> _performAutoScroll() {
    double targetPosition = _getMinOrMaxPositionDependingOnTheScrollDirection();

    int durationInMs =
        _calculateScrollDurationWithSpeedThatDoesNotVaryAccordingToTheScrollAmount(
      targetPosition,
    );

    return controller.animateTo(
      targetPosition,
      duration: Duration(milliseconds: durationInMs),
      curve: Curves.linear,
    );
  }

  double _getMinOrMaxPositionDependingOnTheScrollDirection() =>
      autoScroll.direction == AutoScrollDirection.down
          ? controller.position.maxScrollExtent
          : 0;

  int _calculateScrollDurationWithSpeedThatDoesNotVaryAccordingToTheScrollAmount(
    double targetPosition,
  ) {
    double amountToBeScrolled = (targetPosition - _currentPosition).abs();
    return (amountToBeScrolled * minimumScrollDurationPerPixelInMs).toInt();
  }

  @visibleForTesting
  bool isAbleToPerformAutoScroll() =>
      _currentPosition != null && autoScroll.direction != null;

  @visibleForTesting
  bool hasNothingLeftToScroll() =>
      ((autoScroll.direction == AutoScrollDirection.down) &&
          (_currentPosition == controller.position.maxScrollExtent)) ||
      ((autoScroll.direction == AutoScrollDirection.up) &&
          (_currentPosition == 0));
}
