import 'package:flutter/widgets.dart';

import 'selection.dart';

/// Function signature for notifying whenever the selection changes.
typedef SelectionChangedCallback = void Function(Selection selection);

/// Controls the selection of the grid.
///
/// This provides information that can be used to update the UI to indicate
/// whether there are selected items and how many are selected.
///
/// It also allows to directly update the selected items.
class DragSelectGridViewController extends ChangeNotifier {
  /// Gets the current grid selection.
  ///
  /// Use [addListener] to be notified whenever this field changes. This can be
  /// used to update the UI to indicate whether there are selected items and how
  /// many are selected.
  Selection get selection => _selection;

  /// Sets the grid selection.
  ///
  /// The listeners are going to be notified about this change.
  set selection(Selection selection) {
    _selection = selection;
    notifyListeners();
  }

  var _selection = Selection.empty;

  /// Clears the grid selection.
  ///
  /// The listeners are going to be notified about this change.
  void clear() => selection = Selection.empty;
}
