import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:built_collection/built_collection.dart';

import 'package:ngnga/store/state.dart';

class FetchFavoritesAction extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    if (!state.favoriteState.initialized) {
      await dispatchFuture(RefreshFavoritesAction());
    }

    return null;
  }
}

class RefreshFavoritesAction extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    final res = await state.repository.fetchFavorTopics(page: 0);

    List<int> favoriteIds = res.topics.map((t) => t.id).toList();

    return state.rebuild(
      (b) => b
        ..favoriteState.initialized = true
        ..favoriteState.topicsCount = res.topicsCount
        ..favoriteState.topicIds = ListBuilder(res.topics.map((t) => t.id))
        ..favoriteState.maxPage = res.maxPage
        ..favoriteState.lastPage = 0
        ..topics.addEntries(res.topics.map((t) => MapEntry(t.id, t)))
        ..topicStates.updateAllValues(
          (id, topicsState) => topicsState
              .rebuild((b) => b.isFavorited = favoriteIds.contains(id)),
        ),
    );
  }
}
