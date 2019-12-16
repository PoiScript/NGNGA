import 'dart:async';

import 'package:async_redux/async_redux.dart';

import 'package:ngnga/models/category.dart';
import 'package:ngnga/store/category.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/store/topic.dart';

class FetchTopicsAction extends ReduxAction<AppState> {
  final int categoryId;
  final bool isSubcategory;

  FetchTopicsAction({
    this.categoryId,
    this.isSubcategory,
  })  : assert(categoryId != null),
        assert(isSubcategory != null);

  @override
  Future<AppState> reduce() async {
    if (state.categoryStates[categoryId] == null ||
        state.categoryStates[categoryId] is CategoryUninitialized) {
      await dispatchFuture(RefreshTopicsAction(
        categoryId: categoryId,
        isSubcategory: isSubcategory,
      ));
    }

    return null;
  }
}

class RefreshTopicsAction extends ReduxAction<AppState> {
  final int categoryId;
  final bool isSubcategory;

  RefreshTopicsAction({
    this.categoryId,
    this.isSubcategory,
  })  : assert(categoryId != null),
        assert(isSubcategory != null);

  @override
  Future<AppState> reduce() async {
    final res0 = await state.repository.fetchCategoryTopics(
      categoryId: categoryId,
      page: 0,
      isSubcategory: isSubcategory,
    );

    if (isSubcategory) {
      return state.copy(
        categoryStates: state.categoryStates
          ..[categoryId] = CategoryLoaded(
            topicIds: res0.topics.map((t) => t.id).toList(),
            topicsCount: res0.topicCount,
            lastPage: 0,
            maxPage: res0.maxPage,
            category: Category(
              id: categoryId,
              title: res0.topics.first.title,
              isSubcategory: isSubcategory,
            ),
            toppedTopicId: null,
            isPinned: state.pinned.indexWhere((c) => c.id == categoryId) != -1,
          ),
        topics: state.topics
          ..addEntries(res0.topics.map((t) => MapEntry(t.id, t))),
      );
    } else {
      final res1 = await state.repository
          .fetchTopicPosts(topicId: res0.toppedTopicId, page: 0);

      return state.copy(
        categoryStates: state.categoryStates
          ..[categoryId] = CategoryLoaded(
            topicIds: res0.topics.map((t) => t.id).toList(),
            topicsCount: res0.topicCount,
            lastPage: 0,
            maxPage: res0.maxPage,
            category: Category(
              id: categoryId,
              title: res1.forumName,
              isSubcategory: isSubcategory,
            ),
            toppedTopicId: res0.toppedTopicId,
            isPinned: state.pinned.indexWhere((c) => c.id == categoryId) != -1,
          ),
        topics: state.topics
          ..addEntries(res0.topics.map((t) => MapEntry(t.id, t))),
        topicStates: state.topicStates
          ..[res0.toppedTopicId] = TopicLoaded(
            topic: res1.topic,
            firstPage: 0,
            lastPage: 0,
            maxPage: res1.maxPage,
            postIds: res1.posts.map((p) => p.id).toList(),
            postVotedEvt: Event.spent(),
            isFavorited: false,
          ),
        users: state.users..addAll(res1.users),
        posts: state.posts
          ..addEntries(res1.posts.map((post) => MapEntry(post.id, post)))
          ..addEntries(res1.comments.map((post) => MapEntry(post.id, post))),
      );
    }
  }
}

class FetchNextTopicsAction extends ReduxAction<AppState> {
  final int categoryId;
  final bool isSubcategory;

  FetchNextTopicsAction({
    this.categoryId,
    this.isSubcategory,
  })  : assert(categoryId != null),
        assert(isSubcategory != null);

  @override
  Future<AppState> reduce() async {
    CategoryState categoryState = state.categoryStates[categoryId];

    if (categoryState is CategoryLoaded) {
      final res = await state.repository.fetchCategoryTopics(
        categoryId: categoryId,
        page: categoryState.lastPage + 1,
        isSubcategory: isSubcategory,
      );

      return state.copy(
        categoryStates: state.categoryStates
          ..[categoryId] = categoryState.copyWith(
            topicIds: categoryState.topicIds
              ..addAll(res.topics.map((t) => t.id)),
            topicsCount: res.topicCount,
            lastPage: categoryState.lastPage + 1,
            maxPage: res.maxPage,
          ),
        topics: state.topics
          ..addEntries(res.topics.map((t) => MapEntry(t.id, t))),
      );
    }

    return null;
  }
}
