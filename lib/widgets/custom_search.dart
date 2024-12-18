import 'package:flutter/material.dart';

class CustomSearch extends StatefulWidget {
  final double? height;
  final double? width;
  final Color? border_color;
  final Color? background_color;
  final String? text;
  final Color? text_color;
  final ValueChanged<String>? onChanged;
  const CustomSearch(
      {super.key,
      this.height,
      this.width,
      this.border_color,
      this.background_color,
      this.text,
      this.text_color,
      this.onChanged});

  @override
  State<CustomSearch> createState() => _CustomSearchState();
}

class _CustomSearchState extends State<CustomSearch> {
  @override
  Widget build(BuildContext context) {
    final double scaledHeight =
        MediaQuery.of(context).size.height * widget.height!;
    final double scaledWidth =
        MediaQuery.of(context).size.width * widget.width!;
    return Container(
      height: scaledHeight,
      width: scaledWidth,
      decoration: BoxDecoration(
        color: widget.background_color,
        border: Border.all(
          color: widget.border_color!,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        cursorColor: Color(0xFFADB5BD),
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            color: Color(0xFFADB5BD),
          ),
          hintText: "${widget.text}",
          hintStyle: TextStyle(
            color: widget.text_color,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xFFF7F7FC),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xFFF7F7FC),
            ),
          ),
          border: UnderlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
