import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

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
