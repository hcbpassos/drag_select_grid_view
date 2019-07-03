import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class SpacingDetails {
  static double _distanceFromTopMock;
  static double _distanceFromLeftMock;
  static double _distanceFromRightMock;
  static double _distanceFromBottomMock;
  static double _heightMock;
  static double _widthMock;

  @visibleForTesting
  static void mockAttributes({
    double distanceFromTop,
    double distanceFromLeft,
    double distanceFromRight,
    double distanceFromBottom,
    double height,
    double width,
  }) {
    if (distanceFromTop != null) _distanceFromTopMock = distanceFromTop;
    if (distanceFromLeft != null) _distanceFromLeftMock = distanceFromTop;
    if (distanceFromRight != null) _distanceFromRightMock = distanceFromRight;
    if (distanceFromBottom != null)
      _distanceFromBottomMock = distanceFromBottom;
    if (height != null) _heightMock = height;
    if (width != null) _widthMock = width;
  }

  Size _screenSize;
  Size _widgetSize;
  Offset _widgetTopLeftPosition;

  double get distanceFromTop => _distanceFromTopMock ?? _distanceFromTop;
  double _distanceFromTop;

  double get distanceFromLeft => _distanceFromLeftMock ?? _distanceFromLeft;
  double _distanceFromLeft;

  double get distanceFromRight => _distanceFromRightMock ?? _distanceFromRight;
  double _distanceFromRight;

  double get distanceFromBottom =>
      _distanceFromBottomMock ?? _distanceFromBottom;
  double _distanceFromBottom;

  double get height => _heightMock ?? _height;
  double _height;

  double get width => _widthMock ?? _width;
  double _width;

  final GlobalKey widgetKey;
  final BuildContext context;

  SpacingDetails.calculateWith({
    @required this.widgetKey,
    @required this.context,
  })  : assert(widgetKey != null),
        assert(context != null) {
    _calculate();
  }

  void _calculate() {
    _initializeHelperAttributes();
    _initializeSimpleAttributes();
    _initializeCalculatedAttributes();
  }

  void _initializeHelperAttributes() {
    RenderBox renderBox = widgetKey.currentContext.findRenderObject();

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
