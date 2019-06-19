import 'dart:io';

import 'package:flutter/material.dart';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    changeStatusBarColorIfIsAndroid();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.white,
        accentColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(elevation: 1),
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Drag Select Grid View Sample'),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            dragSelectGridView(),
            autoScrollHotspotIndicator(isUpperHotspot: true),
            autoScrollHotspotIndicator(isUpperHotspot: false),
          ],
        ),
      ),
    );
  }

  Positioned autoScrollHotspotIndicator({@required bool isUpperHotspot}) {
    return Positioned(
      top: isUpperHotspot ? 0 : null,
      right: 0,
      bottom: isUpperHotspot ? null : 0,
      left: 0,
      height: DragSelectGridView.defaultAutoScrollHotspotHeight,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300].withOpacity(0.5),
        ),
      ),
    );
  }

  DragSelectGridView dragSelectGridView() {
    return DragSelectGridView(
      grid: GridView.extent(
        controller: ScrollController(),
        maxCrossAxisExtent: 150,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        padding: EdgeInsets.all(8),
        children: List.generate(90, gridViewItem),
      ),
    );
  }

  Widget gridViewItem(int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: Colors.blue,
      ),
      child: Center(
        child: Text(
          'Item\n#$index',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
      ),
    );
  }

  void changeStatusBarColorIfIsAndroid() {
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.grey[200]),
      );
    }
  }
}
