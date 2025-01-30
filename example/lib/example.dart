import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';

import 'selectable_item.dart';
import 'selection_app_bar.dart';

void main() {
  runApp(
    MaterialApp(
      home: const MyApp(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(elevation: 2),
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final controller = DragSelectGridViewController();

  @override
  void initState() {
    super.initState();
    controller.addListener(scheduleRebuild);
  }

  @override
  void dispose() {
    controller.removeListener(scheduleRebuild);
    super.dispose();
  }

  int speedIncreaseCount = 1;
  Timer? _timer;

  setTimer() {
    if (_timer?.isActive ?? false) _timer?.cancel();

    _timer = Timer(
      const Duration(milliseconds: 240),
      () {
        speedIncreaseCount = 1;
      },
    );
  }

  double calculateSpeed() {
    speedIncreaseCount++;
    setTimer();

    if (speedIncreaseCount < 300) {
      return 1;
    }

    final value = (0.001 * pow(speedIncreaseCount - 300, 1.2) + 1);

    print("${speedIncreaseCount - 300}, $value");

    return value.clamp(1, 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SelectionAppBar(
        selection: controller.value,
        title: const Text('Grid Example'),
      ),
      floatingActionButton: FloatingActionButton(onPressed: setTimer),
      body: DragSelectGridView(
        scrollSpeedCallback: calculateSpeed,
        gridController: controller,
        autoScrollHotspotHeight: 64,
        padding: const EdgeInsets.all(8),
        itemCount: 500,
        itemBuilder: (context, index, selected) {
          return SelectableItem(
            index: index,
            color: Colors.blue,
            selected: selected,
          );
        },
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 150,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
      ),
    );
  }

  void scheduleRebuild() => setState(() {});
}
