import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import 'package:ngnga/models/post.dart';
import 'package:ngnga/utils/requests.dart';

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

    if (state.posts.containsKey(postId) && state.posts[postId] is! Deleted) {
      return null;
    }

    final res = await fetchReply(
      client: state.client,
      topicId: topicId,
      postId: postId,
      cookie: state.userState.cookie,
      baseUrl: state.settings.baseUrl,
    );

    return state.copy(
      topics: Map.of(state.topics)..update(topicId, (_) => res.topic),
      users: Map.of(state.users)..addAll(res.users),
      posts: Map.of(state.posts)
        ..addEntries(res.posts.map((post) => MapEntry(post.id, post)))
        ..addEntries(res.comments.map((post) => MapEntry(post.id, post))),
    );
  }
}
