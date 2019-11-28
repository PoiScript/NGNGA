import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/utils/requests/login_as_guest.dart';

class GuestLoginAction extends ReduxAction<AppState> {
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
}
