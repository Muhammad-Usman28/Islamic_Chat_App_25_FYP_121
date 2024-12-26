import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_user_panel/constants/app_const.dart';
import 'package:fyp_user_panel/screens/main_screen.dart';
import 'package:fyp_user_panel/widgets/button_for_auth.dart';
import 'package:fyp_user_panel/widgets/custom_fields_for_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class UpdateInfoScreen extends StatefulWidget {
  const UpdateInfoScreen({super.key});

  @override
  State<UpdateInfoScreen> createState() => _UpdateInfoScreenState();
}

class _UpdateInfoScreenState extends State<UpdateInfoScreen> {
  void initState() {
    super.initState();
    myPersonInfo().then((_) async {
      print("Data is Fetched");
    });
  }

  // Controller
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

  //  Variables
  String? url;
  int? selectedIndex;

  Map<String, dynamic> myPersonalData = {};

  // Get All uset Method

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

  // Update Method

  Future<void> Update_information(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection("AllUsers")
        .doc("${FirebaseAuth.instance.currentUser!.email}")
        .update({
      "First_Name": firstNameController.text,
      "Last_Name": lastNameController.text,
      "Avatar_Url": url,
    });

    firstNameController.clear();
    lastNameController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          "Personal Information is Updated",
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
        builder: (context) => MainScreen(),
      ),
    );
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
                      "Update Information",
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
                      label_txt: "${myPersonalData["First_Name"]}",
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
                      label_txt: "${myPersonalData["Last_Name"]}",
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
                ButtonForAuth(
                  height: 0.06,
                  width: 0.8,
                  border_color: Color(0xff1F41BB),
                  background_color: Color(0xff1F41BB),
                  text: "Update Information".toUpperCase(),
                  text_color: Colors.white,
                  shadowColor: Color(0xff1F41BB),
                  my_fun: () => Update_information(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
