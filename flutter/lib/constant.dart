import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xff24405C);
const Color kButtonColor = Color(0xff24405C);
const Color kTextColor = Color(0xff000000);
heightSpace(double height) {
  return SizedBox(height: height);
}

widthSpace(double width) {
  return SizedBox(width: width);
}

TextStyle textStyleTitle = const TextStyle(
    fontFamily: 'OpenSans',
    color: kTextColor,
    fontWeight: FontWeight.w700,
    fontSize: 20);
TextStyle textStyle =
    const TextStyle(fontFamily: 'OpenSans', color: kTextColor, fontSize: 18);
