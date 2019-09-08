import 'package:drag_select_grid_view/src/selectable.dart';
import 'package:flutter/widgets.dart';

import 'auto_scroll_hotspot_presence_inspector/auto_scroll_hotspot_presence_inspector.dart';
import 'auto_scroller/auto_scroller_mixin.dart';
import 'spacing_details/spacing_details_mixin.dart';

typedef SelectableWidgetBuilder = Widget Function(
  BuildContext context,
  int index,
  bool selected,
);

class DragSelectGridView extends StatefulWidget {
  static const defaultAutoScrollHotspotHeight = 64.0;

  DragSelectGridView({
    Key key,
    double autoScrollHotspotHeight,
    ScrollController controller,
    this.padding,
    this.itemCount,
    @required this.itemBuilder,
    @required this.gridDelegate,
  })  : assert(itemBuilder != null),
        controller = controller ?? ScrollController(),
        autoScrollHotspotHeight =
            autoScrollHotspotHeight ?? defaultAutoScrollHotspotHeight,
        super(key: key);

  final double autoScrollHotspotHeight;
  final ScrollController controller;
  final EdgeInsetsGeometry padding;
  final SliverGridDelegate gridDelegate;
  final SelectableWidgetBuilder itemBuilder;
  final int itemCount;

  @override
  DragSelectGridViewState createState() => DragSelectGridViewState();
}

class DragSelectGridViewState extends State<DragSelectGridView>
    with
        SpacingDetailsMixin<DragSelectGridView>,
        AutoScrollerMixin<DragSelectGridView> {
  final elements = <SelectableElement>{};
  final selectedIndexes = <int>{};

  int dragStartIndex;
  int dragEndIndex;

  bool get isDragging => dragStartIndex != null && dragEndIndex != null;

  bool get isSelecting => selectedIndexes.isNotEmpty;

  double get autoScrollHotspotHeight => widget.autoScrollHotspotHeight;

  @override
  ScrollController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      key: rootWidgetOfBuildMethodKey,
      onTapUp: onTapUp,
      onLongPressStart: onLongPressStart,
      onLongPressMoveUpdate: onLongPressMoveUpdate,
      onLongPressEnd: onLongPressEnd,
      behavior: HitTestBehavior.translucent,
      child: IgnorePointer(
        ignoring: isDragging,
        child: GridView.builder(
          controller: widget.controller,
          padding: widget.padding,
          gridDelegate: widget.gridDelegate,
          itemCount: widget.itemCount,
          itemBuilder: (BuildContext context, int index) {
            return Selectable(
              index: index,
              child: widget.itemBuilder(
                context,
                index,
                selectedIndexes.contains(index),
              ),
            );
          },
        ),
      ),
    );
  }

  void onTapUp(TapUpDetails details) {
    if (!isSelecting) return;

    final pressedIndex = findIndexOfSelectable(details.localPosition);

    if (pressedIndex != -1) {
      if (selectedIndexes.contains(pressedIndex)) {
        setState(() => selectedIndexes.remove(pressedIndex));
      } else {
        setState(() => selectedIndexes.add(pressedIndex));
      }
    }
  }

  void onLongPressStart(LongPressStartDetails details) {
    final pressedIndex = findIndexOfSelectable(details.localPosition);

    if (pressedIndex != -1) {
      dragStartIndex = pressedIndex;
      dragEndIndex = pressedIndex;
      setState(() => selectedIndexes.add(pressedIndex));
    }
  }

  void onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (!isDragging) return;

    final pressedIndex = findIndexOfSelectable(details.localPosition);

    if ((pressedIndex != -1) && (pressedIndex != dragEndIndex)) {
      final indexesDraggedBy = intListFromRange(dragEndIndex, pressedIndex);

      void removeIndexesDraggedByExceptTheCurrent() {
        indexesDraggedBy.remove(pressedIndex);
        setState(() => selectedIndexes.removeAll(indexesDraggedBy));
      }

      void addIndexesDragged() {
        setState(() => selectedIndexes.addAll(indexesDraggedBy));
      }

      final isSelectingDownwards = pressedIndex > dragStartIndex;
      final isSelectingUpwards = pressedIndex < dragStartIndex;

      if (isSelectingDownwards) {
        final isUnselecting = pressedIndex < dragEndIndex;
        if (isUnselecting) {
          removeIndexesDraggedByExceptTheCurrent();
        } else {
          addIndexesDragged();
        }
      } else if (isSelectingUpwards) {
        final isUnselecting = pressedIndex > dragEndIndex;
        if (isUnselecting) {
          removeIndexesDraggedByExceptTheCurrent();
        } else {
          addIndexesDragged();
        }
      } else {
        removeIndexesDraggedByExceptTheCurrent();
      }

      dragEndIndex = pressedIndex;
    }

    if (isInsideUpperAutoScrollHotspot(details.globalPosition)) {
      startAutoScrollingUp();
    } else if (isInsideLowerAutoScrollHotspot(details.globalPosition)) {
      startAutoScrollingDown();
    } else {
      stopScrolling();
    }
  }

  void onLongPressEnd(LongPressEndDetails details) {
    stopScrolling();
    dragStartIndex = null;
    dragEndIndex = null;
  }

  List<int> intListFromRange(int start, int end) {
    final actualStart = (start < end) ? start : end;
    final actualEnd = (start < end) ? end : start;
    return List.generate(
      (actualEnd - actualStart) + 1,
      (index) => actualStart + index,
    );
  }

  bool isInsideUpperAutoScrollHotspot(Offset position) =>
      AutoScrollHotspotPresenceInspector(this, position)
          .isInsideUpperAutoScrollHotspot;

  bool isInsideLowerAutoScrollHotspot(Offset position) =>
      AutoScrollHotspotPresenceInspector(this, position)
          .isInsideLowerAutoScrollHotspot;

  int findIndexOfSelectable(Offset offset) {
    final ancestor = context.findRenderObject();

    for (final element in List.of(elements)) {
      if (element.containsOffset(ancestor, offset)) {
        return element.widget.index;
      }
    }

    return -1;
  }
}
