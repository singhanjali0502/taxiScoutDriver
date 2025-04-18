import 'package:flutter/material.dart';
import '../styles/styles.dart';
import 'package:google_fonts/google_fonts.dart';

//button style

// ignore: must_be_immutable
class Button extends StatefulWidget {
  dynamic onTap;
  final String text;
  dynamic color;
  dynamic borcolor;
  dynamic textcolor;
  dynamic width;
  dynamic height;
  // ignore: use_key_in_widget_constructors
  Button({
    required this.onTap,
    required this.text,
    this.color,
    this.borcolor,
    this.textcolor,
    this.width,
    this.height,
  });

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return InkWell(
      onTap: widget.onTap,
      child: Container(
        height: widget.height ?? media.width * 0.12,
        width: (widget.width != null) ? widget.width : null,
        padding: EdgeInsets.only(
            left: media.width * twenty, right: media.width * twenty),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: (widget.color != null) ? widget.color : buttonColor,
            border: Border.all(
              color: (widget.borcolor != null) ? widget.borcolor : buttonColor,
              width: 1,
            )),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Text(
            widget.text,
            style: GoogleFonts.roboto(
                fontSize: media.width * sixteen,
                color:
                    (widget.textcolor != null) ? widget.textcolor : buttonText,
                fontWeight: FontWeight.bold,
                letterSpacing: 1),
          ),
        ),
      ),
    );
  }
}



class SearchButton extends StatefulWidget {
  dynamic onTap;
  final String text;
  dynamic color;
  dynamic borcolor;
  dynamic textcolor;
  dynamic width;
  dynamic height;
  // ignore: use_key_in_widget_constructors
  SearchButton({
    required this.onTap,
    required this.text,
    this.color,
    this.borcolor,
    this.textcolor,
    this.width,
    this.height,
  });

  @override
  State<SearchButton> createState() => _SearchButtonState();
}

class _SearchButtonState extends State<SearchButton> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return InkWell(
      onTap: widget.onTap,
      child: Container(
        height: widget.height ?? media.width * 0.12,
        width: (widget.width != null) ? widget.width : null,
        padding: EdgeInsets.only(
            left: media.width * twenty, right: media.width * twenty),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: (widget.color != null) ? Colors.white : Colors.white,
            border: Border.all(
              color: (widget.borcolor != null) ? Colors.white : Colors.white,
              width: 1,
            )),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Text(
            widget.text,
            style: GoogleFonts.roboto(
                fontSize: media.width * sixteen,
                color:
                    (widget.textcolor != null) ? Colors.black : Colors.black,
                fontWeight: FontWeight.bold,
                letterSpacing: 1),
          ),
        ),
      ),
    );
  }
}
//input field style

// ignore: must_be_immutable
class InputField extends StatefulWidget {
  dynamic icon;
  dynamic onTap;
  final String text;
  final TextEditingController textController;
  dynamic inputType;
  dynamic maxLength;
  dynamic color;

  // ignore: use_key_in_widget_constructors
  InputField(
      {this.icon,
      this.onTap,
      required this.text,
      required this.textController,
      this.inputType,
      this.maxLength,
      this.color});

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return TextFormField(
      maxLength: (widget.maxLength == null) ? null : widget.maxLength,
      keyboardType: (widget.inputType == null)
          ? TextInputType.emailAddress
          : widget.inputType,
      controller: widget.textController,
      decoration: InputDecoration(
          counterText: '',
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
            color: inputfocusedUnderline,
            width: 1.2,
            style: BorderStyle.solid,
          )),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
            color: (widget.color == null) ? inputUnderline : widget.color,
            width: 1.2,
            style: BorderStyle.solid,
          )),
          prefixIcon: (widget.icon != null)
              ? Icon(
                  widget.icon,
                  size: media.width * 0.064,
                  color: textColor,
                )
              : null,
          hintText: widget.text,
          hintStyle: GoogleFonts.roboto(
            fontSize: media.width * sixteen,
            color: hintColor,
          )),
      onChanged: widget.onTap,
    );
  }
}
