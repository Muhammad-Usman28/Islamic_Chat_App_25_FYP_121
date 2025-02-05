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
  // Controller
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

  //  Variables
  String? url;
  int? selectedIndex;

  // Sign Up Function

  Future<void> Sign_Up(BuildContext context) async {
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Please Select Your Avatar",
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }
    if (passwordController.text.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Password Must Consist of 8 Characaters",
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }
    if (firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        url != null) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        await FirebaseFirestore.instance
            .collection("AllUsers")
            .doc(emailController.text)
            .set({
          "Email": emailController.text.toLowerCase(),
          "First_Name": firstNameController.text.toLowerCase(),
          "Last_Name": lastNameController.text.toLowerCase(),
          "Avatar_Url": url,
        });

        firstNameController.clear();
        lastNameController.clear();
        emailController.clear();
        passwordController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Sign UP Successfully",
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Login(),
          ),
        );
      } catch (e) {
        return print(e);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: height * 0.05,
                ),
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
                    )
                  ],
                ),
                SizedBox(
                  height: height * 0.05,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: height * 0.21,
                      width: width * 0.8,
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            crossAxisCount: 3),
                        itemCount: AppConst.avatar.length,
                        itemBuilder: (context, index) {
                          bool isSelected = index == selectedIndex;
                          return InkWell(
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                                url = AppConst.avatar[index]["ImageURL"];
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: isSelected
                                        ? Color(0xff1F41BB)
                                        : Colors.transparent,
                                    width: 3),
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
                  ],
                ),
                SizedBox(
                  height: height * 0.03,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomFieldsForAuth(
                      icon: Icon(Icons.person),
                      label_txt: "Enter Your First Name",
                      controller: firstNameController,
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
                      icon: Icon(Icons.person),
                      label_txt: "Enter Your Last Name",
                      controller: lastNameController,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CustomFieldsForAuth(
                          icon: Icon(Icons.lock),
                          label_txt: "Enter Your Password",
                          controller: passwordController,
                          isHidden: true,
                          height: 0.06,
                          width: 0.8,
                          shadowColor: Colors.grey,
                        ),
                        SizedBox(
                          height: height * 0.008,
                        ),
                        Text(
                          "Password must be 8 Characters!",
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: height * 0.03,
                ),
                ButtonForAuth(
                  height: 0.06,
                  width: 0.8,
                  border_color: Color(0xff1F41BB),
                  background_color: Color(0xff1F41BB),
                  text: "Sign Up".toUpperCase(),
                  text_color: Colors.white,
                  shadowColor: Color(0xff1F41BB),
                  my_fun: () => Sign_Up(context),
                ),
                SizedBox(
                  height: height * 0.03,
                ),
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
                      MaterialPageRoute(
                        builder: (context) => Login(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
