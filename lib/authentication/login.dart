import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_user_panel/authentication/forgot_password.dart';
import 'package:fyp_user_panel/authentication/signup.dart';
import 'package:fyp_user_panel/screens/main_screen.dart';
import 'package:fyp_user_panel/widgets/button_for_auth.dart';
import 'package:fyp_user_panel/widgets/custom_fields_for_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signIn(BuildContext context) async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showErrorMessage("Please enter email and password");
      return;
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      emailController.clear();
      passwordController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Sign in Successfully",
            style:
                GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Enter correct email or password";

      if (e.code == 'user-not-found') {
        errorMessage = "No user found for this email";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email format";
      }

      showErrorMessage(errorMessage);
    }
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: height * 0.07),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Login here",
                    style: GoogleFonts.poppins(
                      color: Color(0xff1F41BB),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.03),
              Container(
                height: height * 0.35,
                width: width * 0.8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage("assets/images/admin.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: height * 0.01),
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
              CustomFieldsForAuth(
                icon: Icon(Icons.lock),
                label_txt: "Enter Your Password",
                controller: passwordController,
                isHidden: true,
                height: 0.06,
                width: 0.8,
                shadowColor: Colors.grey,
              ),
              SizedBox(height: height * 0.02),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ForgotPassword()),
                  );
                },
                child: Text(
                  "Forgot Password?",
                  style: GoogleFonts.poppins(
                    color: Color(0xff1F41BB),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: height * 0.04),
              ButtonForAuth(
                height: 0.06,
                width: 0.8,
                border_color: Color(0xff1F41BB),
                background_color: Color(0xff1F41BB),
                text: "Sign in".toUpperCase(),
                text_color: Colors.white,
                shadowColor: Color(0xff1F41BB),
                my_fun: () => signIn(context),
              ),
              SizedBox(height: height * 0.04),
              ButtonForAuth(
                height: 0.06,
                width: 0.8,
                border_color: Color(0xff1F41BB),
                background_color: Colors.white,
                text: "Sign Up".toUpperCase(),
                text_color: Colors.black,
                shadowColor: Colors.grey,
                my_fun: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Signup()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
