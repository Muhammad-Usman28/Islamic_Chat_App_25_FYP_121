import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_user_panel/screens/chat_screen.dart';
import 'package:fyp_user_panel/view/gemini_chat.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Get the current user who use the app
  final loggedInUserEmail = FirebaseAuth.instance.currentUser!.email;
  String generateChatID(String currentUserID, String friendID) {
    List<String> ids = [currentUserID, friendID];
    ids.sort();
    return "${ids[0]}_${ids[1]}";
  }

  // Get Personal Detail of Current User

  Map<String, dynamic> myPersonalData = {};
  bool isLoading = true;

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

  @override
  void initState() {
    super.initState();
    myPersonInfo();
  }

  @override
  Widget build(BuildContext context) {
    double? height = MediaQuery.of(context).size.height;
    double? width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Geminichat()));
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: Color(0xFF37474F),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
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
                              padding:
                                  const EdgeInsets.only(right: 15, top: 10),
                              child: InkWell(
                                highlightColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                onTap: () {
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (context) {
                                      return Center(
                                        child: Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Container(
                                            height: height * 0.4,
                                            width: width * 0.8,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xffBBD2C5)
                                                      .withOpacity(0.8),
                                                  Color(0xff536976)
                                                      .withOpacity(0.8),
                                                  Color(0xff292E49)
                                                      .withOpacity(0.8),
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                // Header Section
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Column(
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 30,
                                                        backgroundImage:
                                                            NetworkImage(
                                                                "${doc["Image"]}"),
                                                      ),
                                                      SizedBox(height: 10),
                                                      Text(
                                                        "${doc["FirstName"][0].toUpperCase()}${doc["FirstName"].substring(1).toLowerCase()} "
                                                        "${doc["LastName"][0].toUpperCase()}${doc["LastName"].substring(1).toLowerCase()}",
                                                        style:
                                                            GoogleFonts.poppins(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Divider(
                                                    color: Colors.white
                                                        .withOpacity(0.5)),
                                                // Action Buttons
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10),
                                                  child: Column(
                                                    children: [
                                                      ElevatedButton.icon(
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      ChatScreen(
                                                                senderID:
                                                                    "${FirebaseAuth.instance.currentUser!.email}",
                                                                senderName:
                                                                    "${myPersonalData["First_Name"]} ${myPersonalData["Last_Name"]}",
                                                                senderImage:
                                                                    "${myPersonalData["Avatar_Url"]}",
                                                                receiverID:
                                                                    "${doc.id}",
                                                                receiverName:
                                                                    "${doc["FirstName"]} ${doc["LastName"]}",
                                                                receiverImage:
                                                                    "${doc["Image"]}",
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        icon: Icon(
                                                          Icons.message,
                                                          color: Colors.white,
                                                        ),
                                                        label: Text(
                                                          "Send Message",
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                        ),
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.green,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10),
                                                      ElevatedButton.icon(
                                                        onPressed: () async {
                                                          String? chatID =
                                                              generateChatID(
                                                            "${FirebaseAuth.instance.currentUser!.email}",
                                                            "${doc.id}",
                                                          );

                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  "users")
                                                              .doc(
                                                                  "${FirebaseAuth.instance.currentUser!.email}")
                                                              .collection(
                                                                  "friends")
                                                              .doc("${doc.id}")
                                                              .delete()
                                                              .then(
                                                            (_) async {
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      "chats")
                                                                  .doc(
                                                                      "${chatID}")
                                                                  .delete()
                                                                  .then(
                                                                (_) {
                                                                  Navigator.pop(
                                                                      context);
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .red,
                                                                      content:
                                                                          Text(
                                                                        "${doc["FirstName"]} ${doc["LastName"]} is removed from the friend list.",
                                                                        style: GoogleFonts
                                                                            .poppins(
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                          );
                                                        },
                                                        icon: Icon(
                                                          Icons.delete,
                                                          color: Colors.white,
                                                        ),
                                                        label: Text(
                                                          "Delete Message",
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                        ),
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.red,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text(
                                                          "Cancel",
                                                          style: GoogleFonts
                                                              .poppins(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
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
                                          "${doc["FirstName"][0].toUpperCase()}${doc["FirstName"].substring(1).toLowerCase()} "
                                          "${doc["LastName"][0].toUpperCase()}${doc["LastName"].substring(1).toLowerCase()}",
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
                SizedBox(height: height * 0.01),
                SizedBox(
                  height: height * 0.5,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text("No recent chats available"));
                      }

                      final chatDocs = snapshot.data!.docs.where((doc) {
                        final chatID = doc.id;
                        return chatID.contains(loggedInUserEmail!);
                      }).toList();

                      if (chatDocs.isEmpty) {
                        return const Center(
                            child: Text("No recent chats available"));
                      }

                      return ListView.builder(
                        itemCount: chatDocs.length,
                        itemBuilder: (context, index) {
                          final chat =
                              chatDocs[index].data() as Map<String, dynamic>;
                          final chatID = chatDocs[index].id;
                          final lastMessage = chat['lastMessage'] ?? '';
                          // final lastSender = chat['lastMessageSender'] ?? '';

                          final timestamp =
                              chat['lastMessageTimestamp'] as Timestamp?;

                          // Extract other participant's email from the chatID
                          final chatPartnerEmail = chatID
                              .replaceAll('${loggedInUserEmail}_', '')
                              .replaceAll('_${loggedInUserEmail}', '');
                          // getSenderInfo(chatPartnerEmail);
                          final record = ((chatPartnerEmail ==
                                  chat["${chatPartnerEmail}"]["Email"])
                              ? chat["${chatPartnerEmail}"]
                              : ((chatPartnerEmail ==
                                      chat["${FirebaseAuth.instance.currentUser!.email}"]
                                          ["Email"])
                                  ? chat[
                                      "${FirebaseAuth.instance.currentUser!.email}"]
                                  : {}));
                          print(
                              "${chat["${FirebaseAuth.instance.currentUser!.email}"]}");
                          return ListTile(
                            leading: CircleAvatar(
                                backgroundColor: Colors.grey[300],
                                child:
                                    Image.network("${record["Avatar_Url"]}")),
                            title: Text(
                              "${record["First_Name"][0].toUpperCase()}${record["First_Name"].substring(1).toLowerCase()} "
                              "${record["Last_Name"][0].toUpperCase()}${record["Last_Name"].substring(1).toLowerCase()}",
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.black54),
                            ),
                            trailing: timestamp != null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        // Format time
                                        DateFormat('hh:mm a')
                                            .format(timestamp.toDate()),
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 10),
                                      ),
                                      const SizedBox(
                                          height: 4), // Add some spacing
                                      Text(
                                        // Format date
                                        DateFormat('dd/MM/yyyy')
                                            .format(timestamp.toDate()),
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 10),
                                      ),
                                    ],
                                  )
                                : null,
                            onTap: () {
                              // Navigate to detailed chat screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    senderID: "${loggedInUserEmail}",
                                    receiverID: "${chatPartnerEmail}",
                                    receiverImage: "${record["Avatar_Url"]}",
                                    receiverName:
                                        "${record["First_Name"][0].toUpperCase()}${record["First_Name"].substring(1).toLowerCase()} "
                                        "${record["Last_Name"][0].toUpperCase()}${record["Last_Name"].substring(1).toLowerCase()}",
                                  ),
                                ),
                              );
                            },
                          );
                        },
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
