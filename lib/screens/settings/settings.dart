import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:ngnga/store/actions/settings.dart';
import 'package:ngnga/store/state.dart';

import 'cookies_editor.dart';

const enumToStringMap = const {
  NgaDomain.nga178com: "nga.178.com",
  NgaDomain.bbsngacn: "bbs.nga.cn",
  NgaDomain.nagbbscom: "ngabbs.com",
};

class SettingsPage extends StatelessWidget {
  final NgaDomain ngaDomain;
  final String ngaUid;
  final String ngaCid;

  final Function(NgaDomain) changeDomain;
  final Function({String uid, String cid}) changeCookies;

  SettingsPage({
    @required this.ngaDomain,
    @required this.ngaUid,
    @required this.ngaCid,
    @required this.changeCookies,
    @required this.changeDomain,
  })  : assert(ngaDomain != null),
        assert(ngaUid != null),
        assert(ngaCid != null),
        assert(changeCookies != null),
        assert(changeDomain != null);

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
            subtitle: Text(enumToStringMap[ngaDomain]),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () => _displayDomainDialog(context),
          ),
          ListTile(
            title: Text('Edit Cookies'),
            subtitle: Text('Logged as user $ngaUid'),
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
              RadioListTile(
                title: Text("bbs.nga.cn"),
                groupValue: ngaDomain,
                value: NgaDomain.bbsngacn,
                onChanged: (domain) {
                  changeDomain(domain);
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile(
                title: Text("nga.178.com"),
                groupValue: ngaDomain,
                value: NgaDomain.nga178com,
                onChanged: (domain) {
                  changeDomain(domain);
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile(
                title: Text("ngabbs.com"),
                groupValue: ngaDomain,
                value: NgaDomain.nagbbscom,
                onChanged: (domain) {
                  changeDomain(domain);
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
        uid: ngaUid,
        cid: ngaCid,
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
        ngaDomain: vm.ngaDomain,
        ngaUid: vm.ngaUid,
        ngaCid: vm.ngaCid,
        changeCookies: vm.changeCookies,
        changeDomain: vm.changeDomain,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  NgaDomain ngaDomain;
  String ngaUid;
  String ngaCid;

  Function(NgaDomain) changeDomain;
  Function({String uid, String cid}) changeCookies;

  ViewModel();

  ViewModel.build({
    @required this.ngaDomain,
    @required this.ngaUid,
    @required this.ngaCid,
    @required this.changeCookies,
    @required this.changeDomain,
  }) : super(equals: [ngaDomain, ngaUid, ngaCid]);

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      ngaDomain: state.settings.domain,
      ngaUid: state.settings.uid,
      ngaCid: state.settings.cid,
      changeDomain: (domain) => store.dispatch(ChangeDomainAction(domain)),
      changeCookies: ({String uid, String cid}) =>
          store.dispatch(ChangeCookiesAction(uid: uid, cid: cid)),
    );
  }
}
