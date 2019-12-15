import 'dart:async';

import 'package:async_redux/async_redux.dart';

import 'package:ngnga/store/inbox.dart';
import 'package:ngnga/store/state.dart';

class FetchNotificationsAction extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    if (state.inboxState is InboxUninitialized) {
      await dispatchFuture(RefreshNotificationsAction());
    }

    return null;
  }
}

class RefreshNotificationsAction extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    final res = await state.repository.fetchNotifications();

    return state.copy(
      inboxState: InboxLoaded(
        notifications: res.notifications
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime)),
      ),
    );
  }
}
