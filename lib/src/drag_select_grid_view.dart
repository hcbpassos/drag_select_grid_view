import 'package:drag_select_grid_view/src/auto_scroll_hotspot_presence_inspector.dart';
import 'package:drag_select_grid_view/src/auto_scroller/auto_scroller_mixin.dart';
import 'package:drag_select_grid_view/src/spacing_details/spacing_details_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

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
    with
        SpacingDetailsMixin<DragSelectGridView>,
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
      onLongPressStart: onLongPressStart,
      onLongPressMoveUpdate: onLongPressMoveUpdate,
      onLongPressUp: onLongPressUp,
      behavior: HitTestBehavior.translucent,
      child: IgnorePointer(
        ignoring: isInDragSelectMode,
        child: grid,
      ),
    );
  }

  void onLongPressStart(LongPressStartDetails details) {
    setState(() => isInDragSelectMode = true);
  }

  void onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (isInsideUpperAutoScrollHotspot(details.globalPosition)) {
      startAutoScrollingUp();
    } else if (isInsideLowerAutoScrollHotspot(details.globalPosition)) {
      startAutoScrollingDown();
    } else {
      stopScrolling();
    }
  }

  void onLongPressUp() {
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
