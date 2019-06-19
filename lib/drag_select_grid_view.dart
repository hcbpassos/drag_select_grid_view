library drag_select_grid_view;

import 'package:drag_select_grid_view/auto_scroller/auto_scroll.dart';
import 'package:drag_select_grid_view/auto_scroll_hotspot_presence_inspector.dart';
import 'package:drag_select_grid_view/auto_scroller/auto_scroller_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:drag_select_grid_view/spacing_details/spacing_details_mixin.dart';

class DragSelectGridView extends StatefulWidget {
  static const defaultAutoScrollHotspotHeight = 64.0;

  final GridView grid;
  final double autoScrollHotspotHeight;

  DragSelectGridView({
    @required this.grid,
    double autoScrollHotspotHeight,
  })  : assert(grid != null),
        assert(grid.gridDelegate is SliverGridDelegateWithMaxCrossAxisExtent),
        autoScrollHotspotHeight = autoScrollHotspotHeight == null
            ? defaultAutoScrollHotspotHeight
            : autoScrollHotspotHeight;

  @override
  DragSelectGridViewState createState() => DragSelectGridViewState();
}

class DragSelectGridViewState extends State<DragSelectGridView>
    with SpacingDetailsMixin<DragSelectGridView>,
        AutoScrollerMixin<DragSelectGridView> {
  bool isInDragSelectMode = false;

  GridView get grid => widget.grid;

  double get autoScrollHotspotHeight => widget.autoScrollHotspotHeight;

  @override
  ScrollController get controller => grid.controller;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      key: rootWidgetOfBuildMethodKey,
      onLongPressDragStart: onLongPressDragStart,
      onLongPressDragUpdate: onLongPressDragUpdate,
      onLongPressDragUp: onLongPressDragUp,
      behavior: HitTestBehavior.translucent,
      child: IgnorePointer(
        ignoring: isInDragSelectMode,
        child: grid,
      ),
    );
  }

  void onLongPressDragStart(GestureLongPressDragStartDetails details) {
    setState(() => isInDragSelectMode = true);
  }

  void onLongPressDragUpdate(GestureLongPressDragUpdateDetails details) {
    if (isInsideUpperAutoScrollHotspot(details.globalPosition)) {
      startAutoScrollingUp();
    } else if (isInsideLowerAutoScrollHotspot(details.globalPosition)) {
      startAutoScrollingDown();
    } else {
      stopScrolling();
    }
  }

  void onLongPressDragUp(GestureLongPressDragUpDetails details) {
    setState(() => isInDragSelectMode = false);
    stopScrolling();
  }

  bool isInsideUpperAutoScrollHotspot(Offset position) =>
      AutoScrollHotspotPresenceInspector(this, position)
          .isInsideUpperAutoScrollHotspot();

  bool isInsideLowerAutoScrollHotspot(Offset position) =>
      AutoScrollHotspotPresenceInspector(this, position)
          .isInsideLowerAutoScrollHotspot();
}
