import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import 'package:ngnga/store/state.dart';
import 'package:ngnga/utils/requests.dart';

class DownvotePostAction extends ReduxAction<AppState> {
  final int topicId;
  final int postId;
  final int postIndex;

  DownvotePostAction({
    @required this.topicId,
    @required this.postId,
    @required this.postIndex,
  });

  @override
  Future<AppState> reduce() async {
    final res = await votePost(
      value: -1,
      topicId: topicId,
      postId: postId,
      cookies: state.cookies,
    );

    print("res.value ${res.value}");

    return state.copy(
      topics: state.topics
        ..update(
          topicId,
          (topicState) => topicState.copy(
            posts: List.from(topicState.posts.getRange(0, postIndex))
              ..add(topicState.posts[postIndex].vote(res.value))
              ..addAll(
                topicState.posts
                    .getRange(postIndex + 1, topicState.posts.length),
              ),
          ),
        ),
    );
  }
}
