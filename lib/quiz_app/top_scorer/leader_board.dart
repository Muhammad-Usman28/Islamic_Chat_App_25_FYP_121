import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LeaderBoard extends StatefulWidget {
  const LeaderBoard({super.key});

  @override
  State<LeaderBoard> createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {
  List<Map<String, dynamic>> _scores = [];
  bool _isDescending = true; // To track sorting order

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(), // Call the interactive app bar
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.purple.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('user_scores').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            var scores = snapshot.data!.docs.map((doc) {
              return {
                'email': doc.id,
                'score': doc['scores'].last['score'],
              };
            }).toList();

            // Sort based on user selection
            scores.sort((a, b) => _isDescending
                ? b['score'].compareTo(a['score'])
                : a['score'].compareTo(b['score']));

            _scores =
                scores.take(5).toList(); // Take top 5 scorers for the chart

            return Column(
              children: [
                SizedBox(height: 10),
                Text(
                  "Top 5 Scorers 📊",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 10),
                _buildBarChart(), // Call the bar chart widget
                Expanded(
                  child: ListView(
                    children: scores.map((data) {
                      return Card(
                        color: Colors.white.withOpacity(0.9),
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.purple.shade400,
                            child: Text(
                              "${scores.indexOf(data) + 1}",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(data['email'],
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                          trailing: Text("${data['score']} points",
                              style: TextStyle(fontSize: 18)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 🎨 Interactive AppBar
  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      title: Text("Leaderboard 🏆",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade800, Colors.purple.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: [
        // Sort Button
        DropdownButton<bool>(
          value: _isDescending,
          icon: Icon(Icons.sort, color: Colors.white),
          underline: SizedBox(),
          dropdownColor: Colors.purple.shade400,
          items: [
            DropdownMenuItem(
                value: true,
                child: Text("Highest First",
                    style: TextStyle(color: Colors.white, fontSize: 12))),
            DropdownMenuItem(
                value: false,
                child: Text("Lowest First",
                    style: TextStyle(color: Colors.white, fontSize: 12))),
          ],
          onChanged: (value) {
            setState(() {
              _isDescending = value!;
            });
          },
        ),
      ],
    );
  }

  /// 📊 Method to build the bar chart
  Widget _buildBarChart() {
    double maxScore = _scores.isNotEmpty
        ? (_scores.map((e) => e['score']).reduce((a, b) => a > b ? a : b) + 10)
            .toDouble()
        : 100;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(12),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxScore, // Dynamically calculated maxY
            barGroups: _scores.asMap().entries.map((entry) {
              int index = entry.key;
              var data = entry.value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: data['score'].toDouble(),
                    color: Colors
                        .purple.shade400, // Changed to a more appealing color
                    width: 16,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              );
            }).toList(),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value < _scores.length) {
                      return Text(
                        _scores[value.toInt()]['email'].split("@")[0],
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      );
                    }
                    return Container();
                  },
                ),
              ),
            ),
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }
}
