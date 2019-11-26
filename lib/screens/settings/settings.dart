import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:ngnga/store/actions/settings.dart';
import 'package:ngnga/store/state.dart';

import 'cookies_editor.dart';

class SettingsPage extends StatelessWidget {
  final String baseUrl;
  final String uid;
  final String cid;

  final Function(String) changeBaseUrl;
  final Function({String uid, String cid}) changeCookies;

  SettingsPage({
    @required this.baseUrl,
    @required this.uid,
    @required this.cid,
    @required this.changeCookies,
    @required this.changeBaseUrl,
  })  : assert(baseUrl != null),
        assert(uid != null),
        assert(cid != null),
        assert(changeCookies != null),
        assert(changeBaseUrl != null);

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
          Container(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Background Color',
              style: Theme.of(context).textTheme.subhead,
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  child: const Text('White'),
                  color: Colors.teal[100],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  child: const Text('Yellow'),
                  color: Colors.teal[200],
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              _colorButton(context, 'Black', Colors.black),
            ],
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Primary Color',
              style: Theme.of(context).textTheme.subhead,
            ),
          ),
          Row(
            children: <Widget>[
              _colorButton(context, 'Blue', Colors.blue),
              _colorButton(context, 'Amber', Colors.amber),
            ],
          ),
          Row(
            children: <Widget>[
              _colorButton(context, 'Red', Colors.red),
              _colorButton(context, 'Green', Colors.green),
            ],
          ),
          Row(
            children: <Widget>[
              _colorButton(context, 'Purple', Colors.purple),
              _colorButton(context, 'Orange', Colors.orange),
            ],
          ),
          ListTile(
            title: Text('Change domain'),
            subtitle: Text(baseUrl),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () => _displayDomainDialog(context),
          ),
          ListTile(
            title: Text('Edit Cookies'),
            subtitle: Text('Logged as user $uid'),
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
            title: Text('About'),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () => {},
          ),
        ],
      ),
    );
  }

  Widget _colorButton(
    BuildContext context,
    String description,
    Color color,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: color,
        ),
        child: Center(
          child: Text(
            description,
            style:
                Theme.of(context).textTheme.body2.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  _displayDomainDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Change Domain',
            style: Theme.of(context).textTheme.body2,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile<String>(
                title: Text("bbs.nga.cn"),
                groupValue: baseUrl,
                value: "bbs.nga.cn",
                onChanged: (domain) {
                  changeBaseUrl(domain);
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<String>(
                title: Text("nga.178.com"),
                groupValue: baseUrl,
                value: "nga.178.com",
                onChanged: (domain) {
                  changeBaseUrl(domain);
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<String>(
                title: Text("ngabbs.com"),
                groupValue: baseUrl,
                value: "ngabbs.com",
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
        uid: uid,
        cid: cid,
        submitChanges: changeCookies,
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
        baseUrl: vm.baseUrl,
        uid: vm.uid,
        cid: vm.cid,
        changeCookies: vm.changeCookies,
        changeBaseUrl: vm.changeDomain,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  String baseUrl;
  String uid;
  String cid;

  Function(String) changeDomain;
  Function({String uid, String cid}) changeCookies;

  ViewModel();

  ViewModel.build({
    @required this.baseUrl,
    @required this.uid,
    @required this.cid,
    @required this.changeCookies,
    @required this.changeDomain,
  }) : super(equals: [baseUrl, uid, cid]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      baseUrl: state.settings.baseUrl,
      uid: state.settings.uid,
      cid: state.settings.cid,
      changeDomain: (domain) => store.dispatch(ChangeBaseUrlAction(domain)),
      changeCookies: ({String uid, String cid}) =>
          store.dispatch(ChangeCookiesAction(uid: uid, cid: cid)),
    );
  }
}
