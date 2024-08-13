import 'package:flutter/material.dart';
import 'package:myapp/screens/game_screen.dart';

class PuzzleHomeScreen extends StatelessWidget {
  const PuzzleHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          // Title and Play button centered on top of the background
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Botany Puzzle',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0c2d0e), // Updated color
                  ),
                ),
                const SizedBox(height: 20), // Adds spacing between title and button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GameScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  child: const Text('Play'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
