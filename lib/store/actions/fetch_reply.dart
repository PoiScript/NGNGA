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
    if (state.posts.containsKey(postId)) {
      return state.copy(
        fetchReplyEvt: Event(Option(state.posts[postId])),
      );
    }

    final res = await fetchReply(
      client: state.client,
      topicId: topicId,
      postId: postId,
      cookie: state.cookie,
      baseUrl: state.settings.baseUrl,
    );

    return state.copy(
      fetchReplyEvt: Event(Option(res.post)),
      users: state.users
        ..addEntries(res.users.map((user) => MapEntry(user.id, user))),
    );
  }
}
