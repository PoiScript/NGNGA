import 'package:async_redux/async_redux.dart';

import 'package:ngnga/models/user.dart';

import 'state.dart';

class UpdateUsersAction extends ReduxAction<AppState> {
  final Iterable<MapEntry<int, User>> users;

  UpdateUsersAction(this.users) : assert(users != null);

  @override
  AppState reduce() {
    return state.copy(
      users: state.users..addEntries(users),
    );
  }
}
