import 'dart:io';

import 'package:async_redux/async_redux.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';

import 'package:ngnga/localizations.dart';
import 'package:ngnga/main.dart';
import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';

import 'about.dart';

final _deviceInfo = DeviceInfoPlugin();

class SettingsPage extends StatelessWidget {
  final String baseUrl;
  final UserState userState;
  final AppTheme theme;
  final AppLocale locale;
  final UserAgent userAgent;

  final VoidCallback logout;
  final ValueChanged<UserAgent> changeUserAgent;
  final ValueChanged<String> changeBaseUrl;
  final ValueChanged<AppTheme> changeTheme;
  final ValueChanged<AppLocale> changeLocale;

  SettingsPage({
    @required this.baseUrl,
    @required this.userState,
    @required this.theme,
    @required this.locale,
    @required this.logout,
    @required this.changeBaseUrl,
    @required this.changeTheme,
    @required this.changeLocale,
    @required this.userAgent,
    @required this.changeUserAgent,
  })  : assert(baseUrl != null),
        assert(userState != null),
        assert(theme != null),
        assert(locale != null),
        assert(logout != null),
        assert(userAgent != null),
        assert(changeBaseUrl != null),
        assert(changeLocale != null),
        assert(changeTheme != null),
        assert(changeUserAgent != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        title: Text(
          AppLocalizations.of(context).settings,
          style: Theme.of(context).textTheme.body2,
        ),
        titleSpacing: 0.0,
        backgroundColor: Theme.of(context).cardColor,
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(AppLocalizations.of(context).theme),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: <Widget>[
                _themeButton(context, AppTheme.white),
                _themeButton(context, AppTheme.black),
              ],
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context).changeDomain),
            subtitle: Text(baseUrl),
            onTap: () => _changeDomain(context),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context).language),
            subtitle: Text(
              const {AppLocale.en: 'English', AppLocale.zh: '中文'}[locale],
            ),
            onTap: () => _changeLocale(context),
          ),
          ListTile(
            title: Text('Device Info'),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () => _changeUserAgent(context),
          ),
          if (userState is UserLogged)
            ListTile(
              title: Text(AppLocalizations.of(context).logout),
              onTap: () => _logout(context),
            ),
          ListTile(
            title: Text(AppLocalizations.of(context).about),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  _logout(BuildContext context) async {
    bool confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout?'),
        content: Text('All your data will be permanently erased.'),
        actions: [
          FlatButton(
            child: Text(
              'CANCEL',
            ),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          FlatButton(
            child: Text(
              'OK',
              style: Theme.of(context)
                  .textTheme
                  .button
                  .copyWith(color: Theme.of(context).errorColor),
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      logout();
      Navigator.pushNamedAndRemoveUntil(context, 'welcome', (route) => false);
    }
  }

  Widget _themeButton(BuildContext context, AppTheme appTheme) {
    ThemeData themeData = themeDataMap[appTheme];
    return Card(
      color: theme == appTheme
          ? Color.alphaBlend(
              Color.fromRGBO(0, 0, 0, 0.2),
              themeData.cardColor,
            )
          : themeData.cardColor,
      child: CustomPaint(
        painter: CirclePainter(themeData),
        child: InkWell(
          child: Container(
            height: 100,
            width: 100,
            alignment: Alignment.center,
            child: theme == appTheme
                ? Icon(
                    Icons.check,
                    size: 50,
                    color: Colors.white,
                  )
                : null,
          ),
          onTap: theme == appTheme ? null : () => changeTheme(appTheme),
        ),
      ),
    );
  }

  _changeUserAgent(BuildContext context) async {
    String fullUserAgent = '';
    String shortUserAgent = '';
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
      shortUserAgent = '仅显示 "Android${androidInfo.version.release}"';
      fullUserAgent =
          '显示 "${androidInfo.model} (Android${androidInfo.version.release})"';
    }
    UserAgent selectedUserAgent = await showDialog<UserAgent>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Device Info',
            style: Theme.of(context).textTheme.body2,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 20.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile<UserAgent>(
                title: Text('隐藏'),
                subtitle: Text('隐藏客户端'),
                groupValue: userAgent,
                value: UserAgent.none,
                onChanged: (_) => Navigator.of(context).pop(UserAgent.none),
              ),
              RadioListTile<UserAgent>(
                title: Text('只显示系统'),
                subtitle: Text(shortUserAgent),
                groupValue: userAgent,
                value: UserAgent.osOnly,
                onChanged: (_) => Navigator.of(context).pop(UserAgent.osOnly),
              ),
              RadioListTile<UserAgent>(
                title: Text('完整显示'),
                subtitle: Text(fullUserAgent),
                groupValue: userAgent,
                value: UserAgent.full,
                onChanged: (_) => Navigator.of(context).pop(UserAgent.full),
              ),
            ],
          ),
        );
      },
    );
    if (selectedUserAgent != null) {
      changeUserAgent(selectedUserAgent);
    }
  }

  _changeDomain(BuildContext context) async {
    String domain = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context).changeDomain,
            style: Theme.of(context).textTheme.body2,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 20.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile<String>(
                title: const Text('bbs.nga.cn'),
                groupValue: baseUrl,
                value: 'bbs.nga.cn',
                onChanged: (_) => Navigator.of(context).pop('bbs.nga.cn'),
              ),
              RadioListTile<String>(
                title: const Text('nga.178.com'),
                groupValue: baseUrl,
                value: 'nga.178.com',
                onChanged: (_) => Navigator.of(context).pop('nga.178.com'),
              ),
              RadioListTile<String>(
                title: const Text('ngabbs.com'),
                groupValue: baseUrl,
                value: 'ngabbs.com',
                onChanged: (_) => Navigator.of(context).pop('ngabbs.com'),
              ),
            ],
          ),
        );
      },
    );
    if (domain != null) {
      changeBaseUrl(domain);
    }
  }

  _changeLocale(BuildContext context) async {
    AppLocale selectedLocale = await showDialog<AppLocale>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context).language,
            style: Theme.of(context).textTheme.body2,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 20.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile<AppLocale>(
                title: const Text('English'),
                groupValue: locale,
                value: AppLocale.en,
                onChanged: (_) => Navigator.of(context).pop(AppLocale.en),
              ),
              RadioListTile<AppLocale>(
                title: const Text('中文'),
                groupValue: locale,
                value: AppLocale.zh,
                onChanged: (_) => Navigator.of(context).pop(AppLocale.zh),
              ),
            ],
          ),
        );
      },
    );
    if (selectedLocale != null) {
      changeLocale(selectedLocale);
    }
  }
}

