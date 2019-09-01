import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class SpacingDetails {
  static double _mockDistanceFromTop;
  static double _mockDistanceFromLeft;
  static double _mockDistanceFromRight;
  static double _mockDistanceFromBottom;
  static double _mockHeight;
  static double _mockWidth;

  @visibleForTesting
  static void mockAttributes({
    double distanceFromTop,
    double distanceFromLeft,
    double distanceFromRight,
    double distanceFromBottom,
    double height,
    double width,
  }) {
    if (distanceFromTop != null) _mockDistanceFromTop = distanceFromTop;
    if (distanceFromLeft != null) _mockDistanceFromLeft = distanceFromLeft;
    if (distanceFromRight != null) _mockDistanceFromRight = distanceFromRight;
    if (distanceFromBottom != null)
      _mockDistanceFromBottom = distanceFromBottom;
    if (height != null) _mockHeight = height;
    if (width != null) _mockWidth = width;
  }

  SpacingDetails.calculateWith({
    @required this.widgetKey,
    @required this.context,
  })  : assert(widgetKey != null),
        assert(context != null) {
    _calculate();
  }

  Size _screenSize;
  Size _widgetSize;
  Offset _widgetTopLeftPosition;

  double get distanceFromTop => _mockDistanceFromTop ?? _distanceFromTop;
  double _distanceFromTop;

  double get distanceFromLeft => _mockDistanceFromLeft ?? _distanceFromLeft;
  double _distanceFromLeft;

  double get distanceFromRight => _mockDistanceFromRight ?? _distanceFromRight;
  double _distanceFromRight;

  double get distanceFromBottom =>
      _mockDistanceFromBottom ?? _distanceFromBottom;
  double _distanceFromBottom;

  double get height => _mockHeight ?? _height;
  double _height;

  double get width => _mockWidth ?? _width;
  double _width;

  final GlobalKey widgetKey;
  final BuildContext context;

  void _calculate() {
    _initializeHelperAttributes();
    _initializeSimpleAttributes();
    _initializeCalculatedAttributes();
  }

  void _initializeHelperAttributes() {
    final renderBox = widgetKey.currentContext.findRenderObject() as RenderBox;

    _screenSize = MediaQuery.of(context).size;
    _widgetSize = renderBox.size;
    _widgetTopLeftPosition = renderBox.localToGlobal(Offset.zero);
  }

  void _initializeSimpleAttributes() {
    _height = _widgetSize.height;
    _width = _widgetSize.width;
    _distanceFromTop = _widgetTopLeftPosition.dy;
    _distanceFromLeft = _widgetTopLeftPosition.dx;
  }

  void _initializeCalculatedAttributes() {
    _distanceFromRight =
        _screenSize.width - (_distanceFromLeft + _widgetSize.width);
    _distanceFromBottom =
        _screenSize.height - (_distanceFromTop + _widgetSize.height);
  }
}
