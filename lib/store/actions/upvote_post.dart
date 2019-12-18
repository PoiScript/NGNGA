import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import 'package:ngnga/store/state.dart';
import 'package:ngnga/store/topic.dart';

class UpvotePostAction extends ReduxAction<AppState> {
  final int topicId;
  final int postId;

  UpvotePostAction({
    @required this.topicId,
    @required this.postId,
  });

  @override
  Future<AppState> reduce() async {
    final res = await state.repository.votePost(
      value: 1,
      topicId: topicId,
      postId: postId,
    );

    return state.rebuild(
      (b) => b.topicStates.updateValue(
        topicId,
        (topicState) => topicState.rebuild(
          (b) => b.postVotedEvt =
              Event(PostVoted(postId: postId, delta: res.value)),
        ),
      ),
    );
  }
}
