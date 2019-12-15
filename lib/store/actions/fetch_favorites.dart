import 'dart:async';

import 'package:async_redux/async_redux.dart';

import 'package:ngnga/store/favorite.dart';
import 'package:ngnga/store/topic.dart';
import '../state.dart';

class FetchFavoritesAction extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    if (state.favoriteState is FavoriteUninitialized) {
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

    return state.copy(
      favoriteState: FavoriteLoaded(
        topicsCount: res.topicsCount,
        topicIds: res.topics.map((t) => t.id).toList(),
        maxPage: res.maxPage,
        lastPage: 0,
      ),
      topics: state.topics
        ..addEntries(res.topics.map((t) => MapEntry(t.id, t))),
      topicStates: state.topicStates
        ..updateAll(
          (id, topicsState) =>
              topicsState is TopicLoaded && favoriteIds.contains(id)
                  ? topicsState.copyWith(isFavorited: true)
                  : topicsState,
        ),
    );
  }
}
