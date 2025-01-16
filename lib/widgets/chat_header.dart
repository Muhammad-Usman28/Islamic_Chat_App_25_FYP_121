import 'package:flutter/material.dart';
import 'package:fyp_user_panel/screens/main_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatHeader extends StatefulWidget {
  final String? receiverImage;
  final String? receiverName;

  const ChatHeader(
      {super.key, required this.receiverImage, required this.receiverName});

  @override
  State<ChatHeader> createState() => _ChatHeaderState();
}

class _ChatHeaderState extends State<ChatHeader> {
  @override
  Widget build(BuildContext context) {
    double? height = MediaQuery.of(context).size.height;
    double? width = MediaQuery.of(context).size.width;
    return Container(
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
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
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
    );
  }
}
