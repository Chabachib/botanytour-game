import 'package:flutter/material.dart';
import 'package:myapp/screens/index.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BotanyTour Games',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ResponsiveWrapper(
          child:
              IndexScreen()), // Wrap the home screen with a responsive wrapper
    );
  }
}

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;

  const ResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Retrieve the screen width using MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;

    // Define breakpoints
    if (screenWidth < 600) {
      // Small screens (phones)
      return MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: child,
          ),
        ),
      );
    } else if (screenWidth >= 600 && screenWidth < 1200) {
      // Medium screens (tablets)
      return MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: child,
          ),
        ),
      );
    } else {
      // Large screens (desktops)
      return MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: child,
          ),
        ),
      );
    }
  }
}
