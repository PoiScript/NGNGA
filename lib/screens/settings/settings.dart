import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:ngnga/store/state.dart';

import 'cookies_editor.dart';

class SettingsPage extends StatelessWidget {
  final int cookieCount;

  SettingsPage({
    @required this.cookieCount,
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
            subtitle: Text('$cookieCount cookies pairs'),
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
        cookieCount: vm.cookieCount,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  int cookieCount;

  ViewModel();

  ViewModel.build({
    @required this.cookieCount,
  }) : super(equals: [cookieCount]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      cookieCount: state.cookies.length,
    );
  }
}
