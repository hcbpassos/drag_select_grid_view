import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Flutter's default value for `testWidgets()`.
const screenHeight = 600.0;

/// Flutter's default value for `testWidgets()`.
const screenWidth = 800.0;

/// Performs a long press without releasing the pointer.
///
/// A call to [WidgetTester.longPress] results in a press, but with a
/// [TestGesture.up] called at the end. [TestGesture.up] is not called in this
/// method.
///
/// Most code was copied from [WidgetTester.longPressAt].
Future<TestGesture> longPressDown({
  @required WidgetTester tester,
  @required Finder finder,
}) {
  assert(tester != null);
  assert(finder != null);

  return TestAsyncUtils.guard<TestGesture>(() async {
    final pressPosition = tester.getCenter(finder);
    final gesture = await tester.startGesture(pressPosition);
    await tester.pump(kLongPressTimeout + kPressTimeout);
    return gesture;
  });
}

/// Performs a long-press, and then a drag, without releasing the pointer.
Future<TestGesture> longPressDownAndDrag({
  @required WidgetTester tester,
  @required Finder finder,
  @required Offset offset,
}) async {
  final gesture = await longPressDown(tester: tester, finder: finder);
  return dragDown(
    tester: tester,
    previousGesture: gesture,
    offset: offset,
  );
}

/// Performs a drag, without releasing the pointer.
///
/// You can either specify a [finder] or a [previousGesture] to hold the
/// starting point of the drag.
///
/// Most code was copied from [WidgetTester.dragFrom].
Future<TestGesture> dragDown({
  @required WidgetTester tester,
  Finder finder,
  TestGesture previousGesture,
  @required Offset offset,
}) {
  assert(tester != null);
  assert(offset != null);
  assert((finder != null) || (previousGesture != null));

  return TestAsyncUtils.guard<TestGesture>(() async {
    final touchSlopX = kDragSlopDefault;
    final touchSlopY = kDragSlopDefault;

    final gesture =
        previousGesture ?? await tester.startGesture(tester.getCenter(finder));
    assert(gesture != null);
    await tester.pump(kLongPressTimeout + kPressTimeout);

    final xSign = offset.dx.sign;
    final ySign = offset.dy.sign;

    final offsetX = offset.dx;
    final offsetY = offset.dy;

    final separateX = offset.dx.abs() > touchSlopX && touchSlopX > 0;
    final separateY = offset.dy.abs() > touchSlopY && touchSlopY > 0;

    if (separateY || separateX) {
      final offsetSlope = offsetY / offsetX;
      final inverseOffsetSlope = offsetX / offsetY;
      final slopSlope = touchSlopY / touchSlopX;
      final absoluteOffsetSlope = offsetSlope.abs();
      final signedSlopX = touchSlopX * xSign;
      final signedSlopY = touchSlopY * ySign;
      if (absoluteOffsetSlope != slopSlope) {
        // The drag goes through one or both of the extents of the edges of the
        // box.
        if (absoluteOffsetSlope < slopSlope) {
          assert(offsetX.abs() > touchSlopX);
          // The drag goes through the vertical edge of the box.
          // It is guaranteed that the |offsetX| > touchSlopX.
          final diffY = offsetSlope.abs() * touchSlopX * ySign;

          // The vector from the origin to the vertical edge.
          await gesture.moveBy(Offset(signedSlopX, diffY));
          if (offsetY.abs() <= touchSlopY) {
            // The drag ends on or before getting to the horizontal extension
            // of the horizontal edge.
            await gesture
                .moveBy(Offset(offsetX - signedSlopX, offsetY - diffY));
          } else {
            final diffY2 = signedSlopY - diffY;
            final diffX2 = inverseOffsetSlope * diffY2;

            // The vector from the edge of the box to the horizontal extension
            // of the horizontal edge.
            await gesture.moveBy(Offset(diffX2, diffY2));
            await gesture.moveBy(
                Offset(offsetX - diffX2 - signedSlopX, offsetY - signedSlopY));
          }
        } else {
          assert(offsetY.abs() > touchSlopY);
          // The drag goes through the horizontal edge of the box.
          // It is guaranteed that the |offsetY| > touchSlopY.
          final diffX = inverseOffsetSlope.abs() * touchSlopY * xSign;

          // The vector from the origin to the vertical edge.
          await gesture.moveBy(Offset(diffX, signedSlopY));
          if (offsetX.abs() <= touchSlopX) {
            // The drag ends on or before getting to the vertical extension of
            // the vertical edge.
            await gesture
                .moveBy(Offset(offsetX - diffX, offsetY - signedSlopY));
          } else {
            final diffX2 = signedSlopX - diffX;
            final diffY2 = offsetSlope * diffX2;

            // The vector from the edge of the box to the vertical extension of
            // the vertical edge.
            await gesture.moveBy(Offset(diffX2, diffY2));
            await gesture.moveBy(
                Offset(offsetX - signedSlopX, offsetY - diffY2 - signedSlopY));
          }
        }
      } else {
        // The drag goes through the corner of the box.
        await gesture.moveBy(Offset(signedSlopX, signedSlopY));
        await gesture
            .moveBy(Offset(offsetX - signedSlopX, offsetY - signedSlopY));
      }
    } else {
      // The drag ends inside the box.
      await gesture.moveBy(offset);
    }
    return gesture;
  });
}
