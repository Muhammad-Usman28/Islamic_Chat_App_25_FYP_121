import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_user_panel/widgets/button_for_auth.dart';
import 'package:fyp_user_panel/widgets/custom_search.dart';
import 'package:fyp_user_panel/widgets/find_friend_tile.dart';
import 'package:google_fonts/google_fonts.dart';

class FindFriendScreen extends StatefulWidget {
  const FindFriendScreen({super.key});

  @override
  State<FindFriendScreen> createState() => _FindFriendScreenState();
}

class _FindFriendScreenState extends State<FindFriendScreen> {
  List? searchFriends = [];
  TextEditingController friendController = TextEditingController();

  // Method For Search

  Future<void> search(String? key) async {
    if (key!.isNotEmpty) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("AllUsers")
          .where("Email", isGreaterThanOrEqualTo: key)
          .where("Email",
              isNotEqualTo: "${FirebaseAuth.instance.currentUser!.email}")
          .where("Email", isLessThanOrEqualTo: key + "\uf8ff")
          .get();
      setState(() {
        searchFriends = snapshot.docs.map((doc) {
          return doc.data() as Map<String, dynamic>;
        }).toList();
      });
    } else if (key.isEmpty) {
      setState(() {
        searchFriends!.clear();
      });
    }
  }

  // Method for Get Personal Data

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

  @override
  Widget build(BuildContext context) {
    double? height = MediaQuery.of(context).size.height;
    // double? width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Find Friends",
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                CustomSearch(
                  height: 0.06,
                  width: double.infinity,
                  text: "Search",
                  text_color: Color(0xFFADB5BD),
                  border_color: Color(0xFFF7F7FC),
                  background_color: Color(0xFFF7F7FC),
                  onChanged: (key) {
                    search(key);
                  },
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                searchFriends!.isEmpty
                    ? SizedBox(
                        height: height * 0.3,
                        width: 300,
                        child: Image.asset("assets/images/empty.jpg"),
                      )
                    : Container(
                        height: height * 0.4,
                        child: ListView.builder(
                          itemCount: searchFriends!.length,
                          itemBuilder: (context, index) {
                            var data = searchFriends![index];

                            return FindFriendTile(
                              image_url: "${data["Avatar_Url"]}",
                              first_name: "${data["First_Name"]}",
                              last_name: "${data["Last_Name"]}",
                              email: "${data["Email"]}",
                              button_widget: ButtonForAuth(
                                shadowColor: Color(0xff1F41BB),
                                height: 0.04,
                                width: 0.5,
                                border_color: Color(0xff1F41BB),
                                background_color: Color(0xff1F41BB),
                                text: "Send Request",
                                text_color: Colors.white,
                                my_fun: () async {
                                  myPersonInfo().then(
                                    (_) async {
                                      String? toUserID =
                                          "${data["Email"]}".toLowerCase();
                                      String? fromUserID =
                                          "${myPersonalData["Email"]}"
                                              .toLowerCase();
                                      String? customID =
                                          "${fromUserID}_$toUserID";
                                      await FirebaseFirestore.instance
                                          .collection("Friend_Requests")
                                          .doc("$customID")
                                          .set({
                                        "ToUserEmail": "$toUserID",
                                        "FromUserImage":
                                            "${myPersonalData["Avatar_Url"]}",
                                        "FromUserFirstName":
                                            "${myPersonalData["First_Name"]}",
                                        "FromUserLastName":
                                            "${myPersonalData["Last_Name"]}",
                                        "FromUserEmail":
                                            "${myPersonalData["Email"]}"
                                                .toLowerCase(),
                                        "Status": "Pending",
                                        "TimeStamp":
                                            FieldValue.serverTimestamp()
                                      });

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              backgroundColor: Colors.green,
                                              content:
                                                  Text("Request is sent.")));
                                    },
                                  ).catchError((error) {
                                    print("Error: $error");
                                  }).whenComplete(
                                    () {
                                      print(
                                          "Operation complete, whether successful or not");
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
