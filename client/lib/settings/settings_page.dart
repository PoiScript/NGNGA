import 'package:flutter/material.dart' hide Builder;

import 'package:business/app_state.dart';
import 'package:business/settings/models/settings_state.dart';

import 'package:ngnga/localizations.dart';
import 'package:ngnga/main.dart';

import 'about_page.dart';

class SettingsPage extends StatelessWidget {
  final String baseUrl;
  final UserState userState;
  final AppTheme theme;
  final AppLocale locale;

  final VoidCallback logout;
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
  })  : assert(baseUrl != null),
        assert(userState != null),
        assert(theme != null),
        assert(locale != null),
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
            onTap: () => _changeDomain(context),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context).language),
            subtitle: Text(
              const {AppLocale.en: 'English', AppLocale.zh: '中文'}[locale],
            ),
            onTap: () => _changeLocale(context),
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
