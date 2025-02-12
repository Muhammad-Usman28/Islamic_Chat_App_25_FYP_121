import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_user_panel/screens/dua_screen.dart';
import 'package:fyp_user_panel/widgets/personal_profile_tile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // State Variables
  Map<String, dynamic> myPersonalData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    myPersonInfo();
  }

  // Personal Info method
  Future<void> myPersonInfo() async {
    try {
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
      setState(() {
        myPersonalData = doc.data() as Map<String, dynamic>;
        isLoading = false; // Data has been fetched
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  // Invite Friend Method

  Future<void> openWhatsApp({required String message}) async {
    final whatsappUrl =
        Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(whatsappUrl)) {
      try {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } catch (e) {
        print('Error launching WhatsApp: $e');
      }
    } else {
      print('Could not launch WhatsApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    double? height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  SizedBox(
                    height: height * 0.05,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Personal Profile",
                        style: GoogleFonts.mulish(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: height * 0.04,
                  ),
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: myPersonalData["Avatar_Url"] != null &&
                            myPersonalData["Avatar_Url"] != ""
                        ? NetworkImage("${myPersonalData["Avatar_Url"]}")
                        : AssetImage("assets/images/placeholder.png")
                            as ImageProvider,
                  ),
                  SizedBox(
                    height: height * 0.04,
                  ),
                  Text(
                    myPersonalData["First_Name"] != null &&
                            myPersonalData["Last_Name"] != null
                        ? "${myPersonalData["First_Name"]} ${myPersonalData["Last_Name"]}"
                            .toUpperCase()
                        : "Loading...",
                    style: GoogleFonts.mulish(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: height * 0.04,
                  ),
                  PersonalProfileTile(
                    targetScreen: DuaScreen(),
                    onTap: null,
                    icon: Icon(
                      Icons.nightlight_round,
                      color: Color(0xffFFC107),
                    ),
                    text: "Dua Vault",
                  ),
                  SizedBox(
                    height: height * 0.04,
                  ),
                  PersonalProfileTile(
                    targetScreen: null,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.blue,
                          content: Text(
                              "This feature is under Development. Stay tuned!"),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.all_inclusive,
                      color: Color(0xffFFC107),
                    ),
                    text: "Dhikr Counter",
                  ),
                  SizedBox(
                    height: height * 0.04,
                  ),
                  PersonalProfileTile(
                    targetScreen: null,
                    icon: Icon(
                      Icons.link,
                      color: Color(0xffFFC107),
                    ),
                    text: "Invite Friend",
                    onTap: () {
                      openWhatsApp(
                          message:
                              "Check out this amazing app: [Your App Link]");
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
