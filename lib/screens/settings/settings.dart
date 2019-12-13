import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import 'package:ngnga/localizations.dart';
import 'package:ngnga/store/actions.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/style.dart';

import 'about.dart';

class SettingsPage extends StatelessWidget {
  final String baseUrl;
  final UserState user;
  final AppTheme currentTheme;
  final AppLocale currentLocale;

  final VoidCallback logout;
  final ValueChanged<String> changeBaseUrl;
  final ValueChanged<AppTheme> changeTheme;
  final ValueChanged<AppLocale> changeLocale;

  SettingsPage({
    @required this.baseUrl,
    @required this.user,
    @required this.currentTheme,
    @required this.currentLocale,
    @required this.logout,
    @required this.changeBaseUrl,
    @required this.changeTheme,
    @required this.changeLocale,
  })  : assert(baseUrl != null),
        assert(user != null),
        assert(currentTheme != null),
        assert(currentLocale != null),
        assert(logout != null),
        assert(changeBaseUrl != null),
        assert(changeLocale != null),
        assert(changeTheme != null);

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
            onTap: () => _displayDomainDialog(context),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context).language),
            subtitle: Text(
              const {
                AppLocale.en: 'English',
                AppLocale.zh: '中文'
              }[currentLocale],
            ),
            onTap: () => _displayLanguageDialog(context),
          ),
          if (user is Logged)
            ListTile(
              title: Text(AppLocalizations.of(context).logout),
              onTap: () {
                logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  'welcome',
                  (route) => false,
                );
              },
            ),
          // ListTile(
          //   title: Text('Device Info'),
          //   trailing: Icon(Icons.keyboard_arrow_right),
          //   onTap: () => {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => EditCookiesPageConnector(),
          //       ),
          //     ),
          //   },
          // ),
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

  Widget _themeButton(BuildContext context, AppTheme appTheme) {
    ThemeData theme = _mapToThemeData(appTheme);
    return Card(
      color: currentTheme == appTheme
          ? Color.alphaBlend(
              Color.fromRGBO(0, 0, 0, 0.2),
              theme.cardColor,
            )
          : theme.cardColor,
      child: CustomPaint(
        painter: CirclePainter(theme),
        child: InkWell(
          child: Container(
            height: 100,
            width: 100,
            alignment: Alignment.center,
            child: currentTheme == appTheme
                ? Icon(
                    Icons.check,
                    size: 50,
                    color: Colors.white,
                  )
                : null,
          ),
          onTap: currentTheme == appTheme ? null : () => changeTheme(appTheme),
        ),
      ),
    );
  }

  ThemeData _mapToThemeData(AppTheme theme) {
    ThemeData themeData;
    switch (theme) {
      case AppTheme.white:
        themeData = whiteTheme;
        break;
      case AppTheme.black:
        themeData = blackTheme;
        break;
      case AppTheme.grey:
        themeData = greyTheme;
        break;
      case AppTheme.yellow:
        themeData = yellowTheme;
        break;
    }
    return themeData;
  }

  _displayDomainDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context).changeDomain,
            style: Theme.of(context).textTheme.body2,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile<String>(
                title: Text('bbs.nga.cn'),
                groupValue: baseUrl,
                value: 'bbs.nga.cn',
                onChanged: (domain) {
                  changeBaseUrl(domain);
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<String>(
                title: Text('nga.178.com'),
                groupValue: baseUrl,
                value: 'nga.178.com',
                onChanged: (domain) {
                  changeBaseUrl(domain);
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<String>(
                title: Text('ngabbs.com'),
                groupValue: baseUrl,
                value: 'ngabbs.com',
                onChanged: (domain) {
                  changeBaseUrl(domain);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  _displayLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context).language,
            style: Theme.of(context).textTheme.body2,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile<AppLocale>(
                title: Text('English'),
                groupValue: currentLocale,
                value: AppLocale.en,
                onChanged: (locale) {
                  changeLocale(locale);
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<AppLocale>(
                title: Text('中文'),
                groupValue: currentLocale,
                value: AppLocale.zh,
                onChanged: (locale) {
                  changeLocale(locale);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
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
        user: vm.user,
        currentLocale: vm.currentLocale,
        currentTheme: vm.currentTheme,
        logout: vm.logout,
        changeBaseUrl: vm.changeBaseUrl,
        changeTheme: vm.changeTheme,
        changeLocale: vm.changeLocale,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  String baseUrl;
  UserState user;
  AppTheme currentTheme;
  AppLocale currentLocale;

  ValueChanged<String> changeBaseUrl;
  VoidCallback logout;
  ValueChanged<AppTheme> changeTheme;
  ValueChanged<AppLocale> changeLocale;

  ViewModel();

  ViewModel.build({
    @required this.baseUrl,
    @required this.user,
    @required this.currentTheme,
    @required this.currentLocale,
    @required this.logout,
    @required this.changeBaseUrl,
    @required this.changeTheme,
    @required this.changeLocale,
  }) : super(equals: [currentTheme, currentLocale, baseUrl, user]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      baseUrl: state.settings.baseUrl,
      user: state.userState,
      currentTheme: state.settings.theme,
      currentLocale: state.settings.locale,
      changeBaseUrl: (domain) => store.dispatch(ChangeBaseUrlAction(domain)),
      logout: () => store.dispatch(LogoutAction()),
      changeTheme: (theme) => store.dispatch(ChangeThemeAction(theme)),
      changeLocale: (locale) => store.dispatch(ChangeLocaleAction(locale)),
    );
  }
}
