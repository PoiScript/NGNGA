import 'package:async_redux/async_redux.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:flutter/widgets.dart' hide Builder;

import 'package:business/inbox/actions/refresh_notifications_action.dart';
import 'package:business/app_state.dart';
import 'package:business/favorites/actions/refresh_favorites_action.dart';
import 'package:business/favorites/models/favorite_state.dart';
import 'package:business/inbox/models/inbox_state.dart';
import 'package:business/models/category.dart';
import 'package:business/topic/models/topic_state.dart';

import 'home_page.dart';

part 'home_page_connector.g.dart';

class HomePageConnector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel.fromStore(store),
      builder: (context, vm) => HomePage(
        favoriteState: vm.favoriteState,
        topics: vm.topics,
        refreshFavorites: vm.refreshFavorites,
        maybeRefreshFavorites: vm.maybeRefreshFavorites,
        pinned: vm.pinned,
        inboxState: vm.inboxState,
        refreshInbox: vm.refreshInbox,
        maybeRefreshInbox: vm.maybeRefreshInbox,
      ),
    );
  }
}

abstract class _ViewModel implements Built<_ViewModel, _ViewModelBuilder> {
  _ViewModel._();

  factory _ViewModel([Function(_ViewModelBuilder) updates]) = _$ViewModel;

  FavoriteState get favoriteState;
  BuiltMap<int, TopicState> get topics;

  Future<void> Function() get refreshFavorites;
  Future<void> Function() get maybeRefreshFavorites;

  BuiltList<Category> get pinned;

  InboxState get inboxState;
  Future<void> Function() get refreshInbox;
  Future<void> Function() get maybeRefreshInbox;

  factory _ViewModel.fromStore(Store<AppState> store) => _ViewModel((b) => b
    ..favoriteState =
        store.state.favoriteState.toBuilder() ?? FavoriteStateBuilder()
    ..topics = store.state.topicStates.toBuilder()
    ..refreshFavorites = (() => store.dispatchFuture(RefreshFavoritesAction()))
    ..maybeRefreshFavorites =
        (() => store.dispatchFuture(MaybeRefreshFavoritesAction()))
    ..pinned = store.state.pinned.toBuilder()
    ..inboxState = store.state.inboxState.toBuilder()
    ..refreshInbox = (() => store.dispatchFuture(RefreshNotificationsAction()))
    ..maybeRefreshInbox =
        (() => store.dispatchFuture(MaybeRefreshNotificationsAction())));
}
