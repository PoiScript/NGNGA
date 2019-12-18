import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import '../state.dart';

class FetchReplyAction extends ReduxAction<AppState> {
  final int topicId;
  final int postId;

  FetchReplyAction({
    @required this.topicId,
    @required this.postId,
  }) : assert(topicId != null);

  @override
  Future<AppState> reduce() async {
    int postId = this.postId == 0 ? 2 ^ 32 - topicId : this.postId;

    final res = await state.repository.fetchReply(
      topicId: topicId,
      postId: postId,
    );

    return state.rebuild(
      (b) => b
        ..topics[topicId] = res.topic
        ..users.addAll(res.users)
        ..posts.addEntries(res.posts.map((post) => MapEntry(post.id, post)))
        ..posts.addEntries(res.comments.map((post) => MapEntry(post.id, post))),
    );
  }
}
