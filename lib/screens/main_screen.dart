import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_user_panel/authentication/login.dart';
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
    // double? width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        drawer: Drawer(
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
              ))
            ],
          ),
        ),
        appBar: AppBar(
          backgroundColor: Color(0xFFFFFFFF),
          centerTitle: true,
          title: Text(
            "Chat App",
            style: GoogleFonts.roboto(
              fontSize: 22,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(),
                  ),
                );
              },
              icon: Icon(Icons.logout),
            )
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
