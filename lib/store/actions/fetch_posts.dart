import 'dart:async';

import 'package:async_redux/async_redux.dart';

import 'package:ngnga/utils/requests.dart';

import '../state.dart';

class FetchPreviousPostsAction extends ReduxAction<AppState> {
  final int topicId;

  FetchPreviousPostsAction(this.topicId) : assert(topicId != null);

  @override
  Future<AppState> reduce() async {
    int firstPage = state.topicStates[topicId].firstPage;

    if (firstPage == 0) {
      final res = await fetchTopicPosts(
        client: state.client,
        topicId: topicId,
        page: 0,
        cookie: state.cookie,
        baseUrl: state.settings.baseUrl,
      );

      return state.copy(
        users: state.users
          ..addEntries(res.users.map((user) => MapEntry(user.id, user))),
        topicStates: state.topicStates
          ..update(
            topicId,
            (topicState) => topicState.copy(
              firstPage: 0,
              lastPage: 0,
              maxPage: res.maxPage,
              postIds: List.of(res.posts.map((post) => post.id)),
            ),
          ),
        posts: state.posts
          ..addEntries(res.posts.map((post) => MapEntry(post.id, post))),
      );
    } else {
      final res = await fetchTopicPosts(
        client: state.client,
        topicId: topicId,
        page: firstPage - 1,
        cookie: state.cookie,
        baseUrl: state.settings.baseUrl,
      );

      return state.copy(
        users: state.users
          ..addEntries(res.users.map((user) => MapEntry(user.id, user))),
        topicStates: state.topicStates
          ..update(
            topicId,
            (topicState) => topicState.copy(
              maxPage: res.maxPage,
              firstPage: firstPage - 1,
              postIds: res.posts.map((post) => post.id).toList()
                ..addAll(topicState.postIds),
            ),
          ),
        posts: state.posts
          ..addEntries(res.posts.map((post) => MapEntry(post.id, post))),
      );
    }
  }
}

class FetchNextPostsAction extends ReduxAction<AppState> {
  final int topicId;

  FetchNextPostsAction(this.topicId) : assert(topicId != null);

  @override
  Future<AppState> reduce() async {
    int lastPage = state.topicStates[topicId].lastPage;
    int maxPage = state.topicStates[topicId].maxPage;

    if (lastPage < maxPage) {
      final res = await fetchTopicPosts(
        client: state.client,
        topicId: topicId,
        page: lastPage + 1,
        cookie: state.cookie,
        baseUrl: state.settings.baseUrl,
      );

      return state.copy(
        lastUpdated: DateTime.now(),
        users: state.users
          ..addEntries(res.users.map((user) => MapEntry(user.id, user))),
        topicStates: state.topicStates
          ..update(
            topicId,
            (topicState) => topicState.copy(
              lastPage: lastPage + 1,
              maxPage: res.maxPage,
              postIds: topicState.postIds..addAll(res.posts.map((p) => p.id)),
            ),
          ),
        posts: state.posts
          ..addEntries(res.posts.map((post) => MapEntry(post.id, post))),
      );
    } else {
      final res = await fetchTopicPosts(
        client: state.client,
        topicId: topicId,
        page: lastPage,
        cookie: state.cookie,
        baseUrl: state.settings.baseUrl,
      );

      List<int> postIds = res.posts.map((p) => p.id).toList();

      return state.copy(
        lastUpdated: DateTime.now(),
        users: state.users
          ..addEntries(res.users.map((user) => MapEntry(user.id, user))),
        topicStates: state.topicStates
          ..update(
            topicId,
            (topicState) => topicState.copy(
              maxPage: res.maxPage,
              postIds: topicState.postIds
                ..removeWhere((id) => postIds.contains(id))
                ..addAll(postIds),
            ),
          ),
        posts: state.posts
          ..addEntries(res.posts.map((post) => MapEntry(post.id, post))),
      );
    }
  }
}

class FetchPostsAction extends ReduxAction<AppState> {
  final int topicId;
  final int pageIndex;

  FetchPostsAction(this.topicId, this.pageIndex)
      : assert(topicId != null && pageIndex != null && pageIndex >= 0);

  @override
  Future<AppState> reduce() async {
    final res = await fetchTopicPosts(
      client: state.client,
      topicId: topicId,
      page: pageIndex,
      cookie: state.cookie,
      baseUrl: state.settings.baseUrl,
    );

    return state.copy(
      lastUpdated: DateTime.now(),
      users: state.users
        ..addEntries(res.users.map((user) => MapEntry(user.id, user))),
      topicStates: state.topicStates
        ..update(
          topicId,
          (topicState) => topicState.copy(
            firstPage: pageIndex,
            lastPage: pageIndex,
            maxPage: res.maxPage,
            postIds: res.posts.map((posts) => posts.id).toList(),
          ),
        ),
      posts: state.posts
        ..addEntries(res.posts.map((post) => MapEntry(post.id, post))),
    );
  }
}
