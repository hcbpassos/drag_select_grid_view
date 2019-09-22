import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../misc/utils.dart';

class SelectionManager {
  int get dragStartIndex => _dragStartIndex;
  var _dragStartIndex = -1;

  int get dragEndIndex => _dragEndIndex;
  var _dragEndIndex = -1;

  final selectedIndexes = <int>{};

  void toggle(int index) {
    if (selectedIndexes.contains(index)) {
      selectedIndexes.remove(index);
    } else {
      selectedIndexes.add(index);
    }
  }

  void startDrag(int index) {
    _dragStartIndex = _dragEndIndex = index;
    selectedIndexes.add(index);
  }

  void updateDrag(int index) {
    final indexesDraggedBy = intListFromRange(index, _dragEndIndex);

    void removeIndexesDraggedByExceptTheCurrent() {
      indexesDraggedBy.remove(index);
      selectedIndexes.removeAll(indexesDraggedBy);
    }

    void addIndexesDragged() => selectedIndexes.addAll(indexesDraggedBy);

    final isSelectingForward = index > _dragStartIndex;
    final isSelectingBackward = index < _dragStartIndex;

    if (isSelectingForward) {
      final isUnselecting = index < _dragEndIndex;
      if (isUnselecting) {
        removeIndexesDraggedByExceptTheCurrent();
      } else {
        addIndexesDragged();
      }
    } else if (isSelectingBackward) {
      final isUnselecting = index > _dragEndIndex;
      if (isUnselecting) {
        removeIndexesDraggedByExceptTheCurrent();
      } else {
        addIndexesDragged();
      }
    } else {
      removeIndexesDraggedByExceptTheCurrent();
    }

    _dragEndIndex = index;
  }

//  void onUpdateDrag(int index) {
//    final indexesDraggedBy = intListFromRange(index, _dragEndIndex);
//
//    void removeIndexesDraggedByExceptTheCurrent() {
//      indexesDraggedBy.remove(index);
//      selectedIndexes.removeAll(indexesDraggedBy);
//    }
//
//    void addIndexesDragged() => selectedIndexes.addAll(indexesDraggedBy);
//
//    final isSelectingForward = index > _dragStartIndex;
//    final isSelectingBackward = index < _dragStartIndex;
//
//    if (isSelectingForward) {
//      final isUnselecting = index < _dragEndIndex;
//      if (isUnselecting) {
//        removeIndexesDraggedByExceptTheCurrent();
//      } else {
//        addIndexesDragged();
//      }
//    } else if (isSelectingBackward) {
//      final isUnselecting = index > _dragEndIndex;
//      if (isUnselecting) {
//        removeIndexesDraggedByExceptTheCurrent();
//      } else {
//        addIndexesDragged();
//      }
//    } else {
//      removeIndexesDraggedByExceptTheCurrent();
//    }
//
//    _dragEndIndex = index;
//  }

  void endDrag() {
    _dragStartIndex = -1;
    _dragEndIndex = -1;
  }
}

@immutable
class Selection {
  static const empty = Selection({});

  const Selection(this.selectedIndexes) : assert(selectedIndexes != null);

  final Set<int> selectedIndexes;

  int get amount => selectedIndexes.length;

  bool get isSelecting => amount != 0;

  @override
  String toString() => 'Selection{selectedIndexes: $selectedIndexes}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Selection &&
              runtimeType == other.runtimeType &&
              SetEquality().equals(selectedIndexes, other.selectedIndexes);

  @override
  int get hashCode => SetEquality().hash(selectedIndexes);
}
