import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xFF181818);
const Color kPrimaryColorTran = Color(0xDD181818);
const Color kSecondaryColor = Color(0xFF09D976);

const kBottomTextStyle = TextStyle(
  fontSize: 30.0,
  fontWeight: FontWeight.bold,
);

const kFABTheme = FloatingActionButtonThemeData(
  backgroundColor: kSecondaryColor,
);

const kTextTheme = TextTheme(
  body1: TextStyle(
    color: Colors.white,
  ),
);

const kAppBarTheme = AppBarTheme(
  elevation: 0.0,
  textTheme: TextTheme(
    title: TextStyle(
      color: Colors.white,
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    ),
  ),
  iconTheme: IconThemeData(
    color: Colors.white,
  ),
  color: kPrimaryColorTran,
);

const kInputDecorationTheme = InputDecorationTheme(
  hintStyle: TextStyle(
    color: Colors.white70,
  ),
);

final appTheme = ThemeData.light().copyWith(
  primaryColor: kPrimaryColor,
  scaffoldBackgroundColor: kPrimaryColor,
  buttonColor: kSecondaryColor,
  accentColor: kSecondaryColor,
  splashColor: kPrimaryColor.withAlpha(0x55),
  floatingActionButtonTheme: kFABTheme,
  textTheme: kTextTheme,
  appBarTheme: kAppBarTheme,
  inputDecorationTheme: kInputDecorationTheme,
  bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.transparent),
);
