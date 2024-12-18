import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ButtonForAuth extends StatefulWidget {
  final double? height;
  final double? width;
  final Color? border_color;
  final Color? background_color;
  final String? text;
  final Color? text_color;
  final VoidCallback? my_fun;
  final Color? shadowColor;
  const ButtonForAuth(
      {super.key,
      required this.height,
      required this.width,
      required this.border_color,
      required this.background_color,
      required this.text,
      required this.text_color,
      required this.my_fun,
      required this.shadowColor});

  @override
  State<ButtonForAuth> createState() => _ButtonForAuthState();
}

class _ButtonForAuthState extends State<ButtonForAuth> {
  @override
  Widget build(BuildContext context) {
    final double scaledHeight =
        MediaQuery.of(context).size.height * widget.height!;
    final double scaledWidth =
        MediaQuery.of(context).size.width * widget.width!;
    return InkWell(
      onTap: widget.my_fun,
      borderRadius: BorderRadius.circular(10),
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        height: scaledHeight,
        width: scaledWidth,
        decoration: BoxDecoration(
            border: Border.all(
              color: widget.border_color!,
            ),
            color: widget.background_color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: widget.shadowColor!.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              )
            ]),
        child: Center(
          child: Text(
            "${widget.text}",
            style: GoogleFonts.poppins(
                color: widget.text_color,
                fontSize: 15,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
