import 'dart:ui';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'settings_state.g.dart';

class AppTheme extends EnumClass {
  static Serializer<AppTheme> get serializer => _$appThemeSerializer;

  static const AppTheme white = _$white;
  static const AppTheme black = _$black;
  static const AppTheme grey = _$grey;
  static const AppTheme yellow = _$yellow;

  const AppTheme._(String name) : super(name);

  static BuiltSet<AppTheme> get values => _$thValues;
  static AppTheme valueOf(String name) => _$thValueOf(name);
}

class AppLocale extends EnumClass {
  static Serializer<AppLocale> get serializer => _$appLocaleSerializer;

  static const AppLocale en = _$en;
  static const AppLocale zh = _$zh;

  const AppLocale._(String name) : super(name);

  static BuiltSet<AppLocale> get values => _$loValues;
  static AppLocale valueOf(String name) => _$loValueOf(name);

  Locale toLocale() {
    return const {
      AppLocale.en: Locale('en', ''),
      AppLocale.zh: Locale('zh', ''),
    }[this];
  }
}

abstract class SettingsState
    implements Built<SettingsState, SettingsStateBuilder> {
  static Serializer<SettingsState> get serializer => _$settingsStateSerializer;

  SettingsState._();

  factory SettingsState([Function(SettingsStateBuilder) updates]) =
      _$SettingsState;

  AppTheme get theme;
  AppLocale get locale;
  String get baseUrl;

  static void _initializeBuilder(SettingsStateBuilder b) => b
    ..theme = AppTheme.white
    ..locale = AppLocale.en
    ..baseUrl = 'ngabbs.com';
}
