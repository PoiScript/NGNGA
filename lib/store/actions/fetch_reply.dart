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
  })  : assert(topicId != null),
        assert(postId != null);

  @override
  Future<AppState> reduce() async {
    if (state.topics.containsKey(topicId)) {
      final post = state.topics[topicId].posts.where((p) => p.id == postId);
      if (post.isNotEmpty) {
        return state.copy(
          fetchReplyEvt: Event(PostWrapper(post.first)),
        );
      }
    }

    final response = await fetchReply(
      client: state.client,
      topicId: topicId,
      postId: postId,
      cookie: state.cookie,
      baseUrl: state.baseUrl,
    );

    return state.copy(
      fetchReplyEvt: Event(PostWrapper(response.post)),
      users: state.users..addEntries(response.users),
    );
  }
}
