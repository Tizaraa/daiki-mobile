import 'package:flutter/material.dart';

class TizaraaColors {
  static const Color primaryColor = Color(0xFFF0F8FF);
  static const Color primaryColor2 = Color(0xFFCEE3F4);
  static const Color Tizara = Color(0xFF05619F);


  // Define gradient colors
  static const Color gradientStart = Color(0xFF00B2AE);
  static const Color gradientEnd = Color(0xFF007B7A);

  // Define linear gradient
  // static const Color primaryColor2 = LinearGradient(
  //   begin: Alignment.topLeft,
  //   end: Alignment.bottomRight,
  //   colors: [gradientStart, gradientEnd],
  // );

static const Gradient primaryColors = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
);

}
