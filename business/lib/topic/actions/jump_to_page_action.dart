import 'package:async_redux/async_redux.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';

import '../../app_state.dart';
import '../models/topic_state.dart';
import 'topic_base_action.dart';

class JumpToPageAction extends TopicBaseAction {
  final int topicId;
  final int pageIndex;

  JumpToPageAction({
    @required this.topicId,
    @required this.pageIndex,
  });

  @override
  Future<AppState> reduce() async {
    assert(topicState == null || !topicState.initialized);

    final res = await fetchPosts(topicId: topicId, page: pageIndex);

    return state.rebuild(
      (b) => b
        ..topicStates[topicId] = TopicState(
          (b) => b
            ..initialized = true
            ..topic = res.topic.toBuilder()
            ..firstPage = pageIndex
            ..lastPage = pageIndex
            ..maxPage = res.maxPage
            ..postIds = SetBuilder(res.postIds)
            ..isFavorited = state.favoriteState.topicIds.contains(topicId),
        )
        ..users.addAll(res.users)
        ..posts.addAll(res.posts),
    );
  }

  void before() => dispatch(_SetUninitialized(topicId));
}

class _SetUninitialized extends ReduxAction<AppState> {
  final int topicId;

  _SetUninitialized(this.topicId);

  @override
  AppState reduce() {
    if (state.topicStates.containsKey(topicId)) {
      return state.rebuild(
        (b) => b.topicStates.updateValue(
          topicId,
          (topicState) => topicState.rebuild((b) => b.initialized = false),
        ),
      );
    } else {
      return null;
    }
  }
}
