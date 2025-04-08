import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart'; // Firebase options
import 'home.dart'; // Your home page

void main() async {
  // Ensures Flutter bindings are initialized before Firebase setup
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with your default options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp()); // Added const
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Added const constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartBin',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(), // Optional: const if HomePage allows
      debugShowCheckedModeBanner: false,
    );
  }
}
