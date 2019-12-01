import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import 'package:ngnga/localizations.dart';
import 'package:ngnga/store/actions/change_theme.dart';
import 'package:ngnga/store/actions/settings.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/style.dart';

import 'cookies_editor.dart';

class SettingsPage extends StatelessWidget {
  final String baseUrl;
  final UserState user;
  final AppTheme selectedTheme;

  final Function(String) changeBaseUrl;
  final Function({int uid, String cid}) changeCookies;
  final Function(AppTheme) changeTheme;

  SettingsPage({
    @required this.baseUrl,
    @required this.user,
    @required this.selectedTheme,
    @required this.changeCookies,
    @required this.changeBaseUrl,
    @required this.changeTheme,
  })  : assert(baseUrl != null),
        assert(user != null),
        assert(selectedTheme != null),
        assert(changeCookies != null),
        assert(changeBaseUrl != null),
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
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () => _displayDomainDialog(context),
          ),
          if (user is Logged)
            ListTile(
              title: Text(AppLocalizations.of(context).editCookies),
              subtitle: Text('Logged as user ${(user as Logged).uid}'),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () => _displayCookiesDialog(context),
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
            onTap: () => {},
          ),
        ],
      ),
    );
  }

  Widget _themeButton(BuildContext context, AppTheme appTheme) {
    ThemeData theme = _mapToThemeData(appTheme);
    return Card(
      color: selectedTheme == appTheme
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
            child: selectedTheme == appTheme
                ? Icon(
                    Icons.check,
                    size: 50,
                    color: Colors.white,
                  )
                : null,
          ),
          onTap: selectedTheme == appTheme ? null : () => changeTheme(appTheme),
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

  _displayCookiesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CookiesEditor(
        user: user,
        submitChanges: changeCookies,
      ),
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
        selectedTheme: vm.selectedTheme,
        changeCookies: vm.changeCookies,
        changeBaseUrl: vm.changeDomain,
        changeTheme: vm.changeTheme,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  String baseUrl;
  UserState user;
  AppTheme selectedTheme;

  Function(String) changeDomain;
  Function({int uid, String cid}) changeCookies;
  Function(AppTheme) changeTheme;

  ViewModel();

  ViewModel.build({
    @required this.baseUrl,
    @required this.user,
    @required this.selectedTheme,
    @required this.changeCookies,
    @required this.changeDomain,
    @required this.changeTheme,
  }) : super(equals: [selectedTheme, baseUrl, user]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
        baseUrl: state.settings.baseUrl,
        user: state.userState,
        selectedTheme: state.settings.theme,
        changeDomain: (domain) => store.dispatch(ChangeBaseUrlAction(domain)),
        changeCookies: ({int uid, String cid}) =>
            store.dispatch(ChangeCookiesAction(uid: uid, cid: cid)),
        changeTheme: (theme) => store.dispatch(ChangeThemeAction(theme)));
  }
}
