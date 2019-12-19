import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';

import 'package:ngnga/models/category.dart';
import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/topic.dart';
import 'package:ngnga/store/category.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/store/topic.dart';

abstract class CategoryBaseAction extends ReduxAction<AppState> {
  int get categoryId;

  CategoryState get categoryState => state.categoryStates[categoryId];
}

class JumpToPageAction extends CategoryBaseAction {
  final int categoryId;
  final bool isSubcategory;
  final int pageIndex;

  JumpToPageAction({
    @required this.categoryId,
    @required this.isSubcategory,
    @required this.pageIndex,
  });

  @override
  Future<AppState> reduce() async {
    assert(categoryState == null || !categoryState.initialized);

    final res0 = await state.repository.fetchCategoryTopics(
      categoryId: categoryId,
      isSubcategory: isSubcategory,
      page: pageIndex,
    );

    if (isSubcategory) {
      if (state.categoryStates.containsKey(categoryId)) {
        return state.rebuild(
          (b) => b
            ..categoryStates.updateValue(
              categoryId,
              (categoryState) => categoryState.rebuild(
                (b) => b
                  ..initialized = true
                  ..topicIds = SetBuilder(res0.topics.map((t) => t.id))
                  ..topicsCount = res0.topicCount
                  ..maxPage = res0.maxPage
                  ..firstPage = pageIndex
                  ..lastPage = pageIndex,
              ),
            )
            ..topicStates.update(_udpateTopicState(res0.topics)),
        );
      } else {
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
                ..firstPage = pageIndex
                ..lastPage = pageIndex
                ..category = category
                ..isPinned = state.pinned.contains(category),
            )
            ..topicStates.update(_udpateTopicState(res0.topics)),
        );
      }
    } else {
      if (state.categoryStates.containsKey(categoryId)) {
        return state.rebuild(
          (b) => b
            ..categoryStates.updateValue(
              categoryId,
              (categoryState) => categoryState.rebuild(
                (b) => b
                  ..initialized = true
                  ..topicIds = SetBuilder(res0.topics.map((t) => t.id))
                  ..topicsCount = res0.topicCount
                  ..maxPage = res0.maxPage
                  ..firstPage = pageIndex
                  ..lastPage = pageIndex
                  ..toppedTopicId = res0.toppedTopicId,
              ),
            )
            ..topicStates.update(_udpateTopicState(res0.topics)),
        );
      } else {
        final res1 = await state.repository.fetchTopicPosts(
          topicId: res0.toppedTopicId,
          page: 0,
        );

        Category category = Category(
          id: categoryId,
          title: res1.forumName,
          isSubcategory: isSubcategory,
        );

        List<Post> posts = res1.posts.whereType<Post>().toList(growable: false);

        return state.rebuild(
          (b) => b
            ..categoryStates[categoryId] = CategoryState(
              (b) => b
                ..initialized = true
                ..topicIds = SetBuilder(res0.topics.map((t) => t.id))
                ..topicsCount = res0.topicCount
                ..firstPage = pageIndex
                ..lastPage = pageIndex
                ..maxPage = res0.maxPage
                ..category = category
                ..toppedTopicId = res0.toppedTopicId
                ..isPinned = state.pinned.contains(category),
            )
            ..topicStates.update(_udpateTopicState(res0.topics))
            ..topicStates[res0.toppedTopicId] = TopicState(
              (b) => b
                ..initialized = true
                ..topic = res1.topic
                ..firstPage = 0
                ..lastPage = 0
                ..postIds = SetBuilder(posts.map((p) => p.id)),
            )
            ..users.addAll(res1.users)
            ..posts.addEntries(posts.map((p) => MapEntry(p.id, p)))
            ..posts.addEntries(res1.comments.map((p) => MapEntry(p.id, p))),
        );
      }
    }
  }

  void before() => dispatch(_SetUninitialized(categoryId));
}

class _SetUninitialized extends CategoryBaseAction {
  final int categoryId;

  _SetUninitialized(this.categoryId);

  @override
  AppState reduce() {
    if (state.categoryStates.containsKey(categoryId)) {
      return state.rebuild(
        (b) => b.categoryStates.updateValue(
          categoryId,
          (categoryState) => categoryState.rebuild(
            (b) => b.initialized = false,
          ),
        ),
      );
    } else {
      return null;
    }
  }
}

class RefreshFirstPageAction extends CategoryBaseAction {
  final int categoryId;
  final bool isSubcategory;

  RefreshFirstPageAction({
    @required this.categoryId,
    @required this.isSubcategory,
  })  : assert(categoryId != null),
        assert(isSubcategory != null);

  @override
  Future<AppState> reduce() async {
    assert(categoryState.initialized);
    assert(categoryState.firstPage == 0);

    final res = await state.repository.fetchCategoryTopics(
      categoryId: categoryId,
      isSubcategory: isSubcategory,
      page: 0,
    );

    return state.rebuild(
      (b) => b
        ..categoryStates[categoryId] = categoryState.rebuild(
          (b) => b
            ..topicIds = SetBuilder(res.topics.map((t) => t.id))
            ..topicsCount = res.topicCount
            ..maxPage = res.maxPage
            ..firstPage = 0,
        )
        ..topicStates.update(_udpateTopicState(res.topics)),
    );
  }
}

class LoadPreviousPageAction extends CategoryBaseAction {
  final int categoryId;
  final bool isSubcategory;

  LoadPreviousPageAction({
    @required this.categoryId,
    @required this.isSubcategory,
  })  : assert(categoryId != null),
        assert(isSubcategory != null);

  @override
  Future<AppState> reduce() async {
    assert(categoryState.initialized);
    assert(!categoryState.hasRechedMin);

    final res = await state.repository.fetchCategoryTopics(
      categoryId: categoryId,
      page: categoryState.firstPage - 1,
      isSubcategory: isSubcategory,
    );

    return state.rebuild(
      (b) => b
        ..categoryStates[categoryId] = categoryState.rebuild(
          (b) => b
            ..topicIds = (SetBuilder(res.topics.map((t) => t.id))
              ..addAll(categoryState.topicIds))
            ..topicsCount = res.topicCount
            ..firstPage = categoryState.firstPage - 1
            ..maxPage = res.maxPage,
        )
        ..topicStates.update(_udpateTopicState(res.topics)),
    );
  }
}

class LoadNextPageAction extends CategoryBaseAction {
  final int categoryId;
  final bool isSubcategory;

  LoadNextPageAction({
    this.categoryId,
    this.isSubcategory,
  })  : assert(categoryId != null),
        assert(isSubcategory != null);

  @override
  Future<AppState> reduce() async {
    assert(categoryState.initialized);
    assert(!categoryState.hasRechedMax);

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
        ..topicStates.update(_udpateTopicState(res.topics)),
    );
  }
}

_udpateTopicState(List<Topic> topics) {
  return (MapBuilder<int, TopicState> b) {
    for (Topic topic in topics) {
      b.updateValue(
        topic.id,
        (topicState) => topicState.rebuild((b) => b.topic = topic),
        ifAbsent: () => TopicState((b) => b.topic = topic),
      );
    }
  };
}
