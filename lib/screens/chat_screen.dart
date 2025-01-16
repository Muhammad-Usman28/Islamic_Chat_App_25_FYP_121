import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_user_panel/widgets/chat_header.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final String? senderID;
  final String? receiverID;
  final String? receiverName;
  final String? receiverImage;
  final String? senderName;
  final String? senderImage;

  const ChatScreen(
      {super.key,
      this.senderID,
      this.receiverID,
      this.receiverName,
      this.receiverImage,
      this.senderName,
      this.senderImage});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageController = TextEditingController();
  String? chatID;

  final ScrollController _scrollController =
      ScrollController(); // Scroll controller

  // Scroll to the last message
  void scrollToLastMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

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
          'read': false,
          "receiverImage": widget.receiverImage,
          'receiverName': widget.receiverName,
          'senderName': widget.senderName,
          "senderImage": widget.senderImage,
        }
      ]),
      'lastMessage': message,
      'lastMessageSender': senderEmail,
      'lastMessageTimestamp': timestamp,
      'recentActiveTime': timestamp,
      "receiverImage": widget.receiverImage,
      'receiverName': widget.receiverName,
      'senderName': widget.senderName,
      "senderImage": widget.senderImage,
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
    ScrollController();
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
              child: ChatHeader(
                  receiverImage: "${widget.receiverImage}",
                  receiverName: "${widget.receiverName}"),
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
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    scrollToLastMessage();
                  });

                  return ListView.builder(
                    controller: _scrollController,
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
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      height: height * 0.04,
                      width: width * 0.09,
                      decoration: BoxDecoration(
                        color: Color(0xffF7F7FC),
                        borderRadius: BorderRadius.all(
                          Radius.circular(30),
                        ),
                      ),
                      child: Center(
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            _showAlertDialog(context,
                                SID: widget.senderID,
                                roomID: chatID,
                                RID: widget.receiverID);
                          },
                          icon: Icon(Icons.add),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      cursorColor: Color(0xFFADB5BD),
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
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
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

  void _showAlertDialog(BuildContext context, {var SID, var RID, var roomID}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search Hadees'),
          actions: <Widget>[
            TextField(
              onSubmitted: (value) async {
                final url =
                    Uri.parse('http://192.168.18.61:8000/get_similar_hadees');
                final data = {'query': value};

                try {
                  final response = await http.post(
                    url,
                    headers: {
                      'Content-Type': 'application/json',
                    },
                    body: jsonEncode(data),
                  );

                  if (response.statusCode == 200) {
                    print(response);
                    final responseData =
                        jsonDecode(response.body)['similar_hadees'];
                    _displayResponseData(context, responseData,
                        SID: SID, RID: RID, roomID: roomID);

                    // Print the response to the console
                  } else {
                    print(
                        'Error: ${response.reasonPhrase}'); // Print error message
                  }
                } catch (e) {
                  print('Error: $e'); // Print error message
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _displayResponseData(BuildContext context, List responseData,
      {var SID, var RID, var roomID}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Similar Hadiths'),
          content: SizedBox(
            height: 300,
            width: 300,
            child: ListView.builder(
              itemCount: responseData.length,
              itemBuilder: (BuildContext context, int index) {
                final hadith = responseData[index];
                return ListTile(
                  title: Text(
                    'Hadith No: ${hadith['hadith_no']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Source: ${hadith['source']}\n${hadith['text_en']}',
                    maxLines: 10,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () async {
                    messageController.text =
                        "${hadith['source']} ${hadith['hadith_no']}${hadith['text_en']}";

                    sendMessage(widget.senderID, widget.receiverID).then((_) {
                      messageController.clear();
                    });

                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
