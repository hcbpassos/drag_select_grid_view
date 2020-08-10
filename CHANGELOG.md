## [0.3.1] - 10/08/2020

* Fix format.

## [0.3.0] - 08/08/2020

* **Breaking change**. Fix the constructor of `Selection`, which now creates a copy of the received `Set`. Consequently, the constructor is no longer constant. To keep `Selection.empty` constant, another constructor has been created: `Selection.empty()`. 
* **Breaking change**. Make `DragSelectGridViewController` extend `ValueNotifier` instead of `ChangeNotifier`. The getter and setter `selection` are now `ValueNotifier`'s default: `value`.
* Support initial selection ([#14](https://github.com/hugocbpassos/drag_select_grid_view/issues/14)). 

## [0.2.1] - 28/07/2020

*  Fix `DragSelectGridViewController` dispose ([#13](https://github.com/hugocbpassos/drag_select_grid_view/issues/13)).

## [0.2.0] - 05/04/2020

* Improve code safety with `assert`s.
* Remove author section from `pubspec.yaml`.

## [0.1.1] - 26/10/2019

* Update authors.

## [0.1.0] - 06/10/2019

* Initial release.
