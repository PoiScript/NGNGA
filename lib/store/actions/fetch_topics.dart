import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:built_collection/built_collection.dart';

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
        !state.categoryStates[categoryId].initialized) {
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
      Category category = Category(
        id: categoryId,
        title: res0.topics.first.title,
        isSubcategory: isSubcategory,
      );

      return state.rebuild(
        (b) => b
          ..categoryStates[categoryId] = CategoryState(
            (b) => b
              ..initialized = true
              ..topicIds = SetBuilder(res0.topics.map((t) => t.id))
              ..topicsCount = res0.topicCount
              ..maxPage = res0.maxPage
              ..category = category
              ..isPinned = state.pinned.contains(category),
          )
          ..topics.addEntries(res0.topics.map((t) => MapEntry(t.id, t))),
      );
    } else {
      final res1 = await state.repository
          .fetchTopicPosts(topicId: res0.toppedTopicId, page: 0);

      Category category = Category(
        id: categoryId,
        title: res1.forumName,
        isSubcategory: isSubcategory,
      );

      return state.rebuild(
        (b) => b
          ..categoryStates[categoryId] = CategoryState(
            (b) => b
              ..initialized = true
              ..topicIds = SetBuilder(res0.topics.map((t) => t.id))
              ..topicsCount = res0.topicCount
              ..maxPage = res0.maxPage
              ..category = category
              ..toppedTopicId = res0.toppedTopicId
              ..isPinned = state.pinned.contains(category),
          )
          ..topics.addEntries(res0.topics.map((t) => MapEntry(t.id, t)))
          ..topicStates[res0.toppedTopicId] = TopicState(
            (b) => b
              ..initialized = true
              ..topic = res1.topic
              ..maxPage = res1.maxPage
              ..postIds = SetBuilder(res1.posts.map((p) => p.id)),
          )
          ..users.addAll(res1.users)
          ..posts.addEntries(res1.posts.map((p) => MapEntry(p.id, p)))
          ..posts.addEntries(res1.comments.map((p) => MapEntry(p.id, p))),
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

    final res = await state.repository.fetchCategoryTopics(
      categoryId: categoryId,
      page: categoryState.lastPage + 1,
      isSubcategory: isSubcategory,
    );

    return state.rebuild(
      (b) => b
        ..categoryStates[categoryId] = categoryState.rebuild(
          (b) => b
            ..topicIds.addAll(res.topics.map((t) => t.id))
            ..topicsCount = res.topicCount
            ..lastPage = categoryState.lastPage + 1
            ..maxPage = res.maxPage,
        )
        ..topics.addEntries(res.topics.map((t) => MapEntry(t.id, t))),
    );
  }
}
