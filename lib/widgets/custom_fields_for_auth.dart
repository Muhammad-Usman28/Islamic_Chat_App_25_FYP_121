import 'package:flutter/material.dart';

class CustomFieldsForAuth extends StatefulWidget {
  final double? height;
  final double? width;
  final String? label_txt;
  final TextEditingController? controller;
  final bool? isHidden;
  final Color? shadowColor;
  final Icon? icon;
  final bool? isRead;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final VoidCallback? my_fun;

  const CustomFieldsForAuth({
    super.key,
    this.label_txt,
    this.controller,
    this.isHidden,
    this.height,
    this.width,
    this.shadowColor,
    this.onChanged,
    this.icon,
    this.validator,
    this.isRead,
    this.my_fun,
  });

  @override
  State<CustomFieldsForAuth> createState() => _CustomFieldsForAuthState();
}

class _CustomFieldsForAuthState extends State<CustomFieldsForAuth> {
  @override
  Widget build(BuildContext context) {
    final double scaledHeight =
        MediaQuery.of(context).size.height * widget.height!;
    final double scaledWidth =
        MediaQuery.of(context).size.width * widget.width!;
    return Container(
      decoration: BoxDecoration(
        color: Color(0xffF1F4FF),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: widget.shadowColor!.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      height: scaledHeight,
      width: scaledWidth,
      child: TextField(
        readOnly: widget.isRead ?? false,
        onTap: widget.my_fun ?? () {},
        cursorColor: Color(0xff1F41BB),
        controller: widget.controller,
        obscureText: widget.isHidden!,
        decoration: InputDecoration(
          prefixIcon: Icon(widget.icon!.icon),
          labelText: "${widget.label_txt}",
          labelStyle: TextStyle(
            color: Color(0xff626262),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(0xff1F41BB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(0xff1F41BB)),
          ),
          contentPadding: EdgeInsets.all(10),
        ),
      ),
    );
  }
}
