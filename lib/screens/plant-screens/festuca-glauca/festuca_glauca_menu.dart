import 'package:flutter/material.dart';
import 'package:myapp/screens/plant-screens/festuca-glauca/festuca_glauca_quiz.dart';
import 'package:myapp/screens/plant-screens/festuca-glauca/festuca_glauca_find_the_plant.dart';
import 'package:myapp/screens/plant-screens/festuca-glauca/festuca_glauca_puzzle.dart';

class FestucaGlaucaMenuScreen extends StatelessWidget {
  const FestucaGlaucaMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Festuca glauca Vill Game Menu'),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgrounds/puzzle-bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 3,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              children: [
                _buildMenuButton(
                    context, 'Quiz', const FestucaGlaucaQuizScreen()),
                _buildMenuButton(context, 'Find the Plant',
                    const FestucaGlaucaFindThePlantScreen()),
                _buildMenuButton(context, 'Level 1 Puzzle',
                    const FestucaGlaucaPuzzleScreen()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, Widget screen) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16.0),
        textStyle: const TextStyle(fontSize: 20),
      ),
      child: Text(title),
    );
  }
}
