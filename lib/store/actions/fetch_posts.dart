import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import 'package:ngnga/models/post.dart';
import 'package:ngnga/utils/requests.dart';

import '../state.dart';
import 'fetch_reply.dart';

abstract class FetchPostsBaseAction extends ReduxAction<AppState> {
  Future<FetchTopicPostsResponse> fetch({
    @required int topicId,
    @required int page,
  }) async {
    final res = await fetchTopicPosts(
      client: state.client,
      topicId: topicId,
      page: page,
      cookie: state.userState.cookie,
      baseUrl: state.settings.baseUrl,
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
          res.posts[i] = post.addPost(state.posts[post.id]);
        }
      }
    }

    return res;
  }
}

class FetchPreviousPostsAction extends FetchPostsBaseAction {
  final int topicId;

  FetchPreviousPostsAction(this.topicId) : assert(topicId != null);

  @override
  Future<AppState> reduce() async {
    int firstPage = state.topicStates[topicId].firstPage;

    assert(firstPage != 0);

    final res = await fetch(topicId: topicId, page: firstPage - 1);

    return state.copy(
      topics: state.topics..[topicId] = res.topic,
      users: state.users..addAll(res.users),
      topicStates: state.topicStates
        ..update(
          topicId,
          (topicState) => topicState.copy(
            maxPage: res.maxPage,
            firstPage: firstPage - 1,
            postIds: List.of(res.posts.map((post) => post.id))
              ..addAll(topicState.postIds),
          ),
        ),
      posts: state.posts
        ..addEntries(res.posts.map((post) => MapEntry(post.id, post)))
        ..addEntries(res.comments.map((post) => MapEntry(post.id, post))),
    );
  }
}

class FetchNextPostsAction extends FetchPostsBaseAction {
  final int topicId;

  FetchNextPostsAction(this.topicId) : assert(topicId != null);

  @override
  Future<AppState> reduce() async {
    int lastPage = state.topicStates[topicId].lastPage;
    int maxPage = state.topicStates[topicId].maxPage;

    if (lastPage < maxPage) {
      final res = await fetch(topicId: topicId, page: lastPage + 1);

      return state.copy(
        topics: state.topics..[topicId] = res.topic,
        users: state.users..addAll(res.users),
        topicStates: state.topicStates
          ..update(
            topicId,
            (topicState) => topicState.copy(
              lastPage: lastPage + 1,
              maxPage: res.maxPage,
              postIds: topicState.postIds
                ..addAll(res.posts.map((post) => post.id)),
            ),
          ),
        posts: state.posts
          ..addEntries(res.posts.map((post) => MapEntry(post.id, post)))
          ..addEntries(res.comments.map((post) => MapEntry(post.id, post))),
      );
    } else {
      final res = await fetch(topicId: topicId, page: lastPage);

      return state.copy(
        topics: state.topics..[topicId] = res.topic,
        users: state.users..addAll(res.users),
        topicStates: state.topicStates
          ..update(
            topicId,
            (topicState) => topicState.copy(
              maxPage: res.maxPage,
              postIds: topicState.postIds
                ..addAll(res.posts
                    .map((post) => post.id)
                    .where((id) => !topicState.postIds.contains(id))),
            ),
          ),
        posts: state.posts
          ..addEntries(res.posts.map((post) => MapEntry(post.id, post)))
          ..addEntries(res.comments.map((post) => MapEntry(post.id, post))),
      );
    }
  }
}

class FetchPostsAction extends FetchPostsBaseAction {
  final int topicId;
  final int pageIndex;

  FetchPostsAction({
    @required this.topicId,
    @required this.pageIndex,
  })  : assert(topicId != null),
        assert(pageIndex >= 0);

  @override
  Future<AppState> reduce() async {
    final res = await fetch(topicId: topicId, page: pageIndex);

    return state.copy(
      topics: state.topics..update(topicId, (_) => res.topic),
      users: state.users..addAll(res.users),
      topicStates: state.topicStates
        ..update(
          topicId,
          (topicState) => topicState.copy(
            firstPage: pageIndex,
            lastPage: pageIndex,
            maxPage: res.maxPage,
            postIds: List.of(res.posts.map((post) => post.id)),
          ),
        ),
      posts: state.posts
        ..addEntries(res.posts.map((post) => MapEntry(post.id, post)))
        ..addEntries(res.comments.map((post) => MapEntry(post.id, post))),
    );
  }
}
