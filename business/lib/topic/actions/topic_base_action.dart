import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import 'package:business/models/post.dart';
import 'package:business/models/topic.dart';
import 'package:business/models/user.dart';

import '../../app_state.dart';
import '../models/topic_state.dart';
import 'fetch_reply_action.dart';

class FetchPostsResult {
  final Topic topic;
  final List<int> postIds;
  final Map<int, User> users;
  final Map<int, Post> posts;
  final String forumName;
  final int maxPage;

  FetchPostsResult({
    this.topic,
    this.postIds,
    this.users,
    this.posts,
    this.forumName,
    this.maxPage,
  });
}

abstract class TopicBaseAction extends ReduxAction<AppState> {
  int get topicId;

  TopicState get topicState => state.topicStates[topicId];

  Future<FetchPostsResult> fetchPosts({
    @required int topicId,
    int page,
    int postId,
  }) async {
    assert(postId != null || page != null);

    List<int> postIds = [];
    Map<int, Post> posts = {};

    final res = page != null
        ? await state.repository.fetchTopicPosts(
            topicId: topicId,
            page: page,
          )
        : await state.repository.fetchReply(
            topicId: topicId,
            postId: postId,
          );

    posts.addEntries(res.comments.map(((c) => MapEntry(c.id, c))));

    for (PostItem post in res.posts) {
      if (post is Post) {
        postIds.add(post.id);
        posts[post.id] = post;
        for (int replyId in post.topReplyIds) {
          if (res.posts
                      .indexWhere((p) => p is Post ? p.id == replyId : false) ==
                  -1 &&
              res.comments.indexWhere((p) => p.postId == replyId) == -1 &&
              !state.posts.containsKey(replyId)) {
            await dispatchFuture(FetchReplyAction(
              topicId: topicId,
              postId: replyId,
            ));
          }
        }
      }

      if (post is Comment) {
        postIds.add(post.postId);

        int index = res.comments.indexWhere((c) => c.id == post.postId);
        if (index != -1) {
          posts[post.postId] = (res.comments[index].toBuilder()
                ..commentTo = post.commentTo
                ..index = post.index)
              .build();
        } else {
          if (!state.posts.containsKey(post.postId)) {
            await dispatchFuture(FetchReplyAction(
              topicId: topicId,
              postId: post.commentTo,
            ));
          }

          posts[post.postId] = (state.posts[post.postId].toBuilder()
                ..commentTo = post.commentTo
                ..index = post.index)
              .build();
        }
      }
    }

    return FetchPostsResult(
      topic: res.topic,
      postIds: postIds,
      users: res.users,
      posts: posts,
      forumName: res.forumName,
      maxPage: res.maxPage,
    );
  }
}
