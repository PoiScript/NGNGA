import 'package:async_redux/async_redux.dart';
import 'package:built_value/built_value.dart';
import 'package:flutter/widgets.dart' hide Builder;

import 'package:business/user/models/user_state.dart';
import 'package:business/settings/actions/change_base_url_action.dart';
import 'package:business/settings/actions/change_locale_action.dart';
import 'package:business/settings/actions/change_theme_action.dart';
import 'package:business/app_state.dart';
import 'package:business/settings/models/settings_state.dart';
import 'package:business/user/actions/logout_action.dart';

import 'settings_page.dart';

part 'settings_page_connector.g.dart';

class SettingsPageConnector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel.fromStore(store),
      builder: (context, vm) => SettingsPage(
        baseUrl: vm.baseUrl,
        userState: vm.user,
        locale: vm.locale,
        theme: vm.theme,
        logout: vm.logout,
        changeBaseUrl: vm.changeBaseUrl,
        changeTheme: vm.changeTheme,
        changeLocale: vm.changeLocale,
      ),
    );
  }
}

abstract class _ViewModel implements Built<_ViewModel, _ViewModelBuilder> {
  _ViewModel._();

  factory _ViewModel([Function(_ViewModelBuilder) updates]) = _$ViewModel;

  String get baseUrl;
  UserState get user;
  AppTheme get theme;
  AppLocale get locale;
  Function() get logout;
  ValueChanged<String> get changeBaseUrl;
  ValueChanged<AppTheme> get changeTheme;
  ValueChanged<AppLocale> get changeLocale;

  factory _ViewModel.fromStore(Store<AppState> store) {
    return _ViewModel(
      (b) => b
        ..baseUrl = store.state.settings.baseUrl
        ..user = store.state.userState
        ..theme = store.state.settings.theme
        ..locale = store.state.settings.locale
        ..changeBaseUrl =
            ((domain) => store.dispatch(ChangeBaseUrlAction(domain)))
        ..logout = (() => store.dispatch(LogoutAction()))
        ..changeTheme = ((theme) => store.dispatch(ChangeThemeAction(theme)))
        ..changeLocale =
            ((locale) => store.dispatch(ChangeLocaleAction(locale))),
    );
  }
}
