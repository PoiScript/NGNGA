import 'dart:async';

import 'package:async_redux/async_redux.dart';

import 'package:ngnga/store/state.dart';
import 'package:ngnga/utils/requests.dart';

class FetchNotificationsAction extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    final res = await fetchNotifications(
      client: state.client,
      baseUrl: state.settings.baseUrl,
      cookie: state.settings.cookie,
    );

    return state.copy(
      notifications: res.notifications
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime)),
    );
  }
}
