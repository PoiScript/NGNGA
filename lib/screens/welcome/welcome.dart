import 'dart:convert';

import 'package:async_redux/async_redux.dart';
import 'package:built_value/built_value.dart';
import 'package:flutter/material.dart' hide Builder;
import 'package:http/http.dart';

import 'package:ngnga/store/actions/user.dart';
import 'package:ngnga/store/state.dart';

part 'welcome.g.dart';

class WelcomePage extends StatefulWidget {
  final Future<void> Function() loginAsGuest;
  final Future<void> Function(int, String) logged;
  final Future<bool> Function(int, String) validate;

  const WelcomePage({
    Key key,
    @required this.loginAsGuest,
    @required this.logged,
    @required this.validate,
  }) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLogging = false;

  int uid;
  String cid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome to'),
            Text(
              'NGNGA',
              style: Theme.of(context)
                  .textTheme
                  .title
                  .copyWith(fontWeight: FontWeight.w500),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Container(
                    width: 320.0,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 32.0,
                    ),
                    child: TextFormField(
                      enabled: !_isLogging,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'ngaPassportUid',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }

                        int uid = int.tryParse(value);

                        if (uid == null) {
                          return 'Please input number only';
                        }

                        return null;
                      },
                      onSaved: (val) => uid = int.tryParse(val),
                    ),
                  ),
                  Container(
                    width: 320.0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32.0,
                    ),
                    child: TextFormField(
                      enabled: !_isLogging,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'ngaPassportCid',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }

                        if (value.runes.any((i) => i < 0x21 || 0x7e < i)) {
                          return 'Please input ASCII only';
                        }

                        return null;
                      },
                      onSaved: (val) => cid = val,
                    ),
                  ),
                ],
              ),
            ),
            FlatButton(
              child: Text(
                _isLogging ? 'Checking...' : 'Login',
              ),
              onPressed: _isLogging
                  ? null
                  : () async {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        setState(() => _isLogging = true);
                        bool validated = await widget.validate(uid, cid);
                        if (!validated) {
                          _scaffoldKey.currentState
                            ..removeCurrentSnackBar()
                            ..showSnackBar(SnackBar(content: Text('invalid')));
                          setState(() => _isLogging = false);
                        } else {
                          await widget.logged(uid, cid);
                          Navigator.pushReplacementNamed(context, '/');
                        }
                      }
                    },
            ),
            // TODO: guest login
            // Divider(),
            // FlatButton(
            //   child: Text('Login As Guest'),
            //   onPressed: () async {
            //     await widget.loginAsGuest();
            //     Navigator.pushReplacementNamed(context, '/');
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}

class WelcomePageConnector extends StatelessWidget {
  WelcomePageConnector();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      converter: (store) => ViewModel.fromStore(store),
      builder: (context, vm) => WelcomePage(
        loginAsGuest: vm.loginAsGuest,
        logged: vm.login,
        validate: vm.validate,
      ),
    );
  }
}

abstract class ViewModel implements Built<ViewModel, ViewModelBuilder> {
  ViewModel._();

  factory ViewModel([Function(ViewModelBuilder) updates]) = _$ViewModel;

  Future<void> Function() get loginAsGuest;
  Future<void> Function(int, String) get login;
  Future<bool> Function(int, String) get validate;

  factory ViewModel.fromStore(Store<AppState> store) {
    return ViewModel(
      (b) => b
        ..loginAsGuest = (() => store.dispatchFuture(LoginAsGuestAction()))
        ..login = ((int uid, String cid) =>
            store.dispatchFuture(LoginAction(uid: uid, cid: cid)))
        ..validate = (int uid, String cid) async {
          final res = await get(
            'https://ngabbs.com/nuke.php?__lib=noti&__act=if&__output=11',
            headers: {'cookie': 'ngaPassportUid=$uid;ngaPassportCid=$cid;'},
          );

          final json = jsonDecode(res.body);

          return json['data'] != null;
        },
    );
  }
}
