import 'package:flutter/widgets.dart';

import '../drag_select_grid_view.dart';

/// This seems to be a good candidate to mid-mixin because it depends on
/// [DragSelectGridViewState], but making a mixin out of this would result in
/// [position] being passed around every time [isInsideUpperAutoScrollHotspot]
/// and [isInsideLowerAutoScrollHotspot] were called.
@immutable
class AutoScrollHotspotPresenceInspector {
  AutoScrollHotspotPresenceInspector(this.dragSelectState, this.position)
      : assert(dragSelectState != null),
        assert(position != null);

  final DragSelectGridViewState dragSelectState;
  final Offset position;

  bool get isInsideUpperAutoScrollHotspot =>
      !_isAboveUpperHotspot &&
      !_isBelowUpperHotspot &&
      !_isAtTheLeftSideOfHotspots &&
      !_isAtTheRightSideOfHotspots;

  bool get isInsideLowerAutoScrollHotspot =>
      !_isAboveLowerHotspot &&
      !_isBelowLowerHotspot &&
      !_isAtTheLeftSideOfHotspots &&
      !_isAtTheRightSideOfHotspots;

  bool get _isAboveUpperHotspot => position.dy <= dragSelectState.distanceFromTop;

  bool get _isBelowUpperHotspot =>
      position.dy >
      (dragSelectState.distanceFromTop +
          dragSelectState.autoScrollHotspotHeight);

  bool get _isAboveLowerHotspot =>
      position.dy <=
      (dragSelectState.distanceFromTop +
          (dragSelectState.height - dragSelectState.autoScrollHotspotHeight));

  bool get _isBelowLowerHotspot =>
      position.dy > (dragSelectState.distanceFromTop + dragSelectState.height);

  bool get _isAtTheLeftSideOfHotspots =>
      position.dx <= dragSelectState.distanceFromLeft;

  bool get _isAtTheRightSideOfHotspots =>
      position.dx > (dragSelectState.distanceFromLeft + dragSelectState.width);
}
