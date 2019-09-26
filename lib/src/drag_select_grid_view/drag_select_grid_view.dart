import 'package:flutter/widgets.dart';

import '../auto_scroll/auto_scroller_mixin.dart';
import '../drag_select_grid_view/selectable.dart';
import 'selection.dart';

/// Function signature that creates a widget based on the index and whether
/// it is selected or not.
///
/// Used by [DragSelectGridView] to generate children lazily.
typedef SelectableWidgetBuilder = Widget Function(
  BuildContext context,
  int index,
  bool selected,
);

/// Function signature for notifying whenever the selection changes.
typedef SelectionChangedCallback = void Function(Selection selection);

/// Grid that supports both dragging and tapping to select its items.
///
/// A long-press enables selection. The user may select/unselect any item by
/// tapping on it. Dragging allows cascade selecting/unselecting.
///
/// Through auto-scroll, this widget adds the ability to select items that go
/// beyond screen bounds without having to stop the drag. To do so, this widget
/// creates two imaginary zones that, if reached by the pointer while dragging,
/// triggers the auto-scroll.
///
/// The first zone is at the top, and triggers backward auto-scrolling.
/// The second is at the bottom, and triggers forward auto-scrolling.
class DragSelectGridView extends StatefulWidget {
  static const defaultAutoScrollHotspotHeight = 64.0;

  /// Creates a grid that supports both dragging and tapping to select its
  /// items.
  ///
  /// For information about the clause of most parameters, refer to
  /// [GridView.builder].
  DragSelectGridView({
    Key key,
    double autoScrollHotspotHeight,
    ScrollController controller,
    this.onSelectionChanged,
    this.reverse = false,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    @required this.gridDelegate,
    @required this.itemBuilder,
    this.itemCount,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.semanticChildCount,
  })  : assert(itemBuilder != null),
        autoScrollHotspotHeight =
            autoScrollHotspotHeight ?? defaultAutoScrollHotspotHeight,
        controller = controller ?? ScrollController(),
        super(key: key);

  /// The height of the hotspot that enables auto-scroll.
  ///
  /// This value is used for both top and bottom hotspots. The width is going to
  /// match the width of the widget.
  ///
  /// Defaults to [defaultAutoScrollHotspotHeight].
  final double autoScrollHotspotHeight;

  /// Refer to [ScrollView.controller].
  final ScrollController controller;

  /// Called whenever the selection changes.
  final SelectionChangedCallback onSelectionChanged;

  /// Refer to [ScrollView.reverse].
  final bool reverse;

  /// Refer to [ScrollView.primary].
  final bool primary;

  /// Refer to [ScrollView.physics].
  final ScrollPhysics physics;

  /// Refer to [ScrollView.shrinkWrap].
  final bool shrinkWrap;

  /// Refer to [BoxScrollView.padding].
  final EdgeInsetsGeometry padding;

  /// Refer to [GridView.gridDelegate].
  final SliverGridDelegate gridDelegate;

  /// Called whenever a child needs to be built.
  ///
  /// The client should use this to build the children dynamically, based on
  /// the index and whether it is selected or not.
  ///
  /// Cannot be null.
  ///
  /// Also refer to [SliverChildBuilderDelegate.builder].
  final SelectableWidgetBuilder itemBuilder;

  /// Refer to [SliverChildBuilderDelegate.itemCount].
  final int itemCount;

  /// Refer to [SliverChildBuilderDelegate.addAutomaticKeepAlives].
  final bool addAutomaticKeepAlives;

  /// Refer to [SliverChildBuilderDelegate.addRepaintBoundaries].
  final bool addRepaintBoundaries;

  /// Refer to [SliverChildBuilderDelegate.addSemanticIndexes].
  final bool addSemanticIndexes;

  /// Refer to [ScrollView.cacheExtent].
  final double cacheExtent;

  /// Refer to [ScrollView.semanticChildCount].
  final int semanticChildCount;

  @override
  DragSelectGridViewState createState() => DragSelectGridViewState();
}

class DragSelectGridViewState extends State<DragSelectGridView>
    with AutoScrollerMixin<DragSelectGridView> {
  final elements = <SelectableElement>{};
  final selectionManager = SelectionManager();

  Set<int> get selectedIndexes => selectionManager.selectedIndexes;

  bool get isSelecting => selectedIndexes.isNotEmpty;

  bool get isDragging =>
      (selectionManager.dragStartIndex != -1) &&
      (selectionManager.dragEndIndex != -1);

  @override
  double get autoScrollHotspotHeight => widget.autoScrollHotspotHeight;

  @override
  ScrollController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onTapUp: _onTapUp,
        onLongPressStart: _onLongPressStart,
        onLongPressMoveUpdate: _onLongPressMoveUpdate,
        onLongPressEnd: _onLongPressEnd,
        behavior: HitTestBehavior.translucent,
        child: IgnorePointer(
          ignoring: isDragging,
          child: GridView.builder(
            controller: widget.controller,
            reverse: widget.reverse,
            primary: widget.primary,
            physics: widget.physics,
            shrinkWrap: widget.shrinkWrap,
            padding: widget.padding,
            gridDelegate: widget.gridDelegate,
            itemCount: widget.itemCount,
            addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
            addRepaintBoundaries: widget.addRepaintBoundaries,
            addSemanticIndexes: widget.addSemanticIndexes,
            cacheExtent: widget.cacheExtent,
            semanticChildCount: widget.semanticChildCount,
            itemBuilder: (BuildContext context, int index) {
              return Selectable(
                index: index,
                onMountElement: elements.add,
                onUnmountElement: elements.remove,
                child: widget.itemBuilder(
                  context,
                  index,
                  selectedIndexes.contains(index),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (isSelecting) {
      setState(selectionManager.clear);
      _notifySelectionChange();
      return false;
    } else {
      return true;
    }
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
      if (widget.reverse) {
        startAutoScrollingForward();
      } else {
        startAutoScrollingBackward();
      }
    } else if (isInsideLowerAutoScrollHotspot(details.localPosition)) {
      if (widget.reverse) {
        startAutoScrollingBackward();
      } else {
        startAutoScrollingForward();
      }
    } else {
      stopScrolling();
    }
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    setState(selectionManager.endDrag);
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
