import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FindThePlantScreen extends StatefulWidget {
  final String plantName;

  const FindThePlantScreen({super.key, required this.plantName});

  @override
  State<FindThePlantScreen> createState() => _FindThePlantScreenState();
}

class _FindThePlantScreenState extends State<FindThePlantScreen> {
  String _backgroundImage = ''; // Initialize with an empty string
  String _plantImage = ''; // Initialize with an empty string
  double _leftPosition = 0;
  double _topPosition = 0;

  @override
  void initState() {
    super.initState();
    _loadPlantData();
    _randomizePlantPosition();
  }

  Future<void> _loadPlantData() async {
    try {
      final String response =
          await rootBundle.loadString('assets/json-files/plants.json');
      final List<dynamic> data = json.decode(response);
      final plant = data.firstWhere(
        (p) => p['name'] == widget.plantName,
        orElse: () => null,
      );

      if (plant != null) {
        setState(() {
          _backgroundImage = plant['wallpaper'];
          _plantImage = plant['find-plant-image'];
        });
      }
    } catch (e) {
      debugPrint('Error loading plant data: $e');
    }
  }

  void _randomizePlantPosition() {
    final random = Random();
    // Generate random positions within the screen's bounds
    _leftPosition = random.nextDouble() * 200; // Adjust the 200 value as needed
    _topPosition = random.nextDouble() * 400; // Adjust the 400 value as needed
  }

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
    if (_backgroundImage.isEmpty || _plantImage.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Find the Plant'),
        ),
        body: const Center(
          child:
              CircularProgressIndicator(), // Show loading indicator while data is loading
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find the Plant'),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              _backgroundImage,
              fit: BoxFit.cover,
            ),
          ),
          // Plant object
          Positioned(
            left: _leftPosition,
            top: _topPosition,
            child: GestureDetector(
              onTap: () => _showWinDialog(context),
              child: Opacity(
                opacity: 0.15, // Set transparency here (0.0 to 1.0)
                child: Image.asset(
                  _plantImage,
                  width: 75, // Set the size of the plant image (smaller)
                  height: 75,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
