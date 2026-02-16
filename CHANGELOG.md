## [0.7.0] - 16/02/2026

* **Breaking change**. Drop support for Dart < 3.0.0.
* Bump dependencies (`collection` ^1.18.0, `flutter_lints` ^6.0.0).
* Adopt Dart 3 language features (super parameters, remove unnecessary library directive).
* Add pub.dev topics for discoverability.

## [0.6.2] - 29/08/2023

* Bump Dart SDK constraints.
* Support `LocalHistoryEntry.impliesAppBarDismissal` ([#31](https://github.com/hcbpassos/drag_select_grid_view/issues/31)).
* Fix lack of local history update on controller changes ([#31](https://github.com/hcbpassos/drag_select_grid_view/issues/31)).

## [0.6.1] - 24/07/2022

* Fix format.

## [0.6.0] - 11/06/2022

* **Breaking change**. Drop support for flutter < 3.0.0.
* Fix null aware operator warning ([#28](https://github.com/hcbpassos/drag_select_grid_view/issues/28)).
* Use `flutter_lints`.

## [0.5.1] - 03/05/2021

* Fix pointer ignoring when grid is in selection mode.

## [0.5.0] - 02/05/2021

* Support selection trigger on tap instead of on long-press.
* Add missing `GridView` fields.
* Replace `WillPopScope` widget by adding entry on local-history. This fixes iOS route navigation (swipe left to pop). 
* **Breaking change**. Remove `DragSelectiGridView.unselectOnWillPop`: turn this behavior mandatory. 

## [0.4.0] - 21/03/2021

* Migrate to null safety.

## [0.3.1] - 10/08/2020

* Fix format.

## [0.3.0] - 08/08/2020

* **Breaking change**. Fix the constructor of `Selection`, which now creates a copy of the received `Set`. Consequently, the constructor is no longer constant. To keep `Selection.empty` constant, another constructor has been created: `Selection.empty()`. 
* **Breaking change**. Make `DragSelectGridViewController` extend `ValueNotifier` instead of `ChangeNotifier`. The getter and setter `selection` are now `ValueNotifier`'s default: `value`.
* Support initial selection ([#14](https://github.com/hcbpassos/drag_select_grid_view/issues/14)).

## [0.2.1] - 28/07/2020

*  Fix `DragSelectGridViewController` dispose ([#13](https://github.com/hcbpassos/drag_select_grid_view/issues/13)).

## [0.2.0] - 05/04/2020

* Improve code safety with `assert`s.
* Remove author section from `pubspec.yaml`.

## [0.1.1] - 26/10/2019

* Update authors.

## [0.1.0] - 06/10/2019

* Initial release.
