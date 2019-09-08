import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../drag_select_grid_view.dart';

class Selectable extends ProxyWidget {
  const Selectable({
    Key key,
    @required this.index,
    @required Widget child,
  }) : super(key: key, child: child);

  final int index;

  @override
  SelectableElement createElement() => SelectableElement(this);
}

class SelectableElement extends ProxyElement {
  SelectableElement(Selectable widget) : super(widget);

  /// Refer to [Element.widget].
  ///
  /// Overridden to specify return type.
  @override
  Selectable get widget => super.widget;

  DragSelectGridViewState _ancestorState;

  @override
  void mount(Element parent, newSlot) {
    super.mount(parent, newSlot);
    _ancestorState =
        ancestorStateOfType(TypeMatcher<DragSelectGridViewState>());
    _ancestorState?.elements?.add(this);
  }

  @override
  void unmount() {
    _ancestorState?.elements?.remove(this);
    _ancestorState = null;
    super.unmount();
  }

  bool containsOffset(RenderObject ancestor, Offset offset) {
    final box = renderObject as RenderBox;
    final rect = box.localToGlobal(Offset.zero, ancestor: ancestor) & box.size;
    return rect.contains(offset);
  }

  void showOnScreen(EdgeInsets scrollPadding) {
    final box = renderObject as RenderBox;
    box.showOnScreen(
      rect: scrollPadding.inflateRect(Offset.zero & box.size),
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void notifyClients(ProxyWidget oldWidget) {}
}

//class MultiChildSelection {
//  const MultiChildSelection(this.total, this.start, this.end);
//
//  static const empty = MultiChildSelection(0, -1, -1);
//
//  final int total;
//  final int start;
//  final int end;
//
//  bool get selecting => total != 0;
//
//  @override
//  String toString() => 'MultiChildSelection{$total, $start, $end}';
//}
