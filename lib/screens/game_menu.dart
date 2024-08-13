import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:myapp/screens/plant-screens/argania-spinosa/argania_spinosa_menu.dart';
import 'package:myapp/screens/plant-screens/festuca-glauca/festuca_glauca_menu.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // List of level names
    final List<String> levelNames = [
      'Argania spinosa (L.) Skeels',
      'Festuca glauca Vill',
      'Cupressus sempervirens L.',
      'Gazania rigens (L.) Gaert',
      'Ononis natrix L',
      'Atriplex nummularia Lindl',
      'Hyoscyamus albus L.',
      'Arundo donax L.',
      'Aeonium arboreum (L.) Webb. & Berth.',
      'Thapsia transtagana Brot.',
      'Nephrolepis exaltata (L.) Schott',
      'Acanthus mollis L.',
      'Cynara scolymus L.',
    ];

    // Define the map associating index with the level menu screens
    final levelScreens = <int, Widget>{
      0: const ArganiaSpinosaMenuScreen(),
      1: const FestucaGlaucaMenuScreen(),
      // Add more screens for other levels if necessary
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Levels'),
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/backgrounds/puzzle-bg.jpg'),
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
              itemCount: levelNames
                  .length, // Number of levels based on the list length
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 buttons per row
                crossAxisSpacing: 20.0,
                mainAxisSpacing: 20.0,
              ),
              itemBuilder: (context, index) {
                return ElevatedButton(
                  onPressed: () {
                    // Navigate to the corresponding level menu screen
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
                      levelNames[index],
                      textAlign: TextAlign.center, // Center the text
                      style: const TextStyle(
                        fontSize: 16, // Adjusted font size for longer names
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
