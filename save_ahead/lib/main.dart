import 'package:flutter/material.dart';
import 'package:save_ahead/modules/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Save Ahead',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}