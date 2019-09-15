import 'package:collection/collection.dart';

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
