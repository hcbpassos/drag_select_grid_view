import 'package:flutter/widgets.dart';

import 'spacing_details.dart';

mixin SpacingDetailsMixin<T extends StatefulWidget> on State<T> {
  SpacingDetails _spacingDetails;

  double get distanceFromTop => _spacingDetails?.distanceFromTop ?? 0;

  double get distanceFromLeft => _spacingDetails?.distanceFromLeft ?? 0;

  double get distanceFromRight => _spacingDetails?.distanceFromRight ?? 0;

  double get distanceFromBottom => _spacingDetails?.distanceFromBottom ?? 0;

  double get height => _spacingDetails?.height ?? 0;

  double get width => _spacingDetails?.width ?? 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _spacingDetails = SpacingDetails.calculate(context),
    );
  }
}
