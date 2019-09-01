import 'package:flutter/widgets.dart';

import 'auto_scroll_hotspot_presence_inspector/auto_scroll_hotspot_presence_inspector.dart';
import 'auto_scroller/auto_scroller_mixin.dart';
import 'spacing_details/spacing_details_mixin.dart';

@immutable
class DragSelectGridView extends StatefulWidget {
  static const defaultAutoScrollHotspotHeight = 64.0;

  DragSelectGridView({
    @required this.grid,
    double autoScrollHotspotHeight,
  })  : assert(grid != null),
        assert(grid.gridDelegate is SliverGridDelegateWithMaxCrossAxisExtent),
        autoScrollHotspotHeight = autoScrollHotspotHeight == null
            ? defaultAutoScrollHotspotHeight
            : autoScrollHotspotHeight;

  final GridView grid;
  final double autoScrollHotspotHeight;

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
          .isInsideUpperAutoScrollHotspot;

  bool isInsideLowerAutoScrollHotspot(Offset position) =>
      AutoScrollHotspotPresenceInspector(this, position)
          .isInsideLowerAutoScrollHotspot;
}
