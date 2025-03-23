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
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addMessage(
        Message(
          isUser: false,
          messages:
              "As-salamu Alaikum! I am Illm AI, your Deen AI Assistant 🌙\n\nHow may I assist you in your journey today?",
          date: DateTime.now(),
        ),
      );
    });
  }

  Future<void> getGeminiCall() async {
    final userMessage = inputController.text.trim();
    if (userMessage.isEmpty) return;

    _addMessage(
      Message(isUser: true, messages: userMessage, date: DateTime.now()),
    );

    inputController.clear();
    _scrollToBottom();

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: API_KEY,
      );

      final response = await model.generateContent([Content.text(userMessage)]);

      _addMessage(
        Message(
          isUser: false,
          messages:
              response.text ?? "Sorry, I couldn't understand your message.",
          date: DateTime.now(),
        ),
      );

      _scrollToBottom();
    } catch (e) {
      _addMessage(
        Message(
          isUser: false,
          messages: "An error occurred: $e",
          date: DateTime.now(),
        ),
      );
      _scrollToBottom();
    }
  }

  void _addMessage(Message message) {
    messages.add(message);
    _listKey.currentState?.insertItem(messages.length - 1);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  // CLEAR HISTORY FUNCTION
  void _clearChatHistory() {
    final itemCount = messages.length;

    for (int i = itemCount - 1; i >= 0; i--) {
      final removedMessage = messages.removeAt(i);
      _listKey.currentState?.removeItem(
        i,
        (context, animation) =>
            _buildAnimatedMessage(removedMessage, animation),
        duration: Duration(milliseconds: 300),
      );
    }
  }

  // CONFIRM BEFORE CLEARING
  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900], // Dark background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Rounded corners
        ),
        title: Text(
          "Clear Chat History",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white, // White text for contrast
          ),
        ),
        content: Text(
          "Are you sure you want to clear all chat history?",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70, // Slightly dimmed text color
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white, // White text
            ),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              _clearChatHistory();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent, // Red color for emphasis
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Rounded corners
              ),
            ),
            child: Text(
              "Clear",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFF7F6F2),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF00796B),
                  Color(0xFF004D40),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: IconThemeData(color: Colors.white),
                title: Text(
                  "Illm AI 🌙",
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    onPressed: () => _showClearHistoryDialog(),
                    icon: Icon(Icons.delete),
                    tooltip: "Clear Chat",
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    _suggestionChip("Dua for sleeping"),
                    _suggestionChip("Dua for anxiety"),
                    _suggestionChip("Explain Surah Al-Fatiha"),
                  ],
                ),
              ),
              Expanded(
                child: AnimatedList(
                  key: _listKey,
                  controller: _scrollController,
                  initialItemCount: messages.length,
                  itemBuilder: (context, index, animation) {
                    final newMessage = messages[index];
                    return _buildAnimatedMessage(newMessage, animation);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        cursorColor: Color(0xFF00796B),
                        controller: inputController,
                        style: GoogleFonts.sen(
                          textStyle: TextStyle(color: Colors.black),
                        ),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Color(0xFF00796B)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Color(0xFF00796B)),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          hintText: "Type your question here...",
                          hintStyle: GoogleFonts.sen(
                            textStyle: TextStyle(color: Colors.black54),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: IconButton(
                        onPressed: () {
                          if (inputController.text.trim().isNotEmpty) {
                            getGeminiCall();
                          }
                        },
                        icon: Icon(Icons.send),
                        iconSize: 22,
                        color: Colors.white,
                        style: IconButton.styleFrom(
                          backgroundColor: Color(0xFF00796B),
                          shape: CircleBorder(),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedMessage(Message message, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: 0.0,
      child: FadeTransition(
        opacity: animation,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          alignment:
              message.isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            decoration: BoxDecoration(
              color: message.isUser ? Color(0xFF00796B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF00796B)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.messages,
                  style: GoogleFonts.sen(
                    textStyle: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  message.date != null
                      ? DateFormat("h:mm a").format(message.date)
                      : "",
                  style: TextStyle(
                    fontSize: 10,
                    color: message.isUser ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _suggestionChip(String text) {
    return ActionChip(
      label: Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Color(0xFF004D40),
      onPressed: () {
        inputController.text = text;
        getGeminiCall();
      },
      shape: StadiumBorder(
        side: BorderSide(color: Colors.white),
      ),
    );
  }
}
