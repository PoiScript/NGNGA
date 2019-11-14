import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:ngnga/store/state.dart';

import 'cookies_editor.dart';

class SettingsPage extends StatelessWidget {
  final Map<String, String> cookies;
  final void Function(Map<String, String>) updateCookies;

  SettingsPage({
    @required this.cookies,
    @required this.updateCookies,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: Text(
          "Settings",
          style: Theme.of(context).textTheme.body2,
        ),
        titleSpacing: 0.0,
        backgroundColor: Colors.white,
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Edit Cookies'),
            subtitle: Text('${cookies.length} cookies pairs'),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditCookiesPageConnector(),
                ),
              ),
            },
          ),
        ],
      ),
    );
  }
}

class SettingsPageConnector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      model: ViewModel(),
      builder: (context, vm) => SettingsPage(
        cookies: vm.cookies,
        updateCookies: vm.updateCookies,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  Map<String, String> cookies;
  void Function(Map<String, String>) updateCookies;

  ViewModel();

  ViewModel.build({
    @required this.cookies,
    @required this.updateCookies,
  }) : super(equals: [cookies]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      cookies: state.cookies,
      updateCookies: (map) => {},
    );
  }
}
