import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:async_redux/async_redux.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/utils/requests/login_as_guest.dart';

import 'state_persist.dart';

class LoggedAction extends ReduxAction<AppState> {
  final int uid;
  final String cid;

  LoggedAction({
    @required this.uid,
    @required this.cid,
  });

  @override
  AppState reduce() {
    return state.copy(
      userState: Logged(uid, cid),
    );
  }

  void after() => dispatch(SaveState());
}

class LoginAsGuestAction extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    String uid = await loginAsGuest(
      client: state.client,
      baseUrl: state.settings.baseUrl,
    );

    return state.copy(
      userState: Guest(uid),
    );
  }

  void after() => dispatch(SaveState());
}
