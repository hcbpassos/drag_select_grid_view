/// Returns a set of int with all the numbers from [start] to [end].
///
/// Both [start] and [end] are included. As a consequence, an empty set is
/// never going to be returned, even if [start] and [end] are equal.
Set<int> intSetFromRange(int start, int end) {
  final actualStart = (start < end) ? start : end;
  final actualEnd = (start < end) ? end : start;
  return List.generate(
    (actualEnd - actualStart) + 1,
    (index) => actualStart + index,
  ).toSet();
}
