import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FindFriendTile extends StatefulWidget {
  final String? image_url;
  final String? first_name;
  final String? last_name;
  final String? email;
  final Widget? button_widget;

  const FindFriendTile({
    super.key,
    this.image_url,
    this.first_name,
    this.last_name,
    this.email,
    this.button_widget,
  });

  @override
  State<FindFriendTile> createState() => _FindFriendTileState();
}

class _FindFriendTileState extends State<FindFriendTile> {
  @override
  Widget build(BuildContext context) {
    double? height = MediaQuery.of(context).size.height;
    double? width = MediaQuery.of(context).size.width;
    return Container(
      height: height * 0.12,
      width: double.infinity,
      // decoration: BoxDecoration(border: Border.all()),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(
              "${widget.image_url}",
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: width * 0.02,
                  ),
                  Text(
                    "Name ",
                    style: GoogleFonts.poppins(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  Text("${widget.first_name} ${widget.last_name}"),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: width * 0.02,
                  ),
                  Text(
                    "Email  ",
                    style: GoogleFonts.poppins(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  Text("${widget.email}"),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: width * 0.02,
                  ),
                  if (widget.button_widget !=
                      null) // Check if button_widget exists
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: widget.button_widget!,
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
