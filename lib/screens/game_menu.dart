import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/screens/find_the_plant.dart';
import 'package:myapp/screens/quiz.dart';
import 'package:myapp/screens/puzzle.dart';

class GameMenuScreen extends StatefulWidget {
  final String plantName;

  const GameMenuScreen({required this.plantName, super.key});

  @override
  State<GameMenuScreen> createState() => _GameMenuScreenState();
}

class _GameMenuScreenState extends State<GameMenuScreen> {
  late Map<String, dynamic> _currentStyle;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedStyle();
  }

  Future<void> _loadSavedStyle() async {
    final jsonString =
        await rootBundle.loadString('assets/json-files/style.json');
    final data = json.decode(jsonString);
    final styles = List<Map<String, dynamic>>.from(data['styles']);

    final prefs = await SharedPreferences.getInstance();
    final savedStyleIndex = prefs.getInt('selectedStyleIndex') ?? 0;

    setState(() {
      _currentStyle = styles.firstWhere(
          (style) => style['id'] == savedStyleIndex + 1,
          orElse: () => styles.first);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.plantName} Game Menu'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(_currentStyle['backgroundImage']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0), // Transparent layer
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1, // Set to 1 for single column
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 3, // Adjust to control item height
              ),
              itemCount: 3,
              itemBuilder: (context, index) {
                final titles = ['Quiz', 'Find the Plant', 'Puzzle'];
                final screens = [
                  PlantQuizScreen(plantName: widget.plantName),
                  FindThePlantScreen(plantName: widget.plantName),
                  PlantPuzzleScreen(plantName: widget.plantName),
                ];
                return _buildMenuButton(
                  context,
                  titles[index],
                  screens[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18, // Match text size from PlantMenuScreen
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
