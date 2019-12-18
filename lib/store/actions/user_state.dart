import 'dart:async';

import 'package:built_collection/built_collection.dart';
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
    return state.rebuild(
      (b) => b
        ..repository.cookie = _updateCookie(UserLogged(uid, cid))
        ..userState = UserLogged(uid, cid),
    );
  }

  void after() => dispatch(SaveState());
}

class LogoutAction extends ReduxAction<AppState> {
  LogoutAction();

  @override
  AppState reduce() {
    return state.rebuild(
      (b) => b
        ..repository.cookie = _updateCookie(UserUninitialized())
        ..userState = UserUninitialized()
        ..pinned = ListBuilder(),
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

String _updateCookie(UserState userState) {
  if (userState is UserLogged) {
    return 'ngaPassportUid=${userState.uid};ngaPassportCid=${userState.cid};';
    // } else if (userState is Guest) {
    //   // TODO: guest login
    //   cookie = 'ngaPassportUid=${userState.uid};';
  } else if (userState is UserUninitialized) {
    return '';
  }
  return null;
}
