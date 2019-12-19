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

class JumpToPageAction extends TopicBaseAction {
  final int topicId;
  final int pageIndex;

  JumpToPageAction({
    @required this.topicId,
    @required this.pageIndex,
  });

  @override
  Future<AppState> reduce() async {
    assert(topicState == null || !topicState.initialized);

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
        ..users.addAll(res.users)
        ..posts.addAll(res.posts),
    );
  }

  void before() => dispatch(_SetUninitialized(topicId));
}

class _SetUninitialized extends ReduxAction<AppState> {
  final int topicId;

  _SetUninitialized(this.topicId);

  @override
  FutureOr<AppState> reduce() {
    if (state.topicStates.containsKey(topicId)) {
      return state.rebuild(
        (b) => b.topicStates.updateValue(
          topicId,
          (topicState) => topicState.rebuild((b) => b.initialized = false),
        ),
      );
    } else {
      return null;
    }
  }
}

class RefreshFirstPageAction extends TopicBaseAction {
  final int topicId;

  RefreshFirstPageAction({
    @required this.topicId,
  }) : assert(topicId != null);

  @override
  Future<AppState> reduce() async {
    assert(topicState.initialized);
    assert(topicState.firstPage == 0);

    final res = await fetchPosts(
      topicId: topicId,
      page: 0,
    );

    return state.rebuild(
      (b) => b
        ..topicStates[topicId] = topicState.rebuild(
          (b) => b
            ..topic = res.topic
            ..lastPage = 0
            ..maxPage = res.maxPage
            ..postIds = SetBuilder(res.postIds),
        )
        ..users.addAll(res.users)
        ..posts.addAll(res.posts),
    );
  }
}

class RefreshLastPageAction extends TopicBaseAction {
  final int topicId;

  RefreshLastPageAction(this.topicId) : assert(topicId != null);

  @override
  Future<AppState> reduce() async {
    assert(topicState.initialized);
    assert(topicState.hasRechedMax);

    final res = await fetchPosts(topicId: topicId, page: topicState.lastPage);

    return state.rebuild(
      (b) => b
        ..topicStates[topicId] = topicState.rebuild(
          (b) => b
            ..topic = res.topic
            ..maxPage = res.maxPage
            ..postIds.addAll(res.postIds),
        )
        ..users.addAll(res.users)
        ..posts.addAll(res.posts),
    );
  }
}

class LoadPreviousPageAction extends TopicBaseAction {
  final int topicId;

  LoadPreviousPageAction(this.topicId) : assert(topicId != null);

  @override
  Future<AppState> reduce() async {
    assert(topicState.initialized);
    assert(!topicState.hasRechedMin);

    final res = await fetchPosts(
      topicId: topicId,
      page: topicState.firstPage - 1,
    );

    return state.rebuild(
      (b) => b
        ..topicStates[topicId] = topicState.rebuild(
          (b) => b
            ..topic = res.topic
            ..maxPage = res.maxPage
            ..firstPage = topicState.firstPage - 1
            ..postIds = (SetBuilder(res.postIds)..addAll(topicState.postIds)),
        )
        ..users.addAll(res.users)
        ..posts.addAll(res.posts),
    );
  }
}

class LoadNextPageAction extends TopicBaseAction {
  final int topicId;

  LoadNextPageAction(this.topicId) : assert(topicId != null);

  @override
  Future<AppState> reduce() async {
    assert(topicState.initialized);
    assert(!topicState.hasRechedMax);

    final res = await fetchPosts(
      topicId: topicId,
      page: topicState.lastPage + 1,
    );

    return state.rebuild(
      (b) => b
        ..topicStates[topicId] = topicState.rebuild(
          (b) => b
            ..topic = res.topic
            ..maxPage = res.maxPage
            ..lastPage = topicState.lastPage + 1
            ..postIds.addAll(res.postIds),
        )
        ..users.addAll(res.users)
        ..posts.addAll(res.posts),
    );
  }
}

class FetchReplyAction extends TopicBaseAction {
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
      (b) => b..users.addAll(res.users)..posts.addAll(res.posts),
    );
  }
}

class ClearTopicAction extends TopicBaseAction {
  final int topicId;

  ClearTopicAction({this.topicId}) : assert(topicId != null);

  @override
  Future<AppState> reduce() async {
    return state.rebuild(
      (b) => b
        ..posts.removeWhere((id, _) => topicState.postIds.contains(id))
        ..topicStates.updateValue(
          topicId,
          (topicState) => topicState.rebuild(
            (b) => b
              ..initialized = false
              ..postIds.clear(),
          ),
          ifAbsent: () => TopicState(),
        ),
    );
  }
}
