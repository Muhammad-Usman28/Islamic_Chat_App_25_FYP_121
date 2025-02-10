import 'package:flutter/material.dart';
import 'package:fyp_user_panel/controller/gemini_chat_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class Geminichat extends StatefulWidget {
  const Geminichat({super.key});

  @override
  State<Geminichat> createState() => _GeminichatState();
}

class _GeminichatState extends State<Geminichat> {
  final String API_KEY = "AIzaSyBKvJzcJXj_7JynTnvW60twqxrWIG4nYTQ";
  final List<Message> messages = [];
  final TextEditingController inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Future<void> getGeminiCall() async {
    final userMessage = inputController.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      messages.add(
          Message(isUser: true, messages: userMessage, date: DateTime.now()));
    });

    inputController.clear();
    _scrollToBottom(); // Scroll to bottom after user message

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: API_KEY,
      );

      final response = await model.generateContent([Content.text(userMessage)]);

      setState(() {
        messages.add(Message(
          isUser: false,
          messages:
              response.text ?? "Sorry, I couldn't understand your message.",
          date: DateTime.now(),
        ));
      });

      _scrollToBottom(); // Scroll after bot response
    } catch (e) {
      setState(() {
        messages.add(Message(
          isUser: false,
          messages: "An error occurred: $e",
          date: DateTime.now(),
        ));
      });
      _scrollToBottom(); // Ensure scrolling even on error
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1E88E5),
                  Color(0xFF37474F),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: IconThemeData(color: Colors.white),
                title: Text(
                  "AI Assistant",
                  style: GoogleFonts.roboto(
                      textStyle: TextStyle(color: Colors.white)),
                ),
                centerTitle: true,
              ),
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController, // Attach scroll controller
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final newMessage = messages[index];
                    return Messages(
                      isUser: newMessage.isUser,
                      messages: newMessage.messages,
                      date: DateFormat("h:mm").format(newMessage.date),
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      cursorColor: Colors.black,
                      controller: inputController,
                      style: GoogleFonts.sen(
                          textStyle: TextStyle(color: Colors.black)),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        fillColor: Colors.transparent,
                        filled: true,
                        hintText: "Enter your message...",
                        hintStyle: GoogleFonts.sen(
                            textStyle: TextStyle(color: Colors.black)),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 20),
                    child: IconButton(
                      onPressed: () {
                        if (inputController.text.trim().isNotEmpty) {
                          getGeminiCall();
                        }
                      },
                      icon: Icon(Icons.send),
                      iconSize: 20,
                      color: Colors.white,
                      style: IconButton.styleFrom(
                        backgroundColor: Color(0xFF37474F),
                        shape: CircleBorder(),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
