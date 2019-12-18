import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:ngnga/models/post.dart';

import 'package:ngnga/store/state.dart';

class DownvotePostAction extends ReduxAction<AppState> {
  final int topicId;
  final int postId;

  DownvotePostAction({
    @required this.topicId,
    @required this.postId,
  });

  @override
  Future<AppState> reduce() async {
    final res = await state.repository.votePost(
      value: -1,
      topicId: topicId,
      postId: postId,
    );

    return state.rebuild(
      (b) => b
        ..posts.updateValue(postId, (item) {
          if (item is TopicPost) {
            return TopicPost(
              item.post.copy(vote: item.post.vote + res.value),
              item.topReplyIds,
            );
          }

          if (item is Comment) {
            return item.addPost(item.post.copy(
              vote: item.post.vote + res.value,
            ));
          }

          if (item is Post) {
            return item.copy(vote: item.vote + res.value);
          }

          return item;
        })
        ..topicStates.updateValue(
          topicId,
          (topicState) => topicState.rebuild(
            (b) => b.snackBarEvt = Event(res.message),
          ),
        ),
    );
  }
}
