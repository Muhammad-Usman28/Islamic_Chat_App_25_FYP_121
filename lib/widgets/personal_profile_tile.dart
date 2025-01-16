import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PersonalProfileTile extends StatefulWidget {
  final String? text;
  final Icon? icon;
  final Widget? targetScreen;
  const PersonalProfileTile({
    super.key,
    this.text,
    this.icon,
    this.targetScreen,
  });

  @override
  State<PersonalProfileTile> createState() => _PersonalProfileTileState();
}

class _PersonalProfileTileState extends State<PersonalProfileTile> {
  @override
  Widget build(BuildContext context) {
    double? height = MediaQuery.of(context).size.height;
    double? width = MediaQuery.of(context).size.width;
    return Container(
      height: height * 0.05,
      width: width * 0.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Color(0xffF7F7FC),
      ),
      child: Row(
        children: [
          SizedBox(
            width: width * 0.05,
          ),
          Icon(widget.icon!.icon),
          SizedBox(
            width: width * 0.08,
          ),
          InkWell(
            onTap: () {
              if (widget.targetScreen != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => widget.targetScreen!),
                );
              }
            },
            child: Text(
              "${widget.text}",
              style: GoogleFonts.roboto(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
