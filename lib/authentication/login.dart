import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  // Controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Sign In Function

  Future<void> Sign_In(BuildContext context) async {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);
        emailController.clear();
        passwordController.clear();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${e}"),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color(0xff1F41BB),
          content: Text(
            "Please Fill out all Fields",
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double? height = MediaQuery.of(context).size.height;
    double? width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          height: height * 0.9,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: height * 0.07,
                ),
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
                SizedBox(
                  height: height * 0.03,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: height * 0.35,
                      width: width * 0.8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                            "assets/images/admin.png",
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: height * 0.01,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomFieldsForAuth(
                      icon: Icon(Icons.email),
                      label_txt: "Enter Your Email",
                      controller: emailController,
                      isHidden: false,
                      height: 0.06,
                      width: 0.8,
                      shadowColor: Colors.grey,
                    ),
                  ],
                ),
                SizedBox(
                  height: height * 0.03,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomFieldsForAuth(
                      icon: Icon(
                        Icons.lock,
                      ),
                      label_txt: "Enter Your Password",
                      controller: passwordController,
                      isHidden: true,
                      height: 0.06,
                      width: 0.8,
                      shadowColor: Colors.grey,
                    ),
                  ],
                ),
                SizedBox(
                  height: height * 0.04,
                ),
                ButtonForAuth(
                  height: 0.06,
                  width: 0.8,
                  border_color: Color(0xff1F41BB),
                  background_color: Color(0xff1F41BB),
                  text: "Sign in".toUpperCase(),
                  text_color: Colors.white,
                  shadowColor: Color(0xff1F41BB),
                  my_fun: () => Sign_In(context),
                ),
                SizedBox(
                  height: height * 0.04,
                ),
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
                      MaterialPageRoute(
                        builder: (context) => Signup(),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
