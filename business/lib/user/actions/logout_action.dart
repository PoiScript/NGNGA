import 'package:async_redux/async_redux.dart';
import 'package:built_collection/built_collection.dart';

import 'package:business/user/models/user_state.dart';

import '../../app_state.dart';

class LogoutAction extends ReduxAction<AppState> {
  LogoutAction();

  @override
  AppState reduce() {
    return state.rebuild(
      (b) => b
        ..userState = UserStateBuilder()
        ..pinned = ListBuilder(),
    );
  }

  void after() => state.save();
}
