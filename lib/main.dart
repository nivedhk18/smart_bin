import 'package:flutter/material.dart';

import 'home.dart'; // Import the home page

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartBin',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(), // Set HomePage as the initial screen
      debugShowCheckedModeBanner: false,
    );
  }
}
