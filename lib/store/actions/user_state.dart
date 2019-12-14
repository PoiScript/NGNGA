import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:async_redux/async_redux.dart';
import 'package:ngnga/store/state.dart';

import 'state_persist.dart';

class LoginAction extends ReduxAction<AppState> {
  final int uid;
  final String cid;

  LoginAction({
    @required this.uid,
    @required this.cid,
  });

  @override
  AppState reduce() {
    return state.copy(
      repository: state.repository..updateCookie(Logged(uid, cid)),
      userState: Logged(uid, cid),
    );
  }

  void after() => dispatch(SaveState());
}

class LogoutAction extends ReduxAction<AppState> {
  LogoutAction();

  @override
  AppState reduce() {
    return state.copy(
      repository: state.repository..updateCookie(Unlogged()),
      userState: Unlogged(),
      pinned: [],
    );
  }

  void after() => dispatch(SaveState());
}

class LoginAsGuestAction extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    // TODO: guest login

    // String uid = await loginAsGuest(
    //   client: state.client,
    //   baseUrl: state.settings.baseUrl,
    // );

    // return state.copy(
    //   repository: state.repository..updateCookie(Guest(uid)),
    //   userState: Guest(uid),
    // );

    return null;
  }

  void after() => dispatch(SaveState());
}
