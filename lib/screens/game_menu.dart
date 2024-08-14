import 'package:flutter/material.dart';
import 'package:myapp/screens/find_the_plant.dart';
import 'package:myapp/screens/quiz.dart';
import 'package:myapp/screens/puzzle.dart';

class GameMenuScreen extends StatelessWidget {
  final String plantName;

  const GameMenuScreen({required this.plantName, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$plantName Game Menu'),
      ),
      body: Padding(
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
              context,
              'Quiz',
              PlantQuizScreen(plantName: plantName),
            ),
            _buildMenuButton(
              context,
              'Find the Plant',
              FindThePlantScreen(plantName: plantName),
            ),
            _buildMenuButton(
              context,
              'Puzzle',
              PlantPuzzleScreen(plantName: plantName),
            ),
          ],
        ),
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
