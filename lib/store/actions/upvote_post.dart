import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import 'package:ngnga/store/state.dart';

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
      (b) => b
        ..posts.updateValue(
          postId,
          (post) => post.rebuild((b) => b.vote += res.value),
        )
        ..topicStates.updateValue(
          topicId,
          (topicState) => topicState.rebuild(
            (b) => b.snackBarEvt = Event(res.message),
          ),
        ),
    );
  }
}
