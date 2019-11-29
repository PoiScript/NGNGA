import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import 'package:ngnga/store/actions/user_state.dart';
import 'package:ngnga/store/state.dart';

class WelcomePage extends StatefulWidget {
  final Future<void> Function() loginAsGuest;

  const WelcomePage({
    Key key,
    @required this.loginAsGuest,
  }) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'ngaPassportUid',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        } else if (value.runes.any((i) => i < 48 || i > 57)) {
                          return 'Please input number only';
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                    width: 320.0,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 32.0,
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'ngaPassportCid',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
            FlatButton(
              child: Text('Submit'),
              onPressed: () {
                if (_formKey.currentState.validate()) {}
              },
            ),
            Divider(),
            FlatButton(
              child: Text('Anonymous Login'),
              onPressed: () async {
                await widget.loginAsGuest();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
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
      model: ViewModel(),
      builder: (context, vm) => WelcomePage(
        loginAsGuest: vm.loginAsGuest,
      ),
    );
  }
}

class ViewModel extends BaseModel<AppState> {
  Future<void> Function() loginAsGuest;

  ViewModel();

  ViewModel.build({
    @required this.loginAsGuest,
  });

  @override
  ViewModel fromStore() {
    return ViewModel.build(
      loginAsGuest: () => dispatchFuture(GuestLoginAction()),
    );
  }
}
