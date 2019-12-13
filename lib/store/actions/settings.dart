import 'dart:io';

import 'package:async_redux/async_redux.dart';
import 'package:device_info/device_info.dart';

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

class ChangeUserAgentAction extends ReduxAction<AppState> {
  final UserAgent userAgent;

  ChangeUserAgentAction(this.userAgent);

  @override
  Future<AppState> reduce() async {
    String newUserAgent = 'Nga_Official/3.0.0';
    switch (userAgent) {
      case UserAgent.none:
        break;
      case UserAgent.osOnly:
        if (Platform.isAndroid) {
          AndroidDeviceInfo device = await DeviceInfoPlugin().androidInfo;
          newUserAgent += '(;Android${device.version.release})';
        }
        break;
      case UserAgent.full:
        if (Platform.isAndroid) {
          AndroidDeviceInfo device = await DeviceInfoPlugin().androidInfo;
          String machine;
          if (device.model.contains(device.manufacturer)) {
            machine = device.model;
          } else {
            machine = '${device.manufacturer} ${device.model}';
          }
          if (machine.length < 19) {
            machine = '[$machine]';
          }
          newUserAgent += '($machine;Android${device.version.release})';
        }
        break;
    }

    return state.copy(
      client: state.client..userAgent = newUserAgent,
      settings: state.settings.copy(userAgent: userAgent),
    );
  }

  void after() => dispatch(SaveState());
}
