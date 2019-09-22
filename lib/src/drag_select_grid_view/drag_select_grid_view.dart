import 'package:flutter/widgets.dart';

import '../auto_scroll/auto_scroller_mixin.dart';
import '../drag_select_grid_view/selectable.dart';
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
    with AutoScrollerMixin<DragSelectGridView> {
  final elements = <SelectableElement>{};
  final selectionManager = SelectionManager();

  Set<int> get selectedIndexes => selectionManager.selectedIndexes;

  bool get isDragging =>
      (selectionManager.dragStartIndex != -1) &&
      (selectionManager.dragEndIndex != -1);

  bool get isSelecting => selectedIndexes.isNotEmpty;

  @override
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

    final tapIndex = _findIndexOfSelectable(details.localPosition);

    if (tapIndex != -1) {
      setState(() => selectionManager.tap(tapIndex));
      _notifySelectionChange();
    }
  }

  void _onLongPressStart(LongPressStartDetails details) {
    final pressIndex = _findIndexOfSelectable(details.localPosition);

    if (pressIndex != -1) {
      setState(() => selectionManager.startDrag(pressIndex));
      _notifySelectionChange();
    }
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (!isDragging) return;

    final dragIndex = _findIndexOfSelectable(details.localPosition);

    if ((dragIndex != -1) && (dragIndex != selectionManager.dragEndIndex)) {
      setState(() => selectionManager.updateDrag(dragIndex));
      _notifySelectionChange();
    }

    if (isInsideUpperAutoScrollHotspot(details.localPosition)) {
      startAutoScrollingUp();
    } else if (isInsideLowerAutoScrollHotspot(details.localPosition)) {
      startAutoScrollingDown();
    } else {
      stopScrolling();
    }
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    setState(() => selectionManager.endDrag());
    stopScrolling();
  }

  int _findIndexOfSelectable(Offset offset) {
    final ancestor = context.findRenderObject();

    for (final element in List.of(elements)) {
      if (element.containsOffset(ancestor, offset)) {
        return element.widget.index;
      }
    }

    return -1;
  }

  void _notifySelectionChange() {
    widget.onSelectionChanged?.call(
      Selection(selectionManager.selectedIndexes),
    );
  }
}
