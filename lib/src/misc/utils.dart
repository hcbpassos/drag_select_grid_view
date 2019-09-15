/// Returns an int list with all the numbers from [start] to [end].
///
/// Both [start] and [end] are included. As a consequence, an empty list is
/// never going to be returned, even if the start and end are equal.
List<int> intListFromRange(int start, int end) {
  final actualStart = (start < end) ? start : end;
  final actualEnd = (start < end) ? end : start;
  return List.generate(
    (actualEnd - actualStart) + 1,
    (index) => actualStart + index,
  );
}
