import 'package:flutter/material.dart';
import 'package:myapp/screens/plant_menu.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({super.key});

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  late List<Map<String, dynamic>> _styles;
  late Map<String, dynamic> _currentStyle;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadStyleData();
  }

  Future<void> _loadStyleData() async {
    final jsonString =
        await rootBundle.loadString('assets/json-files/style.json');
    final data = json.decode(jsonString);

    setState(() {
      _styles = List<Map<String, dynamic>>.from(data['styles']);
    });

    _loadSavedStyle(); // Load the saved style after loading the styles data
  }

  Future<void> _loadSavedStyle() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStyleIndex = prefs.getInt('selectedStyleIndex') ?? 0;
    setState(() {
      _currentStyle = _styles[
          savedStyleIndex]; // Load the saved style or default to first one
    });
  }

  Future<void> _saveStyle(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedStyleIndex', index);
  }

  void _showStyleOptions() {
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
                  itemCount: _styles.length,
                  itemBuilder: (context, index) {
                    final style = _styles[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _currentStyle = style;
                        });
                        _saveStyle(index); // Save the selected style index
                      },
                      child: Container(
                        padding: const EdgeInsets.all(
                            8.0), // Adds padding around the image
                        child: Image.asset(
                          style['backgroundImage'],
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
                      if (pageIndex < _styles.length - 1) {
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
    if (_styles.isEmpty) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(), // Show loading indicator while data is loading
        ),
      );
    }

    // Extract the button text color from the current style
    final buttonTextColor =
        _currentStyle['themeColors'].containsKey('buttonTextColor')
            ? Color(int.parse(_currentStyle['themeColors']['buttonTextColor']
                .replaceAll('#', '0xFF')))
            : Colors.black; // Default color if buttonTextColor is not provided

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(_currentStyle['backgroundImage']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Title positioned higher on the page
          Positioned(
            top: 150, // Adjust this value to move the title higher or lower
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: Stack(
                children: [
                  // Outline of the title
                  Text(
                    'BotanyTour Games',
                    style: TextStyle(
                      fontFamily: 'Billanta', // Use the custom font
                      fontSize: 60,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 6
                        ..color = Colors.black, // Outline color
                    ),
                  ),
                  // Title itself
                  Text(
                    'BotanyTour Games',
                    style: TextStyle(
                      fontFamily: 'Billanta', // Use the custom font
                      fontSize: 60,
                      color: Color(int.parse(_currentStyle['themeColors']
                              ['titleColor']
                          .replaceAll('#', '0xFF'))),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Buttons centered on the page
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 220, // Set a consistent width for all buttons
                  height: 50, // Set a consistent height for all buttons
                  child: ElevatedButton(
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
                          _currentStyle['themeColors']['buttonColor']
                              .replaceAll(
                                  '#', '0xFF'))), // Button background color
                      foregroundColor: buttonTextColor, // Button text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Curved edges
                        side: const BorderSide(
                            color: Colors.black,
                            width: 1), // Thin black outline
                      ),
                    ),
                    child: const Text(
                      'Play',
                      style: TextStyle(
                        fontFamily: 'Billanta', // Custom font
                        fontSize: 30, // Text size
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 220, // Set a consistent width for all buttons
                  height: 50, // Set a consistent height for all buttons
                  child: ElevatedButton(
                    onPressed: _showStyleOptions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(int.parse(
                          _currentStyle['themeColors']['buttonColor']
                              .replaceAll(
                                  '#', '0xFF'))), // Button background color
                      foregroundColor: buttonTextColor, // Button text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Curved edges
                        side: const BorderSide(
                            color: Colors.black,
                            width: 1), // Thin black outline
                      ),
                    ),
                    child: const Text(
                      'Change Background',
                      style: TextStyle(
                        fontFamily: 'Billanta', // Custom font
                        fontSize: 28, // Text size
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
