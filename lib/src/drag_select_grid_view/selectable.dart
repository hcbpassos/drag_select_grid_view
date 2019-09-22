import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../drag_select_grid_view/drag_select_grid_view.dart';

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

  /// Returns whether the [offset] is in the bounds of this element.
  bool containsOffset(RenderObject ancestor, Offset offset) {
    RenderBox box = renderObject;
    final rect = box.localToGlobal(Offset.zero, ancestor: ancestor) & box.size;
    return rect.contains(offset);
  }

  @override
  void notifyClients(ProxyWidget oldWidget) {}
}