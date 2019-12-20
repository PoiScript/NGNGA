import 'package:async_redux/async_redux.dart';
import 'package:flutter/foundation.dart';

import 'package:business/state_persistor/persist_state_action.dart';
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
        ..repository.cookie = 'ngaPassportUid=$uid;ngaPassportCid=$cid;'
        ..userState = UserLogged(uid, cid),
    );
  }

  void after() => dispatch(PersistStateAction());
}
