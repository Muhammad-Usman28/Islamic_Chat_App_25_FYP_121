import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_user_panel/authentication/login.dart';
import 'package:fyp_user_panel/screens/home_screen.dart';

class Authstream extends StatefulWidget {
  const Authstream({super.key});

  @override
  State<Authstream> createState() => _AuthstreamState();
}

class _AuthstreamState extends State<Authstream> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          } else {
            bool user = snapshot.data != null;

            if (user == true) {
              return HomeScreen();
            } else {
              return Login();
            }
          }
        });
  }
}
