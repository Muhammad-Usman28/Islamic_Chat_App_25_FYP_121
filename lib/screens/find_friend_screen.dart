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
  @override
  void initState() {
    super.initState();
    myPersonInfo(); // Fetch personal info when the widget initializes
  }

  List<Map<String, dynamic>> searchFriends = [];
  TextEditingController friendController = TextEditingController();
  Map<String, dynamic> alreadyFriend = {};
  bool? oldfriend = false;

  Future<void> search(String? key) async {
    print("Controller text: ${friendController.text}");
    print("My personal data: ${myPersonalData}");

    if (key == null || key.isEmpty) {
      setState(() {
        searchFriends.clear();
      });
      return;
    }

    String currentUserEmail = FirebaseAuth.instance.currentUser!.email!;
    String enteredName = friendController.text.trim().toLowerCase();
    String myFirstName = myPersonalData["First_Name"].toString().toLowerCase();

    if (enteredName == myFirstName) {
      print("❌ You can't search for yourself.");
      setState(() {
        searchFriends.clear();
      });
      return;
    }

    try {
      setState(() {
        oldfriend = false;
        searchFriends.clear();
        alreadyFriend.clear();
      });

      // 🔹 Step 1: Check in friends subcollection (Search by FirstName)
      QuerySnapshot friendSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserEmail)
          .collection("friends")
          .where('FirstName', isEqualTo: enteredName)
          .get();

      if (friendSnapshot.docs.isNotEmpty) {
        print("✅ Friend found in subcollection, stopping search.");
        setState(() {
          oldfriend = true;
          alreadyFriend =
              friendSnapshot.docs.first.data() as Map<String, dynamic>;
        });
        print("Already Friend${friendSnapshot.docs.first.data()}");
        return; // ✅ Stop searching if a friend is found
      }

      // 🔹 Step 2: Fetch all users matching entered name
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection("AllUsers")
          .where('First_Name', isEqualTo: enteredName)
          .get();

      // 🔹 Step 3: Remove logged-in user from search results manually
      List<Map<String, dynamic>> filteredResults = userSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .where((user) =>
              user["Email"] !=
              currentUserEmail) // Compare email instead of name
          .toList();

      setState(() {
        searchFriends = filteredResults;
        print("🔎 Search Results: $searchFriends");
      });
    } catch (e) {
      print("❌ Error during search: $e");
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
                Container(
                  height: height * 0.06,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Color(0xFFF7F7FC),
                      border: Border.all(
                        color: Color(0xFFF7F7FC),
                      ),
                      borderRadius: BorderRadius.circular(15)),
                  child: TextField(
                    cursorColor: Color(0xFFADB5BD),
                    controller: friendController,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onPressed: () {
                          search(friendController.text.toLowerCase());
                        },
                        icon: Icon(
                          Icons.search,
                          color: Color(0xFFADB5BD),
                        ),
                      ),
                      hintText: "Search Friend",
                      hintStyle: TextStyle(
                        color: Color(0xFFADB5BD),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFF7F7FC),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFF7F7FC),
                        ),
                      ),
                      border: UnderlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.02),

                // Checking if the friend is already added
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
                        text: "Freinds",
                        text_color: Colors.white,
                        my_fun: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.blue,
                              content: Text("You are already friends."),
                            ),
                          );
                        },
                      ),
                    ),
                  )

                // Display if no friends are found
                else if (searchFriends == false || searchFriends.isEmpty)
                  SizedBox(
                    height: height * 0.3,
                    width: 300,
                    child: Image.asset("assets/images/empty.jpg"),
                  )

                // Display found friends
                else
                  Container(
                    height: height * 0.4,
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
                                String? toUserID =
                                    data["Email"].toString().toLowerCase();
                                String? fromUserID = myPersonalData["Email"]
                                    .toString()
                                    .toLowerCase();
                                String? customID = "${fromUserID}_$toUserID";

                                await FirebaseFirestore.instance
                                    .collection("Friend_Requests")
                                    .doc(customID)
                                    .set({
                                  "ToUserEmail": toUserID,
                                  "FromUserImage": myPersonalData["Avatar_Url"],
                                  "FromUserFirstName":
                                      myPersonalData["First_Name"],
                                  "FromUserLastName":
                                      myPersonalData["Last_Name"],
                                  "FromUserEmail": fromUserID,
                                  "Status": "Pending",
                                  "TimeStamp": FieldValue.serverTimestamp(),
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
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
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
