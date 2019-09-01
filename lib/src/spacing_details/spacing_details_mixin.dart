import 'package:flutter/widgets.dart';

import 'spacing_details.dart';

mixin SpacingDetailsMixin<T extends StatefulWidget> on State<T> {
  SpacingDetails _spacingDetails;

  /// This key must be attached to the root Widget returned by the build method
  /// of the State that uses this mixin.
  ///
  /// Example:
  /// ```
  /// class FooState extends State<Foo> with SpacingDetailsMixin<Foo> {
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return Container(
  ///       key: rootWidgetOfBuildMethodKey,
  ///       ...
  ///     );
  ///   }
  /// }
  /// ```
  final rootWidgetOfBuildMethodKey = GlobalKey();

  double get distanceFromTop => _spacingDetails?.distanceFromTop ?? 0;

  double get distanceFromLeft => _spacingDetails?.distanceFromLeft ?? 0;

  double get distanceFromRight => _spacingDetails?.distanceFromRight ?? 0;

  double get distanceFromBottom => _spacingDetails?.distanceFromBottom ?? 0;

  double get height => _spacingDetails?.height ?? 0;

  double get width => _spacingDetails?.width ?? 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _calculateSpacingDetails());
  }

  void _calculateSpacingDetails() {
    _spacingDetails = SpacingDetails.calculateWith(
      widgetKey: rootWidgetOfBuildMethodKey,
      context: context,
    );
  }
}
