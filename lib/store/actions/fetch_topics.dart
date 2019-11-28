import 'dart:async';

import 'package:async_redux/async_redux.dart';

import 'package:ngnga/utils/requests.dart';

import '../state.dart';

class FetchTopicsAction extends ReduxAction<AppState> {
  final int categoryId;

  FetchTopicsAction(this.categoryId) : assert(categoryId != null);

  @override
  Future<AppState> reduce() async {
    final res = await fetchCategoryTopics(
      client: state.client,
      categoryId: categoryId,
      page: 0,
      isSubcategory: state.categories[categoryId].isSubcategory,
      cookie: state.userState.cookie,
      baseUrl: state.settings.baseUrl,
    );

    return state.copy(
      categoryStates: state.categoryStates
        ..update(
          categoryId,
          (categoryState) => categoryState.copy(
            topicIds: res.topics.map((topic) => topic.id).toList(),
            topicsCount: res.topicCount,
            lastPage: 0,
            maxPage: res.maxPage,
          ),
        ),
      topics: state.topics
        ..addEntries(res.topics.map((topic) => MapEntry(topic.id, topic))),
      categories: state.categories
        ..addEntries(res.categories.map((cat) => MapEntry(cat.id, cat))),
    );
  }
}

class FetchNextTopicsAction extends ReduxAction<AppState> {
  final int categoryId;

  FetchNextTopicsAction(this.categoryId) : assert(categoryId != null);

  @override
  Future<AppState> reduce() async {
    final lastPage = state.categoryStates[categoryId].lastPage;

    final res = await fetchCategoryTopics(
      client: state.client,
      categoryId: categoryId,
      page: lastPage + 1,
      isSubcategory: state.categories[categoryId].isSubcategory,
      cookie: state.userState.cookie,
      baseUrl: state.settings.baseUrl,
    );

    List<int> topicIds = res.topics.map((t) => t.id).toList();

    return state.copy(
      categoryStates: state.categoryStates
        ..update(
          categoryId,
          (categoryState) => categoryState.copy(
            topicIds: categoryState.topicIds
              ..removeWhere((id) => topicIds.contains(id))
              ..addAll(topicIds),
            topicsCount: res.topicCount,
            lastPage: lastPage + 1,
            maxPage: res.maxPage,
          ),
        ),
      topics: state.topics
        ..addEntries(res.topics.map((topic) => MapEntry(topic.id, topic))),
      categories: state.categories
        ..addEntries(res.categories.map((cat) => MapEntry(cat.id, cat))),
    );
  }
}
