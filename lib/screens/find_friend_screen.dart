import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_user_panel/widgets/button_for_auth.dart';
import 'package:fyp_user_panel/widgets/find_friend_tile.dart';
import 'package:google_fonts/google_fonts.dart';

class FindFriendScreen extends StatefulWidget {
  const FindFriendScreen({super.key});

  @override
  State<FindFriendScreen> createState() => _FindFriendScreenState();
}

class _FindFriendScreenState extends State<FindFriendScreen> {
  List<Map<String, dynamic>> searchFriends = [];
  TextEditingController friendController = TextEditingController();
  Map<String, dynamic> alreadyFriend = {};
  bool? oldfriend = false;
  Timer? _debounce;
  Map<String, dynamic> myPersonalData = {};

  @override
  void initState() {
    super.initState();
    myPersonInfo();
  }

  Future<void> myPersonInfo() async {
    CollectionReference myData =
        FirebaseFirestore.instance.collection("AllUsers");

    QuerySnapshot snapshot = await myData
        .where("Email", isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get();

    if (snapshot.docs.isEmpty) {
      print("No user found with this email");
      return;
    }

    DocumentSnapshot doc = snapshot.docs.first;
    setState(() {
      myPersonalData = doc.data() as Map<String, dynamic>;
    });
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      search(query);
    });
  }

  Future<void> search(String? key) async {
    if (key == null || key.trim().isEmpty) {
      setState(() {
        searchFriends.clear();
        oldfriend = false;
        alreadyFriend.clear();
      });
      return;
    }

    String currentUserEmail = FirebaseAuth.instance.currentUser!.email!;
    String enteredEmail = key.trim().toLowerCase();

    if (enteredEmail == currentUserEmail.toLowerCase()) {
      setState(() {
        searchFriends.clear();
        oldfriend = false;
        alreadyFriend.clear();
      });
      return;
    }

    try {
      setState(() {
        oldfriend = false;
        searchFriends.clear();
        alreadyFriend.clear();
      });

      // ✅ Step 1: Check if already a friend by email
      QuerySnapshot friendSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserEmail)
          .collection("friends")
          .where('Email', isGreaterThanOrEqualTo: enteredEmail)
          .where('Email', isLessThanOrEqualTo: enteredEmail + '\uf8ff')
          .get();

      if (friendSnapshot.docs.isNotEmpty) {
        setState(() {
          oldfriend = true;
          alreadyFriend =
              friendSnapshot.docs.first.data() as Map<String, dynamic>;
        });
        return;
      }

      // ✅ Step 2: Search by email in AllUsers (partial & case insensitive)
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection("AllUsers")
          .where('Email', isGreaterThanOrEqualTo: enteredEmail)
          .where('Email', isLessThanOrEqualTo: enteredEmail + '\uf8ff')
          .get();

      List<Map<String, dynamic>> filteredResults = userSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .where((user) =>
              user["Email"].toLowerCase() != currentUserEmail.toLowerCase())
          .toList();

      setState(() {
        searchFriends = filteredResults;
      });
    } catch (e) {
      print("❌ Error during search: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
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
              SizedBox(height: height * 0.02),

              // 🔹 Search by Gmail/Email Input Field
              Container(
                height: height * 0.06,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7FC),
                  border: Border.all(color: const Color(0xFFF7F7FC)),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  cursorColor: const Color(0xFFADB5BD),
                  controller: friendController,
                  onChanged: (value) {
                    onSearchChanged(value.toLowerCase());
                    setState(() {}); // For clear button UI refresh
                  },
                  decoration: InputDecoration(
                    suffixIcon: friendController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: Color(0xFFADB5BD)),
                            onPressed: () {
                              friendController.clear();
                              search("");
                              setState(() {});
                            },
                          )
                        : const Icon(Icons.search, color: Color(0xFFADB5BD)),
                    hintText: "Search by Email",
                    hintStyle: const TextStyle(color: Color(0xFFADB5BD)),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFF7F7FC)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFF7F7FC)),
                    ),
                    border:
                        const UnderlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),

              // 🔹 Already Friend
              if (oldfriend == true)
                Container(
                  height: height * 0.105,
                  child: FindFriendTile(
                    image_url: "${alreadyFriend["Image"]}",
                    first_name:
                        "${alreadyFriend["FirstName"][0].toUpperCase()}${alreadyFriend["FirstName"].substring(1).toLowerCase()}",
                    last_name:
                        "${alreadyFriend["LastName"][0].toUpperCase()}${alreadyFriend["LastName"].substring(1).toLowerCase()}",
                    email: "${alreadyFriend["Email"]}",
                    button_widget: ButtonForAuth(
                      shadowColor: const Color(0xff1F41BB),
                      height: 0.04,
                      width: 0.5,
                      border_color: const Color(0xff1F41BB),
                      background_color: const Color(0xff1F41BB),
                      text: "Friends",
                      text_color: Colors.white,
                      my_fun: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.blue,
                            content: Text("You are already friends."),
                          ),
                        );
                      },
                    ),
                  ),
                )

              // 🔹 No Results Found (empty input or no match)
              else if (friendController.text.isEmpty ||
                  (searchFriends.isEmpty && friendController.text.isNotEmpty))
                Center(
                  child: SizedBox(
                    height: height * 0.3,
                    width: 300,
                    child: Image.asset("assets/images/empty.jpg"),
                  ),
                )

              // 🔹 Search Results by Gmail/Email
              else if (searchFriends.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: searchFriends.length,
                    itemBuilder: (context, index) {
                      var data = searchFriends[index];
                      return FindFriendTile(
                        image_url: "${data["Avatar_Url"]}",
                        first_name:
                            "${data["First_Name"][0].toUpperCase()}${data["First_Name"].substring(1)}",
                        last_name:
                            "${data["Last_Name"][0].toUpperCase()}${data["Last_Name"].substring(1)}",
                        email: "${data["Email"]}",
                        button_widget: ButtonForAuth(
                          shadowColor: const Color(0xff1F41BB),
                          height: 0.04,
                          width: 0.5,
                          border_color: const Color(0xff1F41BB),
                          background_color: const Color(0xff1F41BB),
                          text: "Send Request",
                          text_color: Colors.white,
                          my_fun: () async {
                            await myPersonInfo().then((_) async {
                              String toUserID =
                                  data["Email"].toString().toLowerCase();
                              String fromUserID = myPersonalData["Email"]
                                  .toString()
                                  .toLowerCase();
                              String customID = "${fromUserID}_$toUserID";

                              await FirebaseFirestore.instance
                                  .collection("Friend_Requests")
                                  .doc(customID)
                                  .set({
                                "ToUserEmail": toUserID,
                                "FromUserImage": myPersonalData["Avatar_Url"],
                                "FromUserFirstName":
                                    myPersonalData["First_Name"],
                                "FromUserLastName": myPersonalData["Last_Name"],
                                "FromUserEmail": fromUserID,
                                "Status": "Pending",
                                "TimeStamp": FieldValue.serverTimestamp(),
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.green,
                                  content: Text("Request is sent."),
                                ),
                              );
                            }).catchError((error) {
                              print("Error: $error");
                            });
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
    );
  }
}
