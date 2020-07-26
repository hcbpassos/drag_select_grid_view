import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';

import 'selectable_item.dart';
import 'selection_app_bar.dart';

void main() {
  runApp(
    MaterialApp(
      home: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(statusBarColor: Colors.grey[200]),
        child: MyApp(),
      ),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
        accentColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(elevation: 2),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SelectionAppBar(
        selection: controller.selection,
        title: const Text('Grid Example'),
      ),
      body: PageView(
        children: [
          Column(
            children: [
              Center(
                child: Text('first page'),
              )
            ],
          ),
          DragSelectGridView(
            gridController: controller,
            padding: const EdgeInsets.all(8),
            itemCount: 90,
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
        ],
      ),
    );
  }

  void scheduleRebuild() => setState(() {});
}
