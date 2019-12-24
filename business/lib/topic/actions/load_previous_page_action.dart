import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';

import '../../app_state.dart';
import 'topic_base_action.dart';

class LoadPreviousPageAction extends TopicBaseAction {
  final int topicId;

  LoadPreviousPageAction({
    @required this.topicId,
  }) : assert(topicId != null);

  @override
  Future<AppState> reduce() async {
    assert(topicState.initialized);
    assert(!topicState.hasRechedMin);

    final res = await fetchPosts(
      topicId: topicId,
      page: topicState.firstPage - 1,
    );

    return state.rebuild(
      (b) => b
        ..topicStates[topicId] = topicState.rebuild(
          (b) => b
            ..topic = res.topic.toBuilder()
            ..maxPage = res.maxPage
            ..firstPage = topicState.firstPage - 1
            ..postIds = (SetBuilder(res.postIds)..addAll(topicState.postIds)),
        )
        ..users.addAll(res.users)
        ..posts.addAll(res.posts),
    );
  }
}
