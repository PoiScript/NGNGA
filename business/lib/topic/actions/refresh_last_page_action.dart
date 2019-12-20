import 'package:flutter/foundation.dart';

import '../../app_state.dart';
import 'topic_base_action.dart';

class RefreshLastPageAction extends TopicBaseAction {
  final int topicId;

  RefreshLastPageAction({
    @required this.topicId,
  }) : assert(topicId != null);

  @override
  Future<AppState> reduce() async {
    assert(topicState.initialized);
    assert(topicState.hasRechedMax);

    final res = await fetchPosts(topicId: topicId, page: topicState.lastPage);

    return state.rebuild(
      (b) => b
        ..topicStates[topicId] = topicState.rebuild(
          (b) => b
            ..topic = res.topic
            ..maxPage = res.maxPage
            ..postIds.addAll(res.postIds),
        )
        ..users.addAll(res.users)
        ..posts.addAll(res.posts),
    );
  }
}
