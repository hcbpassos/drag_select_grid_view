import 'dart:async';

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
class DragSelectGridViewController {
  final _selectionChangeController = StreamController<Selection>.broadcast();

  /// Stream of selection change events.
  ///
  /// May be used to update the UI to indicate whether there are selected items
  /// and how many are selected.
  Stream<Selection> get selectionChangeStream =>
      _selectionChangeController.stream;

  /// Sets the grid selection.
  ///
  /// Throws [StateError] if called after [dispose].
  void setSelection(Selection selection) =>
      _selectionChangeController.add(selection);

  /// Closes the streams of this controller.
  ///
  /// You must call this on [State.dispose], otherwise the streams will keep
  /// alive without being referenced anywhere.
  ///
  /// Usually, you should not await the returned Future, since [State.dispose]
  /// is not asynchronous.
  Future<void> dispose() => _selectionChangeController.close();
}
