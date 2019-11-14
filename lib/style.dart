import 'package:flutter/material.dart';

const FontFamily = "Noto Sans CJK SC";
const FontFamilyFallback = ["Noto Sans CJK JP"];

const LargeTextSize = 22.0;
const MediumTextSize = 16.0;
const SmallTextSize = 12.0;

const TitleTextStyle = TextStyle(
  fontWeight: FontWeight.w400,
  fontSize: LargeTextSize,
  color: Colors.black,
  fontFamily: FontFamily,
  fontFamilyFallback: FontFamilyFallback,
);

const SubTitleTextStyle = TextStyle(
  fontWeight: FontWeight.w400,
  fontSize: MediumTextSize,
  fontFamily: FontFamily,
  fontFamilyFallback: FontFamilyFallback,
);

const CaptionTextStyle = TextStyle(
  fontWeight: FontWeight.w500,
  fontSize: SmallTextSize,
  color: Color.fromRGBO(0, 0, 0, 0.54),
  fontFamily: FontFamily,
  fontFamilyFallback: FontFamilyFallback,
);

const Body1TextStyle = TextStyle(
  fontWeight: FontWeight.w400,
  color: Colors.black,
  fontFamily: FontFamily,
  fontFamilyFallback: FontFamilyFallback,
);

const Body2TextStyle = TextStyle(
  fontWeight: FontWeight.w500,
  color: Colors.black,
  fontFamily: FontFamily,
  fontFamilyFallback: FontFamilyFallback,
);
