import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';

import '../../app_state.dart';
import 'topic_base_action.dart';

class RefreshFirstPageAction extends TopicBaseAction {
  final int topicId;

  RefreshFirstPageAction({
    @required this.topicId,
  }) : assert(topicId != null);

  @override
  Future<AppState> reduce() async {
    assert(topicState.initialized);
    assert(topicState.firstPage == 0);

    final res = await fetchPosts(
      topicId: topicId,
      page: 0,
    );

    return state.rebuild(
      (b) => b
        ..topicStates[topicId] = topicState.rebuild(
          (b) => b
            ..topic = res.topic.toBuilder()
            ..lastPage = 0
            ..maxPage = res.maxPage
            ..postIds = SetBuilder(res.postIds),
        )
        ..users.addAll(res.users)
        ..posts.addAll(res.posts),
    );
  }
}
