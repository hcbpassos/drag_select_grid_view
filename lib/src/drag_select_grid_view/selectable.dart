import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Function signature for notifying whenever the element is mounted or
/// unmounted.
typedef ElementUpdateCallback = void Function(SelectableElement);

/// Helps to track the elements of the grid items.
///
/// This provides callbacks that allow storing the elements, so the method
/// [SelectableElement.containsOffset] can be used to determine which grid item
/// is at a given offset.
class Selectable extends ProxyWidget {
  /// Creates a [Selectable].
  const Selectable({
    Key key,
    @required this.index,
    @required this.onMountElement,
    @required this.onUnmountElement,
    @required Widget child,
  }) : super(key: key, child: child);

  final int index;
  final ElementUpdateCallback onMountElement;
  final ElementUpdateCallback onUnmountElement;

  @override
  SelectableElement createElement() => SelectableElement(this);
}

class SelectableElement extends ProxyElement {
  SelectableElement(Selectable widget) : super(widget);

  @override
  Selectable get widget => super.widget;

  @override
  void mount(Element parent, newSlot) {
    super.mount(parent, newSlot);
    widget.onMountElement?.call(this);
  }

  @override
  void unmount() {
    widget.onUnmountElement?.call(this);
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
