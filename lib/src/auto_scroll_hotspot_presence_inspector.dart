import 'package:flutter/widgets.dart';

import 'drag_select_grid_view.dart';

@immutable
class AutoScrollHotspotPresenceInspector {
  AutoScrollHotspotPresenceInspector(this.dragSelectState, this.position)
      : assert(dragSelectState != null),
        assert(position != null);

  final DragSelectGridViewState dragSelectState;
  final Offset position;

  bool isInsideUpperAutoScrollHotspot() =>
      !_isAboveUpperHotspot() &&
      !_isBelowUpperHotspot() &&
      !_isAtTheLeftSideOfHotspots() &&
      !_isAtTheRightSideOfHotspots();

  bool isInsideLowerAutoScrollHotspot() =>
      !_isAboveLowerHotspot() &&
      !_isBelowLowerHotspot() &&
      !_isAtTheLeftSideOfHotspots() &&
      !_isAtTheRightSideOfHotspots();

  bool _isAboveUpperHotspot() => position.dy <= dragSelectState.distanceFromTop;

  bool _isBelowUpperHotspot() =>
      position.dy >
      (dragSelectState.distanceFromTop +
          dragSelectState.autoScrollHotspotHeight);

  bool _isAboveLowerHotspot() =>
      position.dy <=
      (dragSelectState.distanceFromTop +
          (dragSelectState.height - dragSelectState.autoScrollHotspotHeight));

  bool _isBelowLowerHotspot() =>
      position.dy > (dragSelectState.distanceFromTop + dragSelectState.height);

  bool _isAtTheLeftSideOfHotspots() =>
      position.dx <= dragSelectState.distanceFromLeft;

  bool _isAtTheRightSideOfHotspots() =>
      position.dx > (dragSelectState.distanceFromLeft + dragSelectState.width);
}
