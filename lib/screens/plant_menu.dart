import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/screens/game_menu.dart'; // Ensure this import is correct

class PlantMenuScreen extends StatefulWidget {
  const PlantMenuScreen({super.key});

  @override
  State<PlantMenuScreen> createState() => _PlantMenuScreenState();
}

class _PlantMenuScreenState extends State<PlantMenuScreen> {
  List<dynamic> plants = [];
  late Map<String, dynamic> _currentStyle;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadPlantsData();
    _loadSavedStyle();
  }

  Future<void> loadPlantsData() async {
    final String response =
        await rootBundle.loadString('assets/json-files/plants.json');
    final data = await json.decode(response);
    setState(() {
      plants = data;
    });
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
        title: const Text('Plant Menu'),
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
          plants.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 3, // Adjust this to change item height
                  ),
                  itemCount: plants.length,
                  itemBuilder: (context, index) {
                    final plant = plants[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                GameMenuScreen(plantName: plant['name']),
                          ),
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
                          plant['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
