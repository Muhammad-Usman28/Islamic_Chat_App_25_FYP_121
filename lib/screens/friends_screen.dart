import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_user_panel/widgets/button_for_auth.dart';
import 'package:fyp_user_panel/widgets/find_friend_tile.dart';
import 'package:google_fonts/google_fonts.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  @override
  Widget build(BuildContext context) {
    double? height = MediaQuery.of(context).size.height;
    // double? width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "All Friends",
              style: GoogleFonts.roboto(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: height * 0.02,
            ),
            SizedBox(
              width: double.infinity,
              height: height * 0.4,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("Friend_Requests")
                    .where("ToUserEmail",
                        isEqualTo:
                            "${FirebaseAuth.instance.currentUser!.email}")
                    .where("Status", isEqualTo: "Pending")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    var doc = snapshot.data!.docs;
                    List<dynamic> requestData = doc.map((e) {
                      return e.data();
                    }).toList();
                    return ListView.builder(
                      itemCount: requestData.length,
                      itemBuilder: (context, index) {
                        var data = requestData[index];
                        return FindFriendTile(
                          first_name: "${data["FromUserFirstName"]}",
                          last_name: "${data["FromUserLastName"]}",
                          email: "${data["FromUserEmail"]}",
                          image_url: "${data["FromUserImage"]}",
                          button_widget: ButtonForAuth(
                            height: 0.04,
                            width: 0.3,
                            border_color: Color(0xff1F41BB),
                            background_color: Color(0xff1F41BB),
                            text: "Accept",
                            text_color: Colors.white,
                            my_fun: () async {
                              DocumentSnapshot snapshot = await FirebaseFirestore
                                  .instance
                                  .collection("AllUsers")
                                  .doc(
                                      "${FirebaseAuth.instance.currentUser!.email}")
                                  .get();

                              Map<String, dynamic> myData =
                                  snapshot.data() as Map<String, dynamic>;

                              await FirebaseFirestore.instance
                                  .collection("Friend_Requests")
                                  .doc("${doc[index].id}")
                                  .update({"Status": "Accepted"});
                              final fromUserEmail = data["FromUserEmail"];
                              String fromUserFirstName =
                                  data["FromUserFirstName"];
                              String fromUserLastName =
                                  data["FromUserLastName"];
                              final fromUserImage = data["FromUserImage"];

                              final toUserEmail = myData["Email"];
                              String toUserFirstName = myData["First_Name"];
                              String toUserLastName = myData["Last_Name"];
                              final toUserImage = myData["Avatar_Url"];

                              await FirebaseFirestore.instance
                                  .collection("users")
                                  .doc("$toUserEmail")
                                  .collection("friends")
                                  .doc(fromUserEmail)
                                  .set({
                                "FirstName": fromUserFirstName.toLowerCase(),
                                "LastName": fromUserLastName.toLowerCase(),
                                "Image": fromUserImage,
                                "Email": fromUserEmail,
                                "timestamp": FieldValue.serverTimestamp(),
                              });

                              await FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(fromUserEmail)
                                  .collection("friends")
                                  .doc(toUserEmail)
                                  .set({
                                "FirstName": toUserFirstName.toLowerCase(),
                                "LastName": toUserLastName.toLowerCase(),
                                "Email": toUserEmail,
                                "Image": toUserImage,
                                "timestamp": FieldValue.serverTimestamp(),
                              });
                            },
                            shadowColor: Color(0xff1F41BB),
                          ),
                          delete_button: ButtonForAuth(
                            height: 0.04,
                            width: 0.3,
                            border_color: Color(0xffADB5BD),
                            background_color: Color(0xffADB5BD),
                            text: "Delete",
                            text_color: Color(0xffF7F7FC),
                            my_fun: () async {
                              await FirebaseFirestore.instance
                                  .collection("Friend_Requests")
                                  .doc("${doc[index].id}")
                                  .update({"Status": "Pending"});
                            },
                            shadowColor: Color(0xffF7F7FC),
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: Text(
                        "No Friend Requests",
                        style: GoogleFonts.poppins(
                            color: Color(0xff1F41BB),
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
