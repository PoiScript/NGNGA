import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/response.dart';
import 'package:ngnga/store/favorite.dart';
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

    FavoriteState favoriteState = state.favoriteState;

    bool isFavorited = favoriteState is FavoriteLoaded
        ? favoriteState.topicIds.contains(topicId)
        : false;

    return state.copy(
      topicStates: state.topicStates
        ..[topicId] = TopicLoaded(
          topic: res.topic,
          firstPage: pageIndex,
          lastPage: pageIndex,
          maxPage: res.maxPage,
          postIds: res.posts.map((p) => p.id).toList(),
          postVotedEvt: Event.spent(),
          isFavorited: isFavorited,
        ),
      topics: state.topics..[topicId] = res.topic,
      users: state.users..addAll(res.users),
      posts: state.posts
        ..addEntries(res.posts.map((post) => MapEntry(post.id, post)))
        ..addEntries(res.comments.map((post) => MapEntry(post.id, post))),
    );
  }
}

class RefreshLastPageAction extends FetchPostsBaseAction {
  final int topicId;

  RefreshLastPageAction(this.topicId) : assert(topicId != null);

  @override
  Future<AppState> reduce() async {
    TopicState topicState = state.topicStates[topicId];

    if (topicState is TopicLoaded) {
      assert(topicState.hasRechedMax);

      final res = await fetch(topicId: topicId, page: topicState.lastPage);

      return state.copy(
        topicStates: state.topicStates
          ..[topicId] = topicState.copyWith(
            maxPage: res.maxPage,
            postIds: topicState.postIds
              ..addAll(
                res.posts
                    .map((p) => p.id)
                    .where((id) => !topicState.postIds.contains(id)),
              ),
          ),
        topics: state.topics..[topicId] = res.topic,
        users: state.users..addAll(res.users),
        posts: state.posts
          ..addEntries(res.posts.map((post) => MapEntry(post.id, post)))
          ..addEntries(res.comments.map((post) => MapEntry(post.id, post))),
      );
    }

    return null;
  }
}

class FetchPreviousPostsAction extends FetchPostsBaseAction {
  final int topicId;

  FetchPreviousPostsAction(this.topicId) : assert(topicId != null);

  @override
  Future<AppState> reduce() async {
    TopicState topicState = state.topicStates[topicId];

    if (topicState is TopicLoaded) {
      assert(!topicState.hasRechedMin);

      final res = await fetch(topicId: topicId, page: topicState.firstPage - 1);

      return state.copy(
        topicStates: state.topicStates
          ..[topicId] = topicState.copyWith(
            maxPage: res.maxPage,
            firstPage: topicState.firstPage - 1,
            postIds: List.of(res.posts.map((p) => p.id))
              ..addAll(topicState.postIds),
          ),
        topics: state.topics..[topicId] = res.topic,
        users: state.users..addAll(res.users),
        posts: state.posts
          ..addEntries(res.posts.map((post) => MapEntry(post.id, post)))
          ..addEntries(res.comments.map((post) => MapEntry(post.id, post))),
      );
    }

    return null;
  }
}

class FetchNextPostsAction extends FetchPostsBaseAction {
  final int topicId;

  FetchNextPostsAction(this.topicId) : assert(topicId != null);

  @override
  Future<AppState> reduce() async {
    TopicState topicState = state.topicStates[topicId];

    if (topicState is TopicLoaded) {
      assert(!topicState.hasRechedMax);

      final res = await fetch(topicId: topicId, page: topicState.lastPage + 1);

      return state.copy(
        topicStates: state.topicStates
          ..[topicId] = topicState.copyWith(
            lastPage: topicState.lastPage + 1,
            maxPage: res.maxPage,
            postIds: topicState.postIds..addAll(res.posts.map((p) => p.id)),
          ),
        topics: state.topics..[topicId] = res.topic,
        users: state.users..addAll(res.users),
        posts: state.posts
          ..addEntries(res.posts.map((post) => MapEntry(post.id, post)))
          ..addEntries(res.comments.map((post) => MapEntry(post.id, post))),
      );
    }

    return null;
  }
}
