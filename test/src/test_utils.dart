import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

/// Performs a long press without releasing the pointer.
///
/// A call to [WidgetTester.longPress] results in a press, but with a
/// [TestGesture.up] called at the end. [TestGesture.up] is not called in this
/// method.
Future<TestGesture> longPressDown({
  @required WidgetTester tester,
  @required Finder finder,
}) {
  assert(tester != null);
  assert(finder != null);

  return TestAsyncUtils.guard<TestGesture>(() async {
    Offset pressPosition = tester.getCenter(finder);
    final TestGesture gesture = await tester.startGesture(pressPosition);
    await tester.pump(kLongPressTimeout + kPressTimeout);
    return gesture;
  });
}

/// Performs a long press followed by a drag, without releasing the pointer.
Future<TestGesture> longPressDownAndDrag({
  @required WidgetTester tester,
  @required Finder finder,
  @required Offset offset,
}) {
  assert(tester != null);
  assert(finder != null);
  assert(offset != null);

  return TestAsyncUtils.guard<TestGesture>(() async {
    Offset pressPosition = tester.getCenter(finder);
    final TestGesture gesture = await tester.startGesture(pressPosition);
    await tester.pump(kLongPressTimeout + kPressTimeout);
    await gesture.moveBy(offset);
    return gesture;
  });
}
