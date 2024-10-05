
import 'package:flutter/material.dart';
import 'package:newuijewelsync/utilis/colorcode.dart';

class Mytheme{

  static ThemeData lighttheme(BuildContext context) => ThemeData(
    fontFamily: 'Inter',
    scaffoldBackgroundColor: ColorCode.backgroundColor,
    primaryColor: ColorCode.primaryColor,
    // colorScheme: const ColorScheme.light(primary: Colors.transparent, background: Colors.transparent),
    colorScheme: const ColorScheme.light(primary: ColorCode.primaryColor, background: ColorCode.backgroundColor),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      // backgroundColor: ColorCode.backgroundColor,
      elevation: 5,
      iconTheme: IconThemeData(color: ColorCode.iconcolor),
      toolbarTextStyle:Theme.of(context).textTheme.bodyText1,
      titleTextStyle:Theme.of(context).textTheme.bodyText1,
    ),
    textTheme: TextTheme(
      bodyText1: TextStyle(
        fontFamily: 'Inter',
        fontSize: 15, // Adjust the font size as needed
        fontWeight: FontWeight.normal,
        color:ColorCode.appcolorback, // Adjust the text color as needed
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: ColorCode.black
    ),

  );

  static ThemeData darktheme(BuildContext context) =>ThemeData(
    brightness: Brightness.dark,
    primaryColor: ColorCode.primaryColor,
  );



}