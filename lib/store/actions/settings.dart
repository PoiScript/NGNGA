import 'package:async_redux/async_redux.dart';

import 'package:ngnga/store/state.dart';

import 'state_persist.dart';

class ChangeBaseUrlAction extends ReduxAction<AppState> {
  final String baseUrl;

  ChangeBaseUrlAction(this.baseUrl);

  @override
  AppState reduce() {
    return state.copy(
      settings: state.settings.copy(baseUrl: baseUrl),
    );
  }

  void after() => dispatch(SaveState());
}

class ChangeLocaleAction extends ReduxAction<AppState> {
  final AppLocale locale;

  ChangeLocaleAction(this.locale);

  @override
  AppState reduce() {
    return state.copy(
      settings: state.settings.copy(locale: locale),
    );
  }

  void after() => dispatch(SaveState());
}

class ChangeThemeAction extends ReduxAction<AppState> {
  final AppTheme theme;

  ChangeThemeAction(this.theme);

  @override
  AppState reduce() {
    return state.copy(
      settings: state.settings.copy(theme: theme),
    );
  }

  void after() => dispatch(SaveState());
}
