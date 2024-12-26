import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_user_panel/screens/main_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String? senderID;
  final String? receiverID;
  final String? receiverName;
  final String? receiverImage;
  const ChatScreen(
      {super.key,
      this.senderID,
      this.receiverID,
      this.receiverName,
      this.receiverImage});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageController = TextEditingController();
  String? chatID;

  // Read message method

  Future<void> markMessagesAsSeen() async {
    DocumentSnapshot chatSnapshot =
        await FirebaseFirestore.instance.collection('chats').doc(chatID).get();

    if (chatSnapshot.exists) {
      List<dynamic> messages = chatSnapshot['messages'];
      List<dynamic> updatedMessages = messages.map((message) {
        if (message['sender'] != FirebaseAuth.instance.currentUser!.email &&
            message['read'] == false) {
          // Update the 'read' field to true
          return {
            ...message,
            'read': true, // Mark the message as seen
          };
        }
        return message;
      }).toList();

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatID)
          .update({'messages': updatedMessages});
    }
  }

  // Send Message method

  Future<void> sendMessage(
    String? senderEmail,
    String? receiverEmail,
  ) async {
    print("${senderEmail} - ${receiverEmail}");
    String message = messageController.text.trim();
    Timestamp timestamp = Timestamp.now();
    await FirebaseFirestore.instance.collection('chats').doc(chatID).set({
      'messages': FieldValue.arrayUnion([
        {
          'sender': senderEmail,
          'text': message,
          'timestamp': timestamp,
          'read': false
        }
      ]),
      'lastMessage': message,
      'lastMessageSender': senderEmail,
      'lastMessageTimestamp': timestamp,
      'recentActiveTime': timestamp,
    }, SetOptions(merge: true));
    messageController.clear();
  }

  String generateChatID(String currentUserID, String receiverID) {
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    return "${ids[0]}_${ids[1]}";
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      chatID = generateChatID(widget.senderID!, widget.receiverID!);
    });
    markMessagesAsSeen();
  }

  @override
  Widget build(BuildContext context) {
    double? height = MediaQuery.of(context).size.height;
    double? width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: height * 0.08,
                width: width * 1,
                decoration: BoxDecoration(
                  color: Color(0xffF7F7FC),
                  border: Border.all(
                    color: Color(0xFFADB5BD),
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainScreen(),
                          ),
                        );
                      },
                      icon: Icon(Icons.chevron_left),
                    ),
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage("${widget.receiverImage}"),
                    ),
                    SizedBox(
                      width: width * 0.05,
                    ),
                    Text(
                      "${widget.receiverName}",
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("chats")
                    .doc("${chatID}")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    // If no document exists, show a message or create the document
                    return const Center(
                        child: Text('No messages yet. Start chatting!'));
                  }
                  var chatData = snapshot.data!;
                  List<dynamic> messages = chatData['messages'] ?? [];

                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var message = messages[index];
                      String sender = message['sender'];
                      String text = message['text'];
                      Timestamp timestamp = message['timestamp'];

                      // Format the message's timestamp
                      DateTime dateTime = timestamp.toDate();
                      String formattedTime =
                          DateFormat('h:mm a').format(dateTime);

                      // Check if the sender is the current user
                      bool isSender =
                          sender == FirebaseAuth.instance.currentUser!.email;

                      // Check if the message has been read
                      bool isRead = message['read'] ?? false;

                      return Align(
                        alignment: isSender
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 16.0),
                            decoration: BoxDecoration(
                              color:
                                  isSender ? Colors.blue : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: isSender
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  text,
                                  style: TextStyle(
                                    color:
                                        isSender ? Colors.white : Colors.black,
                                  ),
                                ),
                                SizedBox(height: height * 0.02),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      formattedTime, // Time the message was sent
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: isSender
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),
                                    SizedBox(width: width * 0.02),
                                    if (isSender &&
                                        isRead) // Show "Seen" only for the sender
                                      Text(
                                        'Seen', // Show "Seen" when the message is read
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          fontStyle: FontStyle.italic,
                                          color: Colors
                                              .white70, // Use a visible color for "Seen"
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                          hintText: 'Enter your message',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFADB5BD),
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Color(0xFFADB5BD)),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          fillColor: Color(0xffF7F7FC),
                          filled: true),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Color(0xff1F41BB),
                    ),
                    onPressed: () => sendMessage(
                      "${FirebaseAuth.instance.currentUser!.email}",
                      "${widget.receiverID}",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
