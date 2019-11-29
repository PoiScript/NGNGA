import 'package:flutter/material.dart';

const titleTextStyle = TextStyle(
  fontWeight: FontWeight.w400,
  fontFamily: 'Roboto',
  fontFamilyFallback: ['Noto Sans CJK SC'],
);

const subTitleTextStyle = TextStyle(
  fontWeight: FontWeight.w400,
  fontFamily: 'Roboto',
  fontFamilyFallback: ['Noto Sans CJK SC'],
);

const subheadTextStyle = TextStyle(
  fontWeight: FontWeight.w500,
  fontFamily: 'Roboto',
  fontFamilyFallback: ['Noto Sans CJK SC'],
);

const captionTextStyle = TextStyle(
  fontWeight: FontWeight.w500,
  fontFamily: 'Roboto',
  fontFamilyFallback: ['Noto Sans CJK SC'],
);

const body1TextStyle = TextStyle(
  fontWeight: FontWeight.w400,
  fontFamily: 'Roboto',
  fontFamilyFallback: ['Noto Sans CJK SC'],
);

const body2TextStyle = TextStyle(
  fontWeight: FontWeight.w500,
  fontFamily: 'Roboto',
  fontFamilyFallback: ['Noto Sans CJK SC'],
);

final ThemeData whiteTheme = ThemeData(
  fontFamily: 'Roboto',
  brightness: Brightness.light,
  textTheme: TextTheme(
    title: titleTextStyle,
    subtitle: subTitleTextStyle,
    caption: captionTextStyle,
    subhead: subheadTextStyle,
    body1: body1TextStyle,
    body2: body2TextStyle,
  ),
);

final ThemeData yellowTheme = ThemeData(
  fontFamily: 'Roboto',
  brightness: Brightness.light,
  textTheme: TextTheme(
    title: titleTextStyle,
    subtitle: subTitleTextStyle,
    caption: captionTextStyle,
    subhead: subheadTextStyle,
    body1: body1TextStyle,
    body2: body2TextStyle,
  ),
);

final ThemeData blackTheme = ThemeData(
  fontFamily: 'Roboto',
  brightness: Brightness.dark,
  textTheme: TextTheme(
    title: titleTextStyle,
    subtitle: subTitleTextStyle,
    caption: captionTextStyle,
    subhead: subheadTextStyle,
    body1: body1TextStyle,
    body2: body2TextStyle,
  ),
);

final ThemeData greyTheme = ThemeData(
  fontFamily: 'Roboto',
  brightness: Brightness.dark,
  primaryColor: Colors.grey,
  textTheme: TextTheme(
    title: titleTextStyle,
    subtitle: subTitleTextStyle,
    caption: captionTextStyle,
    subhead: subheadTextStyle,
    body1: body1TextStyle,
    body2: body2TextStyle,
  ),
);
