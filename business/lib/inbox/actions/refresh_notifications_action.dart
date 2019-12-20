import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:built_collection/built_collection.dart';

import '../../app_state.dart';

class MaybeRefreshNotificationsAction extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    if (!state.inboxState.initialized) {
      await dispatchFuture(RefreshNotificationsAction());
    }

    return null;
  }
}

class RefreshNotificationsAction extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    final res = await state.repository.fetchNotifications();

    return state.rebuild(
      (b) => b
        ..inboxState.initialized = true
        ..inboxState.notifications = ListBuilder(
          res.notifications..sort((a, b) => b.dateTime.compareTo(a.dateTime)),
        ),
    );
  }
}
