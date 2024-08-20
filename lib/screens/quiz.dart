import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

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
  late Map<String, dynamic> _currentStyle;
  bool _loading = true;
  int _correctAnswers = 0; // Track correct answers

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _loadStyle(); // Load the style data
  }

  Future<void> _loadQuestions() async {
    try {
      final String response =
          await rootBundle.loadString('assets/json-files/quiz_questions.json');
      final data = json.decode(response);

      final plant = data['plants'].firstWhere(
        (p) => p['name'] == widget.plantName,
        orElse: () => null,
      );

      if (plant == null) {
        return;
      }

      final List questions = plant['questions'];
      final random = Random();

      if (questions.isEmpty) {
        return;
      }

      // Get 3 random questions
      final List<Map<String, dynamic>> randomQuestions = List.generate(3, (_) {
        return questions[random.nextInt(questions.length)];
      });

      if (mounted) {
        setState(() {
          _questions = randomQuestions;
          _currentQuestion = _questions!.isNotEmpty
              ? _questions![_currentQuestionIndex]
              : null;
        });
      }
    } catch (e) {
      debugPrint('Error loading questions: $e'); // Debug print
    }
  }

  Future<void> _loadStyle() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/json-files/style.json');
      final data = json.decode(jsonString);
      final styles = List<Map<String, dynamic>>.from(data['styles']);

      final prefs = await SharedPreferences.getInstance();
      final savedStyleIndex = prefs.getInt('selectedStyleIndex') ?? 0;

      if (mounted) {
        setState(() {
          _currentStyle = styles.firstWhere(
              (style) => style['id'] == savedStyleIndex + 1,
              orElse: () => styles.first);
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading style: $e');
    }
  }

  void _submitAnswer() {
    if (_selectedAnswer == _currentQuestion!['answer']) {
      setState(() {
        _feedback = 'Correct! ✅';
        _correctAnswers++; // Increment correct answers
      });
    } else {
      setState(() {
        _feedback = 'Wrong Answer! ❌';
      });
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (_currentQuestionIndex < (_questions!.length - 1)) {
        if (mounted) {
          setState(() {
            _currentQuestionIndex++;
            _currentQuestion = _questions![_currentQuestionIndex];
            _selectedAnswer = null;
            _feedback = '';
          });
        }
      } else {
        _showFinishDialog();
      }
    });
  }

  Future<void> _showFinishDialog() async {
    bool allCorrect = _correctAnswers == _questions!.length;

    if (allCorrect) {
      // Update the completion status for the specific plant if all answers were correct
      final prefs = await SharedPreferences.getInstance();
      int stars = prefs.getInt('${widget.plantName}_stars') ?? 0;
      prefs.setInt('${widget.plantName}_stars', stars + 1);
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Quiz Finished'),
            content: Text(
              allCorrect
                  ? 'You have completed the quiz with all correct answers! ⭐'
                  : 'You have completed the quiz.',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    }
  }

  Color _getButtonColor(String option) {
    if (_selectedAnswer == null) return Colors.white; // Default color

    if (_feedback.startsWith('Correct') && option == _selectedAnswer) {
      return Colors.green; // Correct answer
    }
    if (_feedback.startsWith('Wrong') && option == _selectedAnswer) {
      return Colors.red; // Incorrect answer
    }
    return Colors.white; // Default color
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Outlined container for the question with the counter
                Container(
                  padding: const EdgeInsets.all(16.0),
                  width:
                      double.infinity, // Ensures the container takes full width
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    border: Border.all(
                      color: Colors.black, // Border color
                      width: 2.0, // Border width
                    ),
                    borderRadius: BorderRadius.circular(8.0), // Rounded corners
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Question counter
                      Text(
                        'Question ${_currentQuestionIndex + 1}/${_questions!.length}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      // Question text
                      Text(
                        _currentQuestion!['question'],
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center, // Center text horizontally
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Answer options
                ...options.map((option) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10.0),
                    decoration: BoxDecoration(
                      color: _getButtonColor(option),
                      border: Border.all(
                        color: Colors.black, // Border color
                        width: 2.0, // Border width
                      ),
                      borderRadius:
                          BorderRadius.circular(8.0), // Rounded corners
                    ),
                    child: RadioListTile(
                      title: Text(option),
                      value: option,
                      groupValue: _selectedAnswer,
                      onChanged: (value) {
                        setState(() {
                          _selectedAnswer = value as String?;
                        });
                      },
                    ),
                  );
                }),
                const SizedBox(height: 20),
                // Centered Submit button
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black, // Border color
                        width: 2.0, // Border width
                      ),
                      borderRadius:
                          BorderRadius.circular(8.0), // Rounded corners
                    ),
                    child: ElevatedButton(
                      onPressed: _selectedAnswer == null ? null : _submitAnswer,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(16.0), // Text color
                        elevation: 0, // Remove elevation/shadow
                      ),
                      child: const Text('Submit'),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Feedback container
                if (_feedback.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    width: double
                        .infinity, // Ensures the container takes full width
                    decoration: BoxDecoration(
                      color: _feedback.startsWith('Correct')
                          ? Colors.green
                          : Colors.red,
                      border: Border.all(
                        color: Colors.black, // Border color
                        width: 2.0, // Border width
                      ),
                      borderRadius:
                          BorderRadius.circular(8.0), // Rounded corners
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Feedback text and icon
                        Icon(
                          _feedback.startsWith('Correct')
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          _feedback,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                      ],
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
