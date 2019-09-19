import 'package:drag_select_grid_view/src/drag_select_grid_view/selectable.dart';
import 'package:drag_select_grid_view/src/misc/utils.dart';
import 'package:flutter/widgets.dart';

import '../auto_scroll_hotspot_presence_inspector/auto_scroll_hotspot_presence_inspector.dart';
import '../auto_scroller/auto_scroller_mixin.dart';
import '../spacing_details/spacing_details_mixin.dart';
import 'selection.dart';

typedef SelectableWidgetBuilder = Widget Function(
  BuildContext context,
  int index,
  bool selected,
);

typedef SelectionChangedCallback = void Function(Selection selection);

class DragSelectGridView extends StatefulWidget {
  static const defaultAutoScrollHotspotHeight = 64.0;

  DragSelectGridView({
    Key key,
    double autoScrollHotspotHeight,
    ScrollController controller,
    this.onSelectionChanged,
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
  final SelectionChangedCallback onSelectionChanged;
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

  var dragStartIndex = -1;
  var dragEndIndex = -1;

  bool get isDragging => (dragStartIndex != -1) && (dragEndIndex != -1);

  bool get isSelecting => selectedIndexes.isNotEmpty;

  double get autoScrollHotspotHeight => widget.autoScrollHotspotHeight;

  @override
  ScrollController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTapUp: _onTapUp,
      onLongPressStart: _onLongPressStart,
      onLongPressMoveUpdate: _onLongPressMoveUpdate,
      onLongPressEnd: _onLongPressEnd,
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

  void _onTapUp(TapUpDetails details) {
    if (!isSelecting) return;

    final pressedIndex = _findIndexOfSelectable(details.localPosition);

    if (pressedIndex != -1) {
      if (selectedIndexes.contains(pressedIndex)) {
        setState(() => selectedIndexes.remove(pressedIndex));
      } else {
        setState(() => selectedIndexes.add(pressedIndex));
      }

      notifySelectionChange();
    }
  }

  void _onLongPressStart(LongPressStartDetails details) {
    final pressedIndex = _findIndexOfSelectable(details.localPosition);

    if (pressedIndex != -1) {
      dragStartIndex = pressedIndex;
      dragEndIndex = pressedIndex;
      setState(() => selectedIndexes.add(pressedIndex));
      notifySelectionChange();
    }
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (!isDragging) return;

    final pressedIndex = _findIndexOfSelectable(details.localPosition);

    if ((pressedIndex != -1) && (pressedIndex != dragEndIndex)) {
      final indexesDraggedBy = intListFromRange(dragEndIndex, pressedIndex);

      void removeIndexesDraggedByExceptTheCurrent() {
        indexesDraggedBy.remove(pressedIndex);
        setState(() => selectedIndexes.removeAll(indexesDraggedBy));
      }

      void addIndexesDragged() {
        setState(() => selectedIndexes.addAll(indexesDraggedBy));
      }

      final isSelectingForward = pressedIndex > dragStartIndex;
      final isSelectingBackward = pressedIndex < dragStartIndex;

      if (isSelectingForward) {
        final isUnselecting = pressedIndex < dragEndIndex;
        if (isUnselecting) {
          removeIndexesDraggedByExceptTheCurrent();
        } else {
          addIndexesDragged();
        }
      } else if (isSelectingBackward) {
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
      notifySelectionChange();
    }

    if (_isInsideUpperAutoScrollHotspot(details.globalPosition)) {
      startAutoScrollingUp();
    } else if (_isInsideLowerAutoScrollHotspot(details.globalPosition)) {
      startAutoScrollingDown();
    } else {
      stopScrolling();
    }
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    stopScrolling();
    dragStartIndex = -1;
    dragEndIndex = -1;
  }

  void notifySelectionChange() =>
      widget.onSelectionChanged?.call(Selection(selectedIndexes));

  bool _isInsideUpperAutoScrollHotspot(Offset position) =>
      AutoScrollHotspotPresenceInspector(this, position)
          .isInsideUpperAutoScrollHotspot;

  bool _isInsideLowerAutoScrollHotspot(Offset position) =>
      AutoScrollHotspotPresenceInspector(this, position)
          .isInsideLowerAutoScrollHotspot;

  int _findIndexOfSelectable(Offset offset) {
    final ancestor = context.findRenderObject();

    for (final element in List.of(elements)) {
      if (element.containsOffset(ancestor, offset)) {
        return element.widget.index;
      }
    }

    return -1;
  }
}
