import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:math';

class ArganiaSpinosaQuizScreen extends StatefulWidget {
  const ArganiaSpinosaQuizScreen({super.key});

  @override
  State<ArganiaSpinosaQuizScreen> createState() =>
      _ArganiaSpinosaQuizScreenState();
}

class _ArganiaSpinosaQuizScreenState extends State<ArganiaSpinosaQuizScreen> {
  Map<String, dynamic>? _currentQuestion;
  String? _selectedAnswer;
  String _feedback = '';

  @override
  void initState() {
    super.initState();
    _loadRandomQuestion();
  }

  Future<void> _loadRandomQuestion() async {
    try {
      final String response =
          await rootBundle.loadString('assets/quiz_questions.json');
      final List data = json.decode(response);
      final random = Random();
      setState(() {
        _currentQuestion = data[random.nextInt(data.length)];
      });
    } catch (e) {
      debugPrint('Error loading questions: $e');
    }
  }

  void _submitAnswer() {
    if (_selectedAnswer == _currentQuestion!['correctAnswer']) {
      setState(() {
        _feedback = 'Correct!';
      });
    } else {
      setState(() {
        _feedback =
            'Incorrect. The correct answer is ${_currentQuestion!['correctAnswer']}';
      });
    }

    Future.delayed(const Duration(seconds: 2), () {
      _showFinishDialog();
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
            const Text(
              'Random Question',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
