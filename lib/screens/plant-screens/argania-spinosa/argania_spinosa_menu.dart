import 'package:flutter/material.dart';
import 'package:myapp/screens/plant-screens/argania-spinosa/argania_spinosa_quiz.dart';
import 'package:myapp/screens/plant-screens/argania-spinosa/argania_spinosa_find_the_plant.dart';
import 'package:myapp/screens/plant-screens/argania-spinosa/argania_spinosa_puzzle.dart';

class ArganiaSpinosaMenuScreen extends StatelessWidget {
  const ArganiaSpinosaMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Argania spinosa (L.) Skeels Game Menu'),
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
                    context, 'Quiz', const ArganiaSpinosaQuizScreen()),
                _buildMenuButton(context, 'Find the Plant',
                    const ArganiaSpinosaFindThePlantScreen()),
                _buildMenuButton(context, 'Level 1 Puzzle',
                    const ArganiaSpinosaPuzzleScreen()),
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
