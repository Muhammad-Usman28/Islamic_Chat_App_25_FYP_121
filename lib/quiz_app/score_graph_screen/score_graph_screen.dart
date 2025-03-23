import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ScoreBarGraphScreen extends StatefulWidget {
  final String userEmail;
  ScoreBarGraphScreen({required this.userEmail});

  @override
  _ScoreBarGraphScreenState createState() => _ScoreBarGraphScreenState();
}

class _ScoreBarGraphScreenState extends State<ScoreBarGraphScreen> {
  List<ScoreData> scoreData = [];

  @override
  void initState() {
    super.initState();
    _getScores();
  }

  Future<void> _getScores() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('user_scores')
        .doc(widget.userEmail)
        .get();

    if (userDoc.exists) {
      List scores = userDoc['scores'];

      // Sort scores by date
      scores.sort((a, b) => a['date'].compareTo(b['date']));

      List<ScoreData> tempData = [];

      for (var score in scores) {
        DateTime date = DateTime.parse(score['date']);
        String formattedDate =
            DateFormat('MMM d').format(date); // Example: Feb 13
        tempData.add(ScoreData(formattedDate, score['score']));
      }

      setState(() {
        scoreData = tempData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Score Bar Graph")),
      body: Center(
        child: scoreData.isEmpty
            ? CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SfCartesianChart(
                  title: ChartTitle(text: "User Score Over Time"),
                  primaryXAxis: CategoryAxis(
                    title: AxisTitle(text: "Date"),
                    labelRotation: -45, // Rotate labels for better visibility
                  ),
                  primaryYAxis: NumericAxis(
                    title: AxisTitle(text: "Score"),
                    minimum: 0,
                    maximum: 1000,
                    interval: 200, // Y-axis marks every 200 points
                  ),
                  series: <CartesianSeries<ScoreData, String>>[
                    ColumnSeries<ScoreData, String>(
                      // Bar graph (Fixed type)
                      dataSource: scoreData,
                      xValueMapper: (ScoreData data, _) => data.date,
                      yValueMapper: (ScoreData data, _) => data.score,
                      dataLabelSettings: DataLabelSettings(
                          isVisible: true), // Show score values
                      color: Colors.blue, // Customize bar color
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class ScoreData {
  final String date;
  final int score;
  ScoreData(this.date, this.score);
}

// Line Graph
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

// class ScoreGraphScreen extends StatefulWidget {
//   final String userEmail;
//   ScoreGraphScreen({required this.userEmail});

//   @override
//   _ScoreGraphScreenState createState() => _ScoreGraphScreenState();
// }

// class _ScoreGraphScreenState extends State<ScoreGraphScreen> {
//   List<ScoreData> scoreData = [];

//   @override
//   void initState() {
//     super.initState();
//     _getScores();
//   }

//   Future<void> _getScores() async {
//     DocumentSnapshot userDoc = await FirebaseFirestore.instance
//         .collection('user_scores')
//         .doc(widget.userEmail)
//         .get();

//     if (userDoc.exists) {
//       List scores = userDoc['scores'];

//       // Sort scores by date
//       scores.sort((a, b) => a['date'].compareTo(b['date']));

//       List<ScoreData> tempData = [];

//       for (var score in scores) {
//         DateTime date = DateTime.parse(score['date']);
//         String formattedDate = DateFormat('MMM d').format(date); // e.g., "Feb 13"
//         tempData.add(ScoreData(formattedDate, score['score']));
//       }

//       setState(() {
//         scoreData = tempData;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Score Graph")),
//       body: Center(
//         child: scoreData.isEmpty
//             ? CircularProgressIndicator()
//             : Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: SfCartesianChart(
//                   title: ChartTitle(text: "User Score Over Time"),
//                   primaryXAxis: CategoryAxis(
//                     title: AxisTitle(text: "Date"),
//                     labelRotation: -45, // Rotates the date labels for better visibility
//                   ),
//                   primaryYAxis: NumericAxis(
//                     title: AxisTitle(text: "Score"),
//                     minimum: 0,
//                     maximum: 1000,
//                     interval: 200, // Y-axis marks every 200 points
//                   ),
//                   series: <CartesianSeries<ScoreData, String>>[
//                     LineSeries<ScoreData, String>(
//                       dataSource: scoreData,
//                       xValueMapper: (ScoreData data, _) => data.date,
//                       yValueMapper: (ScoreData data, _) => data.score,
//                       markerSettings: MarkerSettings(isVisible: true), // Show points on line
//                       dataLabelSettings: DataLabelSettings(isVisible: true), // Show score labels
//                     ),
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }
// }

// class ScoreData {
//   final String date;
//   final int score;
//   ScoreData(this.date, this.score);
// }
