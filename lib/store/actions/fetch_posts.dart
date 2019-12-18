import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';

import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/response.dart';
import 'package:ngnga/store/state.dart';
import 'package:ngnga/store/topic.dart';

import 'fetch_reply.dart';

abstract class FetchPostsBaseAction extends ReduxAction<AppState> {
  Future<FetchTopicPostsResponse> fetch({
    @required int topicId,
    @required int page,
  }) async {
    final res = await state.repository.fetchTopicPosts(
      topicId: topicId,
      page: page,
    );

    for (int i = 0; i < res.posts.length; i++) {
      PostItem post = res.posts[i];
      if (post is Comment) {
        int index = res.comments.indexWhere((c) => c.id == post.id);
        if (index != -1) {
          res.posts[i] = post.addPost(res.comments[index]);
        } else {
          if (!state.posts.containsKey(post.id)) {
            await dispatchFuture(FetchReplyAction(
              topicId: topicId,
              postId: post.commentTo,
            ));
          }
          res.posts[i] = post.addPost(state.posts[post.id].inner);
        }
      } else if (post is TopicPost) {
        for (int postId in post.topReplyIds) {
          if (res.posts.indexWhere((p) => p.id == postId) == -1 &&
              res.comments.indexWhere((p) => p.id == postId) == -1 &&
              !state.posts.containsKey(postId)) {
            await dispatchFuture(FetchReplyAction(
              topicId: topicId,
              postId: postId,
            ));
          }
        }
      }
    }

    return res;
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
    final res = await fetch(topicId: topicId, page: pageIndex);

    return state.rebuild(
      (b) => b
        ..topicStates[topicId] = TopicState(
          (b) => b
            ..initialized = true
            ..topic = res.topic
            ..firstPage = pageIndex
            ..lastPage = pageIndex
            ..maxPage = res.maxPage
            ..postIds = SetBuilder(res.posts.map((p) => p.id))
            ..isFavorited = state.favoriteState.topicIds.contains(topicId),
        )
        ..topics[topicId] = res.topic
        ..users.addAll(res.users)
        ..posts.addEntries(res.posts.map((p) => MapEntry(p.id, p)))
        ..posts.addEntries(res.comments.map((p) => MapEntry(p.id, p))),
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

    final res = await fetch(topicId: topicId, page: topicState.lastPage);

    return state.rebuild(
      (b) => b
        ..topicStates[topicId] = topicState.rebuild(
          (b) => b
            ..maxPage = res.maxPage
            ..postIds.addAll(res.posts.map((p) => p.id)),
        )
        ..topics[topicId] = res.topic
        ..users.addAll(res.users)
        ..posts.addEntries(res.posts.map((p) => MapEntry(p.id, p)))
        ..posts.addEntries(res.comments.map((p) => MapEntry(p.id, p))),
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

    final res = await fetch(topicId: topicId, page: topicState.firstPage - 1);

    return state.rebuild(
      (b) => b
        ..topicStates[topicId] = topicState.rebuild(
          (b) => b
            ..maxPage = res.maxPage
            ..firstPage = topicState.firstPage - 1
            ..postIds = (SetBuilder(res.posts.map((p) => p.id))
              ..addAll(topicState.postIds)),
        )
        ..topics[topicId] = res.topic
        ..users.addAll(res.users)
        ..posts.addEntries(res.posts.map((p) => MapEntry(p.id, p)))
        ..posts.addEntries(res.comments.map((p) => MapEntry(p.id, p))),
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

    final res = await fetch(topicId: topicId, page: topicState.lastPage + 1);

    return state.rebuild(
      (b) => b
        ..topicStates[topicId] = topicState.rebuild(
          (b) => b
            ..lastPage = topicState.lastPage + 1
            ..maxPage = res.maxPage
            ..postIds.addAll(res.posts.map((p) => p.id)),
        )
        ..topics[topicId] = res.topic
        ..users.addAll(res.users)
        ..posts.addEntries(res.posts.map((p) => MapEntry(p.id, p)))
        ..posts.addEntries(res.comments.map((p) => MapEntry(p.id, p))),
    );
  }
}
