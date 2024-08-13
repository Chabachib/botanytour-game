import 'package:flutter/material.dart';
import 'dart:ui'; // For the BackdropFilter

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Slide Puzzle'),
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/puzzle-bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Blur effect
          BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: 5.0, sigmaY: 5.0), // Adjust blur intensity
            child: Container(
              color: Colors.black
                  .withOpacity(0), // Transparent color to maintain the blur
            ),
          ),
          // Level buttons
          Center(
            child: GridView.builder(
              padding: const EdgeInsets.all(20.0),
              itemCount: 13,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 buttons per row
                crossAxisSpacing: 20.0,
                mainAxisSpacing: 20.0,
              ),
              itemBuilder: (context, index) {
                return ElevatedButton(
                  onPressed: () {
                    // Handle button press
                    // Navigate to a specific level or show a dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5da45a), // Button color
                    padding: const EdgeInsets.all(20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0), // Curvy edges
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Level ${index + 1}',
                      textAlign: TextAlign.center, // Center the text
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white, // Text color set to white
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
