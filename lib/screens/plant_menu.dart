import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:myapp/screens/find_the_plant.dart';
import 'package:myapp/screens/quiz.dart';
import 'package:myapp/screens/puzzle.dart';

class PlantMenuScreen extends StatefulWidget {
  const PlantMenuScreen({super.key});

  @override
  State<PlantMenuScreen> createState() => _PlantMenuScreenState();
}

class _PlantMenuScreenState extends State<PlantMenuScreen> {
  List<dynamic> plants = [];

  @override
  void initState() {
    super.initState();
    loadPlantsData();
  }

  Future<void> loadPlantsData() async {
    final String response =
        await rootBundle.loadString('json-files/plants.json');
    final data = await json.decode(response);
    setState(() {
      plants = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Menu'),
      ),
      body: plants.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: plants.length,
              itemBuilder: (context, index) {
                final plant = plants[index];
                return ListTile(
                  title: Text(plant['name']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GamePlantScreen(plantName: plant['name']),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class GamePlantScreen extends StatelessWidget {
  final String plantName;

  const GamePlantScreen({super.key, required this.plantName});

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
                context, 'Quiz', PlantQuizScreen(plantName: plantName)),
            _buildMenuButton(context, 'Find the Plant',
                FindThePlantScreen(plantName: plantName)),
            _buildMenuButton(
                context, 'Puzzle', PlantPuzzleScreen(plantName: plantName)),
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
