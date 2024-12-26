import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_user_panel/screens/chat_screen.dart';
import 'package:fyp_user_panel/widgets/button_for_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    double? height = MediaQuery.of(context).size.height;
    double? width = MediaQuery.of(context).size.width;

    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            SizedBox(
              height: height * 0.12,
              width: double.infinity,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc("${FirebaseAuth.instance.currentUser!.email}")
                    .collection("friends")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasData) {
                    var data = snapshot.data!.docs;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot doc = data[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 15, top: 10),
                          child: InkWell(
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Center(
                                      child: AlertDialog(
                                        backgroundColor: Colors.white,
                                        content: Container(
                                          height: height * 0.1,
                                          width: width * 0.4,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              ButtonForAuth(
                                                my_fun: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ChatScreen(
                                                        senderID:
                                                            "${FirebaseAuth.instance.currentUser!.email}",
                                                        receiverID: "${doc.id}",
                                                        receiverName:
                                                            "${doc["FirstName"]} ${doc["LastName"]}",
                                                        receiverImage:
                                                            "${doc["Image"]}",
                                                      ),
                                                    ),
                                                  );
                                                },
                                                height: 0.045,
                                                width: 0.45,
                                                text: "Send Message",
                                                text_color: Colors.white,
                                                background_color: Colors.green,
                                                shadowColor: Colors.green,
                                                border_color: Colors.green,
                                              ),
                                              ButtonForAuth(
                                                my_fun: () async {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection("users")
                                                      .doc(
                                                          "${FirebaseAuth.instance.currentUser!.email}")
                                                      .collection("friends")
                                                      .doc("${doc.id}")
                                                      .delete();
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      content: Text(
                                                        "${doc["FirstName"]} ${doc["LastName"]} is removed from friend list.",
                                                        style:
                                                            GoogleFonts.poppins(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                height: 0.045,
                                                width: 0.45,
                                                text: "Delete Friend",
                                                text_color: Colors.white,
                                                background_color: Colors.red,
                                                shadowColor: Colors.red,
                                                border_color: Colors.red,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                            },
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage:
                                      NetworkImage("${doc["Image"]}"),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "${doc["FirstName"]} ${doc["LastName"]}",
                                      style: GoogleFonts.roboto(
                                          color: Colors.black,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Text("No Friend is Available");
                  }
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
