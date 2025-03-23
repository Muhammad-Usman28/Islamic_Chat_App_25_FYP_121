import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizScreen extends StatefulWidget {
  final String userEmail;
  QuizScreen({required this.userEmail});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  Timer? _timer;
  int _timeLeft = 30;
  String? _selectedOption;
  bool _showAnswerFeedback = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('questions').get();

    List<Map<String, dynamic>> questions = snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'question': doc['question'],
        'options': List<String>.from(doc['options']),
        'correctOption': doc['correctOption']
      };
    }).toList();

    questions.shuffle();
    for (var question in questions) {
      question['options'].shuffle();
    }

    setState(() {
      _questions = questions;
      _currentQuestionIndex = 0;
      _score = 0;
      _selectedOption = null;
      _showAnswerFeedback = false;
    });

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _timeLeft = 30;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
        _nextQuestion();
      }
    });
  }

  void _answerQuestion(String selectedOption) {
    setState(() {
      _selectedOption = selectedOption;
      _showAnswerFeedback = true;
    });

    if (_questions[_currentQuestionIndex]['correctOption'] == selectedOption) {
      setState(() {
        _score += 10;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("🎉 Correct! +10 Points", style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ));

      _updateUserScore();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("❌ Wrong Answer!", style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
      ));
    }

    Future.delayed(Duration(seconds: 1), _nextQuestion);
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOption = null;
        _showAnswerFeedback = false;
      });
      _startTimer();
    } else {
      _timer?.cancel();
      _showCompletionDialog();
    }
  }

  Future<void> _updateUserScore() async {
    String today = DateTime.now().toIso8601String().split("T")[0];

    DocumentReference userDoc = FirebaseFirestore.instance
        .collection('user_scores')
        .doc(widget.userEmail);

    DocumentSnapshot userSnapshot = await userDoc.get();

    if (userSnapshot.exists) {
      List scores = userSnapshot['scores'];
      int index = scores.indexWhere((s) => s['date'] == today);
      if (index != -1) {
        scores[index]['score'] += 10;
      } else {
        scores.add({"date": today, "score": 10});
      }
      await userDoc.update({'scores': scores});
    } else {
      await userDoc.set({
        'scores': [
          {"date": today, "score": 10}
        ]
      });
    }
  }

  void _showCompletionDialog() {
    _timer?.cancel();

    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      title: "🎉 Quiz Completed!",
      desc: "Your total score: $_score points",
      btnOkText: "Play Again",
      btnOkColor: Colors.green,
      btnOkOnPress: () => _restartQuiz(),
      btnCancelText: "Exit",
      btnCancelColor: Colors.red,
      btnCancelOnPress: () => Navigator.pop(context),
    ).show();
  }

  void _restartQuiz() {
    setState(() {
      _score = 0;
      _currentQuestionIndex = 0;
      _selectedOption = null;
      _showAnswerFeedback = false;
    });
    _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) return Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz Time 🧠"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade800, Colors.purple.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.purple.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Question ${_currentQuestionIndex + 1} / ${_questions.length}",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                SizedBox(height: 10),

                // **Progress Bar**
                LinearProgressIndicator(
                  value: _timeLeft / 30,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation(
                      _timeLeft > 10 ? Colors.green : Colors.red),
                ),
                SizedBox(height: 10),

                // **Countdown Timer Display**
                Text(
                  "⏳ Time Left: $_timeLeft sec",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),

                SizedBox(height: 20),

                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 10,
                  color: Colors.white.withOpacity(0.2),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          _questions[_currentQuestionIndex]['question'],
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        ..._questions[_currentQuestionIndex]['options']
                            .map<Widget>((option) {
                          return GestureDetector(
                            onTap: _showAnswerFeedback
                                ? null
                                : () => _answerQuestion(option),
                            child: Card(
                              color: Colors.white.withOpacity(0.9),
                              child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Center(
                                      child: Text(option,
                                          style: TextStyle(fontSize: 18)))),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Date with quiz
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart'; // Import for date formatting

// class QuizScreen extends StatefulWidget {
//   final String userEmail;
//   QuizScreen({required this.userEmail});

//   @override
//   _QuizScreenState createState() => _QuizScreenState();
// }

// class _QuizScreenState extends State<QuizScreen> {
//   List<Map<String, dynamic>> _questions = [];
//   int _currentQuestionIndex = 0;
//   int _score = 0;
//   DateTime _selectedDate = DateTime.now(); // Store selected date

//   @override
//   void initState() {
//     super.initState();
//     _loadQuestions();
//   }

//   Future<void> _loadQuestions() async {
//     QuerySnapshot snapshot =
//         await FirebaseFirestore.instance.collection('questions').get();

//     List<Map<String, dynamic>> questions = snapshot.docs.map((doc) {
//       return {
//         'id': doc.id,
//         'question': doc['question'],
//         'options': List<String>.from(doc['options']),
//         'correctOption': doc['correctOption']
//       };
//     }).toList();

//     questions.shuffle();
//     setState(() {
//       _questions = questions;
//     });
//   }

//   void _answerQuestion(String selectedOption) async {
//     if (_questions[_currentQuestionIndex]['correctOption'] == selectedOption) {
//       _score += 10;
//       _updateUserScore();
//     }

//     if (_currentQuestionIndex < _questions.length - 1) {
//       setState(() => _currentQuestionIndex++);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Quiz Completed! Score: $_score")));
//     }
//   }

//   Future<void> _updateUserScore() async {
//     String formattedDate =
//         DateFormat('yyyy-MM-dd').format(_selectedDate); // Format selected date

//     DocumentReference userDoc = FirebaseFirestore.instance
//         .collection('user_scores')
//         .doc(widget.userEmail);

//     DocumentSnapshot userSnapshot = await userDoc.get();

//     if (userSnapshot.exists) {
//       List scores = userSnapshot['scores'];
//       int index = scores.indexWhere((s) => s['date'] == formattedDate);
//       if (index != -1) {
//         scores[index]['score'] += 10; // Add score to the selected date
//       } else {
//         scores.add({"date": formattedDate, "score": 10});
//       }
//       await userDoc.update({'scores': scores});
//     } else {
//       await userDoc.set({
//         'scores': [
//           {"date": formattedDate, "score": 10}
//         ]
//       });
//     }
//   }

//   void _pickDate() async {
//     DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime(2020), // Set a reasonable start date
//       lastDate: DateTime.now(), // Prevent selecting future dates
//     );

//     if (pickedDate != null) {
//       setState(() {
//         _selectedDate = pickedDate;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_questions.isEmpty) return Center(child: CircularProgressIndicator());

//     return Scaffold(
//       appBar: AppBar(title: Text("Quiz")),
//       body: Column(
//         children: [
//           Text(
//               "Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}"),
//           ElevatedButton(
//             onPressed: _pickDate,
//             child: Text("Select Date"),
//           ),
//           Text(_questions[_currentQuestionIndex]['question'],
//               style: TextStyle(fontSize: 18)),
//           ..._questions[_currentQuestionIndex]['options'].map<Widget>((option) {
//             return ElevatedButton(
//               onPressed: () => _answerQuestion(option),
//               child: Text(option),
//             );
//           }).toList(),
//         ],
//       ),
//     );
//   }
// }
