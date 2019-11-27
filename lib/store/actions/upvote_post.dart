import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import 'package:ngnga/store/state.dart';
import 'package:ngnga/utils/requests.dart';

class UpvotePostAction extends ReduxAction<AppState> {
  final int topicId;
  final int postId;

  UpvotePostAction({
    @required this.topicId,
    @required this.postId,
  });

  @override
  Future<AppState> reduce() async {
    final res = await votePost(
      client: state.client,
      value: 1,
      topicId: topicId,
      postId: postId,
      cookie: state.settings.cookie,
      baseUrl: state.settings.baseUrl,
    );

    return state.copy(
      topicSnackBarEvt: Event(res.message),
      posts: state.posts
        ..update(
          postId,
          (post) => post.vote(res.value),
        ),
    );
  }
}
