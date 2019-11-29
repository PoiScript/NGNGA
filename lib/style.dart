import 'package:flutter/material.dart';

const TitleTextStyle = TextStyle(
  fontWeight: FontWeight.w400,
  fontFamily: "Roboto",
  fontFamilyFallback: ["Noto Sans CJK SC"],
);

const SubTitleTextStyle = TextStyle(
  fontWeight: FontWeight.w400,
  fontFamily: "Roboto",
  fontFamilyFallback: ["Noto Sans CJK SC"],
);

const SubheadTextStyle = TextStyle(
  fontWeight: FontWeight.w500,
  fontFamily: "Roboto",
  fontFamilyFallback: ["Noto Sans CJK SC"],
);

const CaptionTextStyle = TextStyle(
  fontWeight: FontWeight.w500,
  fontFamily: "Roboto",
  fontFamilyFallback: ["Noto Sans CJK SC"],
);

const Body1TextStyle = TextStyle(
  fontWeight: FontWeight.w400,
  fontFamily: "Roboto",
  fontFamilyFallback: ["Noto Sans CJK SC"],
);

const Body2TextStyle = TextStyle(
  fontWeight: FontWeight.w500,
  fontFamily: "Roboto",
  fontFamilyFallback: ["Noto Sans CJK SC"],
);

final ThemeData whiteTheme = ThemeData(
  fontFamily: "Roboto",
  brightness: Brightness.light,
  textTheme: TextTheme(
    title: TitleTextStyle,
    subtitle: SubTitleTextStyle,
    caption: CaptionTextStyle,
    subhead: SubheadTextStyle,
    body1: Body1TextStyle,
    body2: Body2TextStyle,
  ),
);

final ThemeData yellowTheme = ThemeData(
  fontFamily: "Roboto",
  brightness: Brightness.light,
  textTheme: TextTheme(
    title: TitleTextStyle,
    subtitle: SubTitleTextStyle,
    caption: CaptionTextStyle,
    subhead: SubheadTextStyle,
    body1: Body1TextStyle,
    body2: Body2TextStyle,
  ),
);

final ThemeData blackTheme = ThemeData(
  fontFamily: "Roboto",
  brightness: Brightness.dark,
  textTheme: TextTheme(
    title: TitleTextStyle,
    subtitle: SubTitleTextStyle,
    caption: CaptionTextStyle,
    subhead: SubheadTextStyle,
    body1: Body1TextStyle,
    body2: Body2TextStyle,
  ),
);

final ThemeData greyTheme = ThemeData(
  fontFamily: "Roboto",
  brightness: Brightness.dark,
  primaryColor: Colors.grey,
  textTheme: TextTheme(
    title: TitleTextStyle,
    subtitle: SubTitleTextStyle,
    caption: CaptionTextStyle,
    subhead: SubheadTextStyle,
    body1: Body1TextStyle,
    body2: Body2TextStyle,
  ),
);
