import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import 'package:ngnga/models/post.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/utils/requests.dart';

class DownvotePostAction extends ReduxAction<AppState> {
  final int topicId;
  final int postId;

  DownvotePostAction({
    @required this.topicId,
    @required this.postId,
  });

  @override
  Future<AppState> reduce() async {
    final res = await votePost(
      client: state.client,
      value: -1,
      topicId: topicId,
      postId: postId,
      baseUrl: state.settings.baseUrl,
    );

    return state.copy(
      topicSnackBarEvt: Event(res.message),
      posts: state.posts
        ..update(
          postId,
          (item) {
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
              return item.copy(
                vote: item.vote + res.value,
              );
            }

            return null;
          },
        ),
    );
  }
}
