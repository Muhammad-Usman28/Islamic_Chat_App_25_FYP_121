import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_user_panel/constants/supabase_service.dart';
import 'package:fyp_user_panel/widgets/chat_header.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final String? senderID;
  final String? receiverID;
  final String? receiverName;
  final String? receiverImage;
  final String? senderName;
  final String? senderImage;

  const ChatScreen({
    super.key,
    this.senderID,
    this.receiverID,
    this.receiverName,
    this.receiverImage,
    this.senderName,
    this.senderImage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? chatID;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    setState(() {
      chatID = generateChatID(widget.senderID!, widget.receiverID!);
    });
  }

  // Scroll bottom
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300), // Smooth scrolling
          curve: Curves.easeOut,
        );
      }
    });
  }

  File? _image;
  String? _uploadedImageUrl;

  final ImagePicker _picker = ImagePicker();
  bool? uploaded;

  Future<void> pickAndUploadImage() async {
    // Pick an image from the gallery
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final File file = File(image.path);

      // Call the SupabaseService function
      final String? imageUrl =
          await SupabaseService.uploadImage(file, 'images');

      setState(() {
        _uploadedImageUrl = imageUrl!;
        messageController.text = _uploadedImageUrl!;
        sendMessage(
          "${FirebaseAuth.instance.currentUser!.email}",
          "${widget.receiverID}",
        );
      });

      if (imageUrl != null) {
        print('Uploaded Image URL: $imageUrl');
      } else {
        print('Failed to upload image.');
      }
    } else {
      print('No image selected.');
    }
  }

// Method to generate Chat ID
  String generateChatID(String currentUserID, String receiverID) {
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    return "${ids[0]}_${ids[1]}";
  }

  Map<String, dynamic> ReceiveInfoBeforeMessage = {};
  Map<String, dynamic> SenderInfoBeforeMessage = {};

  // Method For gettting information of Receiver

  Future<void> getReceiverInfoBeforeMessage() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
          .instance
          .collection(
              'AllUsers') // Replace 'users' with your Firestore collection name
          .where('Email', isEqualTo: "${widget.receiverID}")
          .get();

      setState(() {
        ReceiveInfoBeforeMessage = querySnapshot.docs.first.data();
      });
    } catch (e) {}
  }

  // Method for getting information of sender

  Future<void> getSenderInfoBeforeMessage() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
          .instance
          .collection(
              'AllUsers') // Replace 'users' with your Firestore collection name
          .where('Email', isEqualTo: "${widget.senderID}")
          .get();

      setState(() {
        SenderInfoBeforeMessage = querySnapshot.docs.first.data();
      });
    } catch (e) {}
  }

  //  Send message method
  Future<void> sendMessage(
    String? senderEmail,
    String? receiverEmail,
  ) async {
    print("${senderEmail} - ${receiverEmail}");
    String message = messageController.text.trim();
    Timestamp timestamp = Timestamp.now();

    try {
      // Fetch sender and receiver information before sending the message
      await getSenderInfoBeforeMessage();
      await getReceiverInfoBeforeMessage();

      // Update Firestore with the chat details
      await FirebaseFirestore.instance.collection('chats').doc(chatID).set({
        'messages': FieldValue.arrayUnion([
          {
            'sender': senderEmail,
            'text': message,
            'timestamp': timestamp,
            'read': false,
          }
        ]),
        'lastMessage': message,
        'lastMessageSender': senderEmail,
        'lastMessageTimestamp': timestamp,
        'recentActiveTime': timestamp,
        "${widget.senderID}": SenderInfoBeforeMessage,
        "${widget.receiverID}": ReceiveInfoBeforeMessage,
      }, SetOptions(merge: true));

      // Clear the message input
      messageController.clear();
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  Map<String, dynamic> receiverInfo = {};

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
                  receiverImage: widget.receiverImage,
                  receiverName: widget.receiverName),
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
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _scrollToBottom());

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
                              color: isSender
                                  ? Color(0xff2196F3)
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: isSender
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sender,
                                  style: TextStyle(
                                    color:
                                        isSender ? Colors.white : Colors.black,
                                  ),
                                ),
                                SizedBox(height: height * 0.01),
                                buildMessageWidget(text, isSender),
                                SizedBox(height: height * 0.01),
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
                      height: height * 0.06,
                      width: width * 0.12,
                      decoration: BoxDecoration(
                        color: Color(0xffF7F7FC),
                        border: Border.all(color: Color(0xffADB5BD)),
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
                        filled: true,
                        suffixIcon: IconButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onPressed: pickAndUploadImage,
                          icon: Icon(
                            Icons.photo_library,
                          ),
                        ),
                      ),
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
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        String searchQuery = ''; // Temporary variable to store the input query

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Rounded corners
          ),
          title: Text(
            'Search Hadees',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Type your query...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  searchQuery = value; // Update the query variable
                },
              ),
              SizedBox(height: 10),
              Text(
                'Press Enter or click "Search" to search similar Hadees.',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor:
                        Colors.red[50], // Light red background color
                    padding: EdgeInsets.symmetric(horizontal: 26, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'CLOSE',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (searchQuery.isNotEmpty) {
                      final url = Uri.parse(
                          'http://192.168.18.61:8000/get_similar_hadees');
                      final data = {'query': searchQuery};

                      try {
                        final response = await http.post(
                          url,
                          headers: {
                            'Content-Type': 'application/json',
                          },
                          body: jsonEncode(data),
                        );

                        if (response.statusCode == 200) {
                          final responseData =
                              jsonDecode(response.body)['similar_hadees'];
                          _displayResponseData(context, responseData,
                              SID: SID, RID: RID, roomID: roomID);
                        } else {
                          print('Error: ${response.reasonPhrase}');
                        }
                      } catch (e) {
                        print('Error: $e');
                      }
                    } else {
                      print('Search query is empty.');
                    }
                  },
                  child: Text('SEARCH'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
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
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Similar Hadiths',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(),
              responseData.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No Similar Hadiths Found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: responseData.length,
                        itemBuilder: (BuildContext context, int index) {
                          final hadith = responseData[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hadith No: ${hadith['hadith_no']}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    'Source: ${hadith['source']}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '${hadith['text_en']}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Divider(),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        messageController.text =
                                            "${hadith['source']} ${hadith['hadith_no']} ${hadith['text_en']}";

                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) {
                                            return Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          },
                                        );

                                        try {
                                          await sendMessage(widget.senderID,
                                              widget.receiverID);
                                          messageController.clear();
                                        } catch (error) {
                                          print(
                                              'Error sending message: $error');
                                        } finally {
                                          Navigator.of(context)
                                              .pop(); // Close loading
                                          Navigator.of(context)
                                              .pop(); // Close dialog
                                        }
                                      },
                                      icon: Icon(Icons.send, size: 18),
                                      label: Text('Send'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('CLOSE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// Widget to understand whether a text or image
  Widget buildMessageWidget(String text, bool isSender) {
    // Check if the text starts with "https" (indicating it's a URL for an image)
    final isImage = text.startsWith('https');

    return isImage
        ? Image.network(
            height: 300,
            width: 150,
            text,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Text(
                'Image could not be loaded',
                style: TextStyle(
                  color: isSender ? Colors.white : Colors.black,
                ),
              );
            },
          )
        : Text(
            text,
            style: TextStyle(
              color: isSender ? Colors.white : Colors.black,
            ),
          );
  }
}
