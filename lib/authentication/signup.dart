import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_user_panel/authentication/login.dart';
import 'package:fyp_user_panel/constants/app_const.dart';
import 'package:fyp_user_panel/widgets/button_for_auth.dart';
import 'package:fyp_user_panel/widgets/custom_fields_for_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  // Controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

  String? url;
  int? selectedIndex;

  void showMessage(String message, {Color backgroundColor = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> signUp() async {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      showMessage("Please fill out all fields.");
      return;
    }

    if (passwordController.text.length < 8) {
      showMessage("Password must be at least 8 characters long.");
      return;
    }

    if (url == null) {
      showMessage("Please select your avatar.");
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection("AllUsers")
          .doc(emailController.text.trim())
          .set({
        "Email": emailController.text.trim().toLowerCase(),
        "First_Name": firstNameController.text.trim().toLowerCase(),
        "Last_Name": lastNameController.text.trim().toLowerCase(),
        "Avatar_Url": url,
      });

      emailController.clear();
      passwordController.clear();
      firstNameController.clear();
      lastNameController.clear();

      showMessage("Sign Up Successful!", backgroundColor: Colors.green);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showMessage("Email is already in use. Try another one.");
      } else {
        showMessage(e.message ?? "An error occurred. Please try again.");
      }
    }
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
              SizedBox(height: height * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Create Account",
                    style: GoogleFonts.poppins(
                      color: Color(0xff1F41BB),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.05),
              Container(
                height: height * 0.21,
                width: width * 0.8,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    crossAxisCount: 3,
                  ),
                  itemCount: AppConst.avatar.length,
                  itemBuilder: (context, index) {
                    bool isSelected = index == selectedIndex;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                          url = AppConst.avatar[index]["ImageURL"];
                        });
                      },
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? Color(0xff1F41BB)
                                : Colors.transparent,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Image.network(
                          "${AppConst.avatar[index]["ImageURL"]}",
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: height * 0.03),
              CustomFieldsForAuth(
                icon: Icon(Icons.person),
                label_txt: "Enter Your First Name",
                controller: firstNameController,
                isHidden: false,
                height: 0.06,
                width: 0.8,
                shadowColor: Colors.grey,
              ),
              SizedBox(height: height * 0.03),
              CustomFieldsForAuth(
                icon: Icon(Icons.person),
                label_txt: "Enter Your Last Name",
                controller: lastNameController,
                isHidden: false,
                height: 0.06,
                width: 0.8,
                shadowColor: Colors.grey,
              ),
              SizedBox(height: height * 0.03),
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
              SizedBox(height: height * 0.008),
              Text(
                "Password must be at least 8 characters!",
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: height * 0.03),
              ButtonForAuth(
                height: 0.06,
                width: 0.8,
                border_color: Color(0xff1F41BB),
                background_color: Color(0xff1F41BB),
                text: "Sign Up".toUpperCase(),
                text_color: Colors.white,
                shadowColor: Color(0xff1F41BB),
                my_fun: () => signUp(),
              ),
              SizedBox(height: height * 0.03),
              ButtonForAuth(
                height: 0.06,
                width: 0.8,
                border_color: Color(0xff1F41BB),
                background_color: Colors.white,
                text: "Sign in".toUpperCase(),
                shadowColor: Colors.grey,
                text_color: Colors.black,
                my_fun: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
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