class CirclePainter extends CustomPainter {
  final ThemeData themeData;

  CirclePainter(this.themeData);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(
        size.width - 24.0,
        size.height - 24.0,
      ),
      12.0,
      Paint()..color = themeData.accentColor,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}

class SettingsPageConnector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(),
      builder: (context, vm) => SettingsPage(
        baseUrl: vm.baseUrl,
        userState: vm.user,
        locale: vm.locale,
        theme: vm.theme,
        logout: vm.logout,
        userAgent: vm.userAgent,
        changeBaseUrl: vm.changeBaseUrl,
        changeTheme: vm.changeTheme,
        changeLocale: vm.changeLocale,
        changeUserAgent: vm.changeUserAgent,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  String baseUrl;
  UserState user;
  AppTheme theme;
  AppLocale locale;
  UserAgent userAgent;

  VoidCallback logout;
  ValueChanged<UserAgent> changeUserAgent;
  ValueChanged<String> changeBaseUrl;
  ValueChanged<AppTheme> changeTheme;
  ValueChanged<AppLocale> changeLocale;

  ViewModel();

  ViewModel.build({
    @required this.baseUrl,
    @required this.user,
    @required this.theme,
    @required this.locale,
    @required this.logout,
    @required this.userAgent,
    @required this.changeBaseUrl,
    @required this.changeTheme,
    @required this.changeLocale,
    @required this.changeUserAgent,
  }) : super(equals: [theme, locale, baseUrl, user, userAgent]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      baseUrl: state.settings.baseUrl,
      user: state.userState,
      theme: state.settings.theme,
      locale: state.settings.locale,
      userAgent: state.settings.userAgent,
      changeBaseUrl: (domain) => store.dispatch(ChangeBaseUrlAction(domain)),
      logout: () => store.dispatch(LogoutAction()),
      changeUserAgent: (userAgent) =>
          store.dispatch(ChangeUserAgentAction(userAgent)),
      changeTheme: (theme) => store.dispatch(ChangeThemeAction(theme)),
      changeLocale: (locale) => store.dispatch(ChangeLocaleAction(locale)),
    );
  }
}
