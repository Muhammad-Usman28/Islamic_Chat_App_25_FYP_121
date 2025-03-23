import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_user_panel/authentication/login.dart';
import 'package:fyp_user_panel/quiz_app/quiz_screen/quiz_screen.dart';
import 'package:fyp_user_panel/quiz_app/score_graph_screen/score_graph_screen.dart';
import 'package:fyp_user_panel/quiz_app/top_scorer/leader_board.dart';
import 'package:fyp_user_panel/screens/find_friend_screen.dart';
import 'package:fyp_user_panel/screens/friends_screen.dart';
import 'package:fyp_user_panel/screens/home_screen.dart';
import 'package:fyp_user_panel/screens/profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Personal Info method

  Map<String, dynamic> myPersonalData = {};

  Future<void> myPersonInfo() async {
    CollectionReference myData =
        FirebaseFirestore.instance.collection("AllUsers");

    QuerySnapshot snapshot = await myData
        .where("Email",
            isEqualTo: "${FirebaseAuth.instance.currentUser!.email}")
        .get();

    // Check if no documents are found
    if (snapshot.docs.isEmpty) {
      print("No user found with this email");
      return;
    }
    // Get the first document
    DocumentSnapshot doc = snapshot.docs.first;
    setState(
      () {
        myPersonalData = doc.data() as Map<String, dynamic>;
      },
    );
  }

  List? Screens = [
    HomeScreen(),
    FindFriendScreen(),
    FriendsScreen(),
    ProfileScreen(),
  ];
  int? index = 0;

  @override
  void initState() {
    super.initState();
    myPersonInfo().then((_) async {
      print("Data is Fetched");
    });
  }

  @override
  Widget build(BuildContext context) {
    double? height = MediaQuery.of(context).size.height;
    double? width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        drawer: Drawer(
          backgroundColor: Colors.white,
          child: Column(
            children: [
              DrawerHeader(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          NetworkImage("${myPersonalData["Avatar_Url"]}"),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    Text(
                      "${myPersonalData["First_Name"]} ${myPersonalData["Last_Name"]}"
                          .toUpperCase(),
                      style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${FirebaseAuth.instance.currentUser!.email}",
                      style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              // Buttons Section
              SizedBox(height: 20),

              // Take Quiz Button with Hover & Press Effects
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizScreen(
                          userEmail:
                              "${FirebaseAuth.instance.currentUser!.email}"),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: height * 0.06,
                  width: width * 0.6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.blue, Colors.blueAccent]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue
                            .withValues(alpha: 0.3), // 30% opacity as double
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.quiz, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Take Quiz",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 15),

              // Score Graph Button with Hover & Press Effects
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScoreBarGraphScreen(
                          userEmail:
                              "${FirebaseAuth.instance.currentUser!.email}"),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: height * 0.06,
                  width: width * 0.6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.green, Colors.greenAccent]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue
                            .withValues(alpha: 0.3), // 30% opacity as double
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Score Graph",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LeaderBoard()));
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: height * 0.06,
                  width: width * 0.6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.blue.shade800, Colors.purple.shade400]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue
                            .withValues(alpha: 0.3), // 30% opacity as double
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.military_tech, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Top Scorer",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          backgroundColor: Color(0xFFFFFFFF),
          centerTitle: true,
          title: Text(
            "Deen AI Chat App",
            style: GoogleFonts.roboto(
              fontSize: 22,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onPressed: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => Dialog(
                    backgroundColor:
                        Colors.grey[900], // Dark background for a sleek UI
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20), // Smooth rounded corners
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 60,
                            color: Colors
                                .orangeAccent, // More vibrant warning color
                          ),
                          SizedBox(height: 15),
                          Text(
                            "Logout Confirmation",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // White text for contrast
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            "Are you sure you want to log out?",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                          SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close dialog
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors
                                        .grey[700], // Dark gray cancel button
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    FirebaseAuth.instance.signOut();
                                    Navigator.pop(context); // Close dialog
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Login()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  child: Text(
                                    "Log Out",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              icon: Icon(Icons.logout, size: 28),
            ),
          ],
        ),
        body: Screens![index!],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color(0xFFFFFFFF),
          selectedItemColor: Color(0xff1F41BB),
          unselectedItemColor: Color(0xFFADB5BD),
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.search), label: "Find Friends"),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: "Friends"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
          currentIndex: index!,
          onTap: (value) {
            setState(() {
              index = value;
            });
          },
        ),
      ),
    );
  }
}
