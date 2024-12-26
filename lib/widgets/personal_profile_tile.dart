import 'package:flutter/material.dart';
import 'package:fyp_user_panel/screens/update_info_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class PersonalProfileTile extends StatefulWidget {
  final String? text;
  final Icon? icon;
  const PersonalProfileTile({
    super.key,
    this.text,
    this.icon,
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UpdateInfoScreen()));
            },
            child: Text(
              "${widget.text}",
              style: GoogleFonts.roboto(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
