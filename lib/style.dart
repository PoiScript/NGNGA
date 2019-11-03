import 'package:flutter/material.dart';

const LargeTextSize = 22.0;
const MediumTextSize = 16.0;
const SmallTextSize = 12.0;

const Color TextColorDark = Colors.black;
const Color TextColorLight = Colors.white;
const Color TextColorAccent = Colors.red;
const Color TextColorFaint = Color.fromRGBO(125, 125, 125, 1.0);

const DefaultPaddingHorizontal = 12.0;

const TitleTextStyle = TextStyle(
  fontWeight: FontWeight.w300,
  fontSize: LargeTextSize,
  color: TextColorDark,
);

const SubTitleTextStyle = TextStyle(
  fontWeight: FontWeight.w300,
  fontSize: MediumTextSize,
  color: TextColorAccent,
);

const CaptionTextStyle = TextStyle(
  fontWeight: FontWeight.w600,
  fontSize: SmallTextSize,
  color: Color.fromRGBO(0, 0, 0, 0.54),
);

const Body1TextStyle = TextStyle(
  fontWeight: FontWeight.w300,
  fontSize: MediumTextSize,
  color: Colors.black,
);
