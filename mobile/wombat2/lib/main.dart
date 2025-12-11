import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const MetalDetectorApp());
}

class MetalDetectorApp extends StatelessWidget {
  const MetalDetectorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Metal Detector',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const MainScreen(),
    );
  }
}