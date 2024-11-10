import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color bluishClr = Color (0xFF3C729F) ;
const Color yellowClr = Color (0xffffd166);
const Color pinkClr = Color (0x98118AB2);
const Color secBlackmode = Color (0xFF4966AF);
const Color adistanceClr = Color (0xff1f3341);
const Color offlineClr = Color (0xff43888c);
const Color libClr = Color (0xffc0d6df);
Color white = Colors.grey.shade50;
const primaryClr = bluishClr;
const Color darkGreyClr = Color (0xFF171E27);
Color absentText = const Color (0xEC336699);



class Themes{
  static final light= ThemeData(
    backgroundColor: Colors.grey.shade50,
    primaryColor: bluishClr,
    brightness: Brightness.light
  );


  static final dark= ThemeData(
    backgroundColor: darkGreyClr ,
    primaryColor: darkGreyClr,
    brightness: Brightness.dark
  );
}

TextStyle get subheadingStyle{
  return GoogleFonts.lato(
    textStyle: const TextStyle(
        fontSize: 23,
      color: Colors.grey,
      fontWeight: FontWeight.bold
    )
  );
}
TextStyle get headingStyle{
  return GoogleFonts.lato(
      textStyle:  const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold
      )
  );
}