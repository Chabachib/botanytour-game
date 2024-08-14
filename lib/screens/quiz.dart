import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:math';

class PlantQuizScreen extends StatefulWidget {
  final String plantName;

  const PlantQuizScreen({super.key, required this.plantName});

  @override
  State<PlantQuizScreen> createState() => _PlantQuizScreenState();
}

class _PlantQuizScreenState extends State<PlantQuizScreen> {
  List<Map<String, dynamic>>? _questions;
  Map<String, dynamic>? _currentQuestion;
  String? _selectedAnswer;
  String _feedback = '';
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final String response =
          await rootBundle.loadString('json-files/quiz_questions.json');
      final data = json.decode(response);

      debugPrint('Data loaded: $data'); // Debug print

      final plant = data['plants'].firstWhere(
        (p) => p['name'] == widget.plantName,
        orElse: () => null,
      );

      if (plant == null) {
        debugPrint('Plant not found: ${widget.plantName}'); // Debug print
        return;
      }

      final List questions = plant['questions'];
      final random = Random();

      if (questions.isEmpty) {
        debugPrint(
            'No questions found for plant: ${widget.plantName}'); // Debug print
        return;
      }

      // Get 3 random questions
      final List<Map<String, dynamic>> randomQuestions = List.generate(3, (_) {
        return questions[random.nextInt(questions.length)];
      });

      setState(() {
        _questions = randomQuestions;
        _currentQuestion =
            _questions!.isNotEmpty ? _questions![_currentQuestionIndex] : null;
      });
    } catch (e) {
      debugPrint('Error loading questions: $e'); // Debug print
    }
  }

  void _submitAnswer() {
    if (_selectedAnswer == _currentQuestion!['answer']) {
      setState(() {
        _feedback = 'Correct!';
      });
    } else {
      setState(() {
        _feedback =
            'Incorrect. The correct answer is ${_currentQuestion!['answer']}';
      });
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (_currentQuestionIndex < (_questions!.length - 1)) {
        setState(() {
          _currentQuestionIndex++;
          _currentQuestion = _questions![_currentQuestionIndex];
          _selectedAnswer = null;
          _feedback = '';
        });
      } else {
        _showFinishDialog();
      }
    });
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quiz Finished'),
          content: const Text('You have completed the quiz!'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
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
    if (_currentQuestion == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final List options = _currentQuestion!['options'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1}/${_questions!.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              _currentQuestion!['question'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ...options.map((option) {
              return RadioListTile(
                title: Text(option),
                value: option,
                groupValue: _selectedAnswer,
                onChanged: (value) {
                  setState(() {
                    _selectedAnswer = value as String?;
                  });
                },
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectedAnswer == null ? null : _submitAnswer,
              child: const Text('Submit'),
            ),
            const SizedBox(height: 20),
            Text(
              _feedback,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
