import 'package:flutter/material.dart';
import 'package:myapp/screens/plant_menu.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class IndexScreen extends StatefulWidget {
  const IndexScreen({super.key});

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  late List<Map<String, dynamic>> _backgrounds;
  late Map<String, dynamic> _currentBackground;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadBackgroundData();
  }

  Future<void> _loadBackgroundData() async {
    final jsonString =
        await rootBundle.loadString('assets/json-files/style.json');
    final data = json.decode(jsonString);

    setState(() {
      _backgrounds = List<Map<String, dynamic>>.from(data['backgrounds']);
      _currentBackground = _backgrounds[0]; // Set default background
    });
  }

  void _showBackgroundOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose a Background'),
          content: SizedBox(
            width: 300, // Adjust the width as needed
            height: 300, // Adjust the height as needed
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _backgrounds.length,
                  itemBuilder: (context, index) {
                    final background = _backgrounds[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _currentBackground = background;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(
                            8.0), // Adds padding around the image
                        child: Image.asset(
                          background['image'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  left: 0,
                  top: 50,
                  bottom: 50,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_left, size: 40),
                    onPressed: () {
                      final pageIndex = _pageController.page?.toInt() ?? 0;
                      if (pageIndex > 0) {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 50,
                  bottom: 50,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_right, size: 40),
                    onPressed: () {
                      final pageIndex = _pageController.page?.toInt() ?? 0;
                      if (pageIndex < _backgrounds.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_backgrounds.isEmpty) {
      return const Scaffold(
        body: Center(
            child:
                CircularProgressIndicator()), // Show loading indicator while data is loading
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(_currentBackground['image']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Title and Play button centered on top of the background
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'BotanyTour Game',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(int.parse(_currentBackground['themeColors']
                            ['titleColor']
                        .replaceAll('#', '0xFF'))),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PlantMenuScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(int.parse(
                        _currentBackground['themeColors']['buttonColor']
                            .replaceAll('#', '0xFF'))),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    textStyle:
                        const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  child: const Text('Play'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _showBackgroundOptions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.grey, // Color for the background change button
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    textStyle:
                        const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  child: const Text('Change Background'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
