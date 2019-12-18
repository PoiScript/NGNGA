import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';

import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/topic.dart';
import 'package:ngnga/models/user.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/store/topic.dart';

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

abstract class FetchPostsBaseAction extends ReduxAction<AppState> {
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

class RefreshPostsAction extends FetchPostsBaseAction {
  final int topicId;
  final int pageIndex;

  RefreshPostsAction({
    @required this.topicId,
    @required this.pageIndex,
  })  : assert(topicId != null),
        assert(pageIndex >= 0);

  @override
  Future<AppState> reduce() async {
    final res = await fetchPosts(topicId: topicId, page: pageIndex);

    return state.rebuild(
      (b) => b
        ..topicStates[topicId] = TopicState(
          (b) => b
            ..initialized = true
            ..topic = res.topic
            ..firstPage = pageIndex
            ..lastPage = pageIndex
            ..maxPage = res.maxPage
            ..postIds = SetBuilder(res.postIds)
            ..isFavorited = state.favoriteState.topicIds.contains(topicId),
        )
        ..topics[topicId] = res.topic
        ..users.addAll(res.users)
        ..posts.addAll(res.posts),
    );
  }
}

class RefreshLastPageAction extends FetchPostsBaseAction {
  final int topicId;

  RefreshLastPageAction(this.topicId) : assert(topicId != null);

  @override
  Future<AppState> reduce() async {
    TopicState topicState = state.topicStates[topicId];

    assert(topicState.hasRechedMax);

    final res = await fetchPosts(topicId: topicId, page: topicState.lastPage);

    return state.rebuild(
      (b) => b
        ..topicStates[topicId] = topicState.rebuild(
          (b) => b
            ..maxPage = res.maxPage
            ..postIds.addAll(res.postIds),
        )
        ..topics[topicId] = res.topic
        ..users.addAll(res.users)
        ..posts.addAll(res.posts),
    );
  }
}

class FetchPreviousPostsAction extends FetchPostsBaseAction {
  final int topicId;

  FetchPreviousPostsAction(this.topicId) : assert(topicId != null);

  @override
  Future<AppState> reduce() async {
    TopicState topicState = state.topicStates[topicId];

    assert(!topicState.hasRechedMin);

    final res =
        await fetchPosts(topicId: topicId, page: topicState.firstPage - 1);

    return state.rebuild(
      (b) => b
        ..topicStates[topicId] = topicState.rebuild(
          (b) => b
            ..maxPage = res.maxPage
            ..firstPage = topicState.firstPage - 1
            ..postIds = SetBuilder(res.postIds..addAll(topicState.postIds)),
        )
        ..topics[topicId] = res.topic
        ..users.addAll(res.users)
        ..posts.addAll(res.posts),
    );
  }
}

class FetchNextPostsAction extends FetchPostsBaseAction {
  final int topicId;

  FetchNextPostsAction(this.topicId) : assert(topicId != null);

  @override
  Future<AppState> reduce() async {
    TopicState topicState = state.topicStates[topicId];

    assert(!state.topicStates[topicId].hasRechedMax);

    final res =
        await fetchPosts(topicId: topicId, page: topicState.lastPage + 1);

    return state.rebuild(
      (b) => b
        ..topicStates[topicId] = topicState.rebuild(
          (b) => b
            ..lastPage = topicState.lastPage + 1
            ..maxPage = res.maxPage
            ..postIds.addAll(res.postIds),
        )
        ..topics[topicId] = res.topic
        ..users.addAll(res.users)
        ..posts.addAll(res.posts),
    );
  }
}

class FetchReplyAction extends FetchPostsBaseAction {
  final int topicId;
  final int postId;

  FetchReplyAction({
    @required this.topicId,
    @required this.postId,
  }) : assert(topicId != null);

  @override
  Future<AppState> reduce() async {
    final res = await fetchPosts(
      topicId: topicId,
      postId: postId,
    );

    return state.rebuild(
      (b) => b
        ..topics[topicId] = res.topic
        ..users.addAll(res.users)
        ..posts.addAll(res.posts),
    );
  }
}
