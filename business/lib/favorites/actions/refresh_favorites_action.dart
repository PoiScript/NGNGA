import 'package:async_redux/async_redux.dart';
import 'package:built_collection/built_collection.dart';

import 'package:business/models/topic.dart';
import 'package:business/topic/models/topic_state.dart';

import '../../app_state.dart';

class MaybeRefreshFavoritesAction extends ReduxAction<AppState> {
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
    final res = await state.repository.fetchFavorTopics(
      cookie: state.userState.cookie,
      baseUrl: state.settings.baseUrl,
      page: 0,
    );

    List<int> favoriteIds = res.topics.map((t) => t.id).toList(growable: false);

    return state.rebuild(
      (b) => b
        ..favoriteState.initialized = true
        ..favoriteState.topicsCount = res.topicsCount
        ..favoriteState.topicIds = ListBuilder(res.topics.map((t) => t.id))
        ..favoriteState.maxPage = res.maxPage
        ..favoriteState.lastPage = 0
        ..topicStates.update((b) {
          for (Topic topic in res.topics) {
            b.updateValue(
                topic.id, (s) => s.rebuild((b) => b.topic = topic.toBuilder()),
                ifAbsent: () => TopicState((b) => b.topic = topic.toBuilder()));
          }
        })
        ..topicStates.updateAllValues((id, topicsState) => topicsState
            .rebuild((b) => b.isFavorited = favoriteIds.contains(id))),
    );
  }
}
