import 'package:flutter/foundation.dart';

import '../../app_state.dart';
import 'topic_base_action.dart';

class FetchReplyAction extends TopicBaseAction {
  final int topicId;
  final int postId;

  FetchReplyAction({
    @required this.topicId,
    @required this.postId,
  }) : assert(topicId != null);

  @override
  Future<AppState> reduce() async {
    final res = await fetchPosts(
      topicId: topicId,
      postId: postId,
    );

    return state.rebuild(
      (b) => b..users.addAll(res.users)..posts.addAll(res.posts),
    );
  }
}
