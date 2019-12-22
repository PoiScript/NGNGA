import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart' hide Category;

import '../../app_state.dart';
import '../../models/category.dart';
import '../../models/post.dart';
import '../../topic/models/topic_state.dart';
import '../models/category_state.dart';
import 'category_base_action.dart';

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

    final res0 = await fetchCategoryTopics(
      categoryId: categoryId,
      isSubcategory: isSubcategory,
      pageIndex: pageIndex,
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
            ..topicStates.update(udpateTopicState(res0.topics)),
        );
      } else {
        Category category = Category((b) => b
          ..id = categoryId
          ..title = res0.topics.first.title
          ..isSubcategory = isSubcategory);

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
                ..category = category.toBuilder()
                ..isPinned = state.pinned.contains(category),
            )
            ..topicStates.update(udpateTopicState(res0.topics)),
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
            ..topicStates.update(udpateTopicState(res0.topics)),
        );
      } else {
        final res1 = await fetchTopicPosts(
          topicId: res0.toppedTopicId,
          pageIndex: 0,
        );

        Category category = Category((b) => b
          ..id = categoryId
          ..title = res1.forumName
          ..isSubcategory = isSubcategory);

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
                ..category = category.toBuilder()
                ..toppedTopicId = res0.toppedTopicId
                ..isPinned = state.pinned.contains(category),
            )
            ..topicStates.update(udpateTopicState(res0.topics))
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
