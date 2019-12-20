import 'package:async_redux/async_redux.dart';
import 'package:built_collection/built_collection.dart';
import 'package:business/state_persistor/persist_state_action.dart';

import '../../app_state.dart';

class LogoutAction extends ReduxAction<AppState> {
  LogoutAction();

  @override
  AppState reduce() {
    return state.rebuild(
      (b) => b
        ..repository.cookie = ''
        ..userState = UserUninitialized()
        ..pinned = ListBuilder(),
    );
  }

  void after() => dispatch(PersistStateAction());
}
