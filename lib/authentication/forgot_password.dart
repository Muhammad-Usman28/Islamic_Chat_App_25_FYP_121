import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_user_panel/widgets/button_for_auth.dart';
import 'package:fyp_user_panel/widgets/custom_fields_for_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login.dart'; // Import Login screen

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword>
    with SingleTickerProviderStateMixin {
  TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> resetPassword() async {
    String email = emailController.text.trim().toLowerCase();

    if (email.isEmpty) {
      showMessage("Please enter your email", Colors.red);
      return;
    }

    try {
      // Check if email exists in Firestore (AllUsers collection)
      DocumentSnapshot userDoc =
          await _firestore.collection("AllUsers").doc(email).get();

      if (!userDoc.exists) {
        showMessage(
            "Email not found. Please enter a registered email.", Colors.red);
        return;
      }

      // If email exists, send reset link
      await _auth.sendPasswordResetEmail(email: email);
      showMessage("Password reset link sent! Check your email.", Colors.green);

      // Navigate to Login screen after a short delay
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Something went wrong";

      if (e.code == 'invalid-email') {
        errorMessage = "Invalid email format";
      }

      showMessage(errorMessage, Colors.red);
    }
  }

  void showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: color,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.1),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: height * 0.07),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Forgot Password",
                      style: GoogleFonts.poppins(
                        color: Color(0xff1F41BB),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: height * 0.1,
                ),
                Container(
                  height: height * 0.3,
                  width: width * 0.8,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/forgot_password.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.03),
                Text(
                  "Enter your email to reset your password",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: height * 0.04),
                CustomFieldsForAuth(
                  icon: Icon(Icons.email),
                  label_txt: "Enter Your Email",
                  controller: emailController,
                  isHidden: false,
                  height: 0.06,
                  width: 0.8,
                  shadowColor: Colors.grey,
                ),
                SizedBox(height: height * 0.03),
                ButtonForAuth(
                  height: 0.06,
                  width: 0.8,
                  border_color: Color(0xff1F41BB),
                  background_color: Color(0xff1F41BB),
                  text: "Send reset Link".toUpperCase(),
                  text_color: Colors.white,
                  shadowColor: Color(0xff1F41BB),
                  my_fun: () => resetPassword(),
                ),
                SizedBox(height: height * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
