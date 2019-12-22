import 'package:async_redux/async_redux.dart';
import 'package:flutter/foundation.dart';

import 'package:business/user/models/user_state.dart';
import '../../app_state.dart';

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
        ..userState.status = UserStatus.logged
        ..userState.uid = uid
        ..userState.cid = cid,
    );
  }

  void after() => state.save();
}
