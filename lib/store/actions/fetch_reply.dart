import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

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
    if (postId == 0 && state.posts.containsKey(2 ^ 32 - topicId)) {
      return state.copy(
        fetchReplyEvt: Event(Option(state.posts[2 ^ 32 - topicId])),
      );
    }

    if (state.posts.containsKey(postId)) {
      return state.copy(
        fetchReplyEvt: Event(Option(state.posts[postId].inner)),
      );
    }

    final res = await fetchReply(
      client: state.client,
      topicId: topicId,
      postId: postId,
      cookie: state.userState.cookie,
      baseUrl: state.settings.baseUrl,
    );

    if (res.posts.isEmpty) {
      return state.copy(
        topics: state.topics..update(topicId, (_) => res.topic),
        fetchReplyEvt: Event(Option(null)),
        users: state.users..addAll(res.users),
      );
    } else {
      return state.copy(
        topics: state.topics..update(topicId, (_) => res.topic),
        fetchReplyEvt: Event(Option(res.posts.first.inner)),
        users: state.users..addAll(res.users),
        posts: state.posts
          ..addEntries(res.posts.map((post) => MapEntry(post.id, post)))
          ..addEntries(res.comments.map((post) => MapEntry(post.id, post))),
      );
    }
  }
}
