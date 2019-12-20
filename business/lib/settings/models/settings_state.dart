import 'package:built_value/built_value.dart';

part 'settings_state.g.dart';

enum AppTheme { white, black, grey, yellow }

enum AppLocale { en, zh }

abstract class SettingsState
    implements Built<SettingsState, SettingsStateBuilder> {
  SettingsState._();

  factory SettingsState([Function(SettingsStateBuilder) updates]) =
      _$SettingsState;

  AppTheme get theme;
  AppLocale get locale;

  static void _initializeBuilder(SettingsStateBuilder b) => b
    ..theme = AppTheme.white
    ..locale = AppLocale.en;
}
