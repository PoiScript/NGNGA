import 'dart:async';

import 'package:async_redux/async_redux.dart';

import 'package:ngnga/utils/requests.dart';

import '../state.dart';

class FetchFavoritesAction extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    final res = await fetchFavorTopics(
      client: state.client,
      cookie: state.cookie,
      baseUrl: state.settings.baseUrl,
      page: 0,
    );

    return state.copy(
      favoriteState: state.favoriteState.copy(
        topicsCount: res.topicsCount,
        topicIds: res.topics.map((topic) => topic.id).toList(),
        maxPage: res.maxPage,
        lastPage: 0,
      ),
      topics: state.topics
        ..addEntries(res.topics.map((topic) => MapEntry(topic.id, topic))),
    );
  }
}
