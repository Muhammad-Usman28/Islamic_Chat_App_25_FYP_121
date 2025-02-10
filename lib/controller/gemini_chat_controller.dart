import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Message {
  final bool isUser;
  final String messages;
  final DateTime date;
  const Message(
      {required this.isUser, required this.messages, required this.date});
}

class Messages extends StatelessWidget {
  final bool isUser;
  final String messages;
  final String date;
  const Messages(
      {super.key,
      required this.isUser,
      required this.messages,
      required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(vertical: 10).copyWith(
        left: isUser ? 100 : 10,
        right: isUser ? 10 : 100,
      ),
      decoration: BoxDecoration(
        color: isUser ? Color(0xFF1E88E5) : Color(0xFF37474F), // New Colors
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
          bottomLeft: isUser ? Radius.circular(12) : Radius.zero,
          bottomRight: isUser ? Radius.zero : Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            messages,
            style: GoogleFonts.sen(
                textStyle: TextStyle(
                    color: Colors.white, // Ensuring text is readable
                    fontSize: 15)),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(date,
                style: GoogleFonts.sen(
                    textStyle: TextStyle(
                  color: Colors.grey[300], // Adjusting timestamp color
                ))),
          ),
        ],
      ),
    );
  }
}
