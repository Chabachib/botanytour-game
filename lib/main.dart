import 'package:flutter/material.dart';
import 'package:myapp/screens/puzzle_home_screen.dart'; // Import the puzzle home screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Slide Puzzle',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PuzzleHomeScreen(),
    );
  }
}
