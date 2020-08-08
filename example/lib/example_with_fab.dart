import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';

import 'selectable_item.dart';
import 'selection_app_bar.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(statusBarColor: Colors.grey[200]),
  );
  runApp(
    MaterialApp(
      home: MyApp(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: onPressed,
        child: Icon(Icons.select_all),
      ),
      body: DragSelectGridView(
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
          maxCrossAxisExtent: 80,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
      ),
    );
  }

  void onPressed() => controller.selection =
      Selection({15, 20, 25, 21, 22, 17, 27, 19, 24, 29});

  void scheduleRebuild() => setState(() {});
}
