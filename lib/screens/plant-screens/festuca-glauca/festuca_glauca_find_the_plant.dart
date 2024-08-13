import 'package:flutter/material.dart';

class FestucaGlaucaFindThePlantScreen extends StatelessWidget {
  const FestucaGlaucaFindThePlantScreen({super.key});

  void _showWinDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Congratulations!'),
          content: const Text('You found the plant!'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Go back to the menu screen
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find the Plant'),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgrounds/puzzle-bg.jpg', // Use your desired background image
              fit: BoxFit.cover,
            ),
          ),
          // Plant object
          Positioned(
            left:
                100, // Adjust these values to position the plant on the screen
            top: 150,
            child: GestureDetector(
              onTap: () => _showWinDialog(context),
              child: Image.asset(
                'assets/plant.png', // Use your desired plant image
                width: 100, // Adjust size as needed
                height: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
