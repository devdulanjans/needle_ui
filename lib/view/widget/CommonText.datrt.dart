import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommonText extends StatelessWidget {
  final String? errorMessage;
  final String? message;
  final double fontSize;
  final bool isTextAlignCenter;
  final FontWeight setFontWeight;
  const CommonText({
    super.key,
    this.message,
    this.errorMessage,
    this.fontSize = 14,
    this.isTextAlignCenter = true,
    this.setFontWeight = FontWeight.w500,
  });

  @override
  Widget build(BuildContext context) {
    return Text(message!.isNotEmpty ? message! : errorMessage!,
      textAlign: isTextAlignCenter ? TextAlign.center:TextAlign.start,
      style: GoogleFonts.poppins(
        color: message!.isNotEmpty ? Colors.black : Colors.white,
        fontSize: fontSize,
        fontWeight: setFontWeight
      ),
    );
  }
}