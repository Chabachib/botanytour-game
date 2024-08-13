import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:myapp/screens/levels/level1_screen.dart';
import 'package:myapp/screens/levels/level2_screen.dart';
import 'package:myapp/screens/levels/level3_screen.dart';
import 'package:myapp/screens/levels/level4_screen.dart';
import 'package:myapp/screens/levels/level5_screen.dart';
import 'package:myapp/screens/levels/level6_screen.dart';
import 'package:myapp/screens/levels/level7_screen.dart';
import 'package:myapp/screens/levels/level8_screen.dart';
import 'package:myapp/screens/levels/level9_screen.dart';
import 'package:myapp/screens/levels/level10_screen.dart';
import 'package:myapp/screens/levels/level11_screen.dart';
import 'package:myapp/screens/levels/level12_screen.dart';
import 'package:myapp/screens/levels/level13_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the map associating index with the level screens
    final levelScreens = <int, Widget>{
      0: const Level1Screen(),
      1: const Level2Screen(),
      2: const Level3Screen(),
      3: const Level4Screen(),
      4: const Level5Screen(),
      5: const Level6Screen(),
      6: const Level7Screen(),
      7: const Level8Screen(),
      8: const Level9Screen(),
      9: const Level10Screen(),
      10: const Level11Screen(),
      11: const Level12Screen(),
      12: const Level13Screen(),
    };

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
                image: AssetImage('images/backgrounds/puzzle-bg.jpg'),
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
                    // Navigate to the corresponding level screen
                    final screen = levelScreens[index];
                    if (screen != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => screen),
                      );
                    }
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
