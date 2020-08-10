import 'package:flutter/widgets.dart';

import 'drag_select_grid_view.dart';
import 'selection.dart';

/// Function signature for notifying whenever the selection changes.
typedef SelectionChangedCallback = void Function(Selection selection);

/// A controller for [DragSelectGridView].
///
/// This provides information that can be used to update the UI to indicate
/// whether there are selected items and how many are selected.
///
/// It also allows to directly update the selected items.
class DragSelectGridViewController extends ValueNotifier<Selection> {
  /// Creates a controller for [DragSelectGridView].
  ///
  /// The initial selection is [Selection.empty], unless a different one is
  /// provided.
  DragSelectGridViewController([Selection selection])
      : super(selection ?? const Selection.empty());

  /// Clears the grid selection.
  void clear() => value = const Selection.empty();
}
