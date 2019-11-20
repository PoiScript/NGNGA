import 'dart:async';

import 'package:async_redux/async_redux.dart';

import 'package:ngnga/utils/requests.dart';

import 'is_loading.dart';
import '../state.dart';

StreamSubscription streamSub;
int subscribedTopic;

class StartListeningNewReplyAction extends ReduxAction<AppState> {
  final int topicId;

  StartListeningNewReplyAction(this.topicId);

  @override
  Future<AppState> reduce() async {
    if (subscribedTopic != topicId) {
      if (streamSub != null) {
        await streamSub.cancel();
      }

      print("Start listening");

      streamSub = Stream.periodic(const Duration(seconds: 20))
          .listen((_) => dispatch(_NewReplyAction(topicId)));
      subscribedTopic = topicId;
    }
    return null;
  }
}

class _NewReplyAction extends ReduxAction<AppState> {
  final int topicId;

  _NewReplyAction(this.topicId);

  @override
  Future<AppState> reduce() async {
    final lastPage = state.topics[topicId].posts.last.index ~/ 20;
    final maxPage = state.topics[topicId].topic.postsCount ~/ 20;

    if (lastPage == maxPage) {
      await dispatchFuture(FetchNextPostsAction(topicId));
    }

    return null;
  }
}

class CancelListeningNewReplyAction extends ReduxAction<AppState> {
  @override
  Future<AppState> reduce() async {
    subscribedTopic = null;
    if (streamSub != null) {
      await streamSub.cancel();
      streamSub = null;
    }

    print("Cancel listening");

    return null;
  }
}

class FetchPreviousPostsAction extends ReduxAction<AppState> {
  final int topicId;

  FetchPreviousPostsAction(this.topicId) : assert(topicId != null);

  @override
  Future<AppState> reduce() async {
    final firstPage = state.topics[topicId].posts.first.index ~/ 20;

    if (firstPage == 0) {
      final response = await fetchTopicPosts(
        client: state.client,
        topicId: topicId,
        page: 0,
        cookies: state.cookies,
      );

      return state.copy(
        users: state.users..addEntries(response.users),
        topics: state.topics
          ..update(
            topicId,
            (topicState) => topicState.copy(
              topic: response.topic,
              posts: List.of(response.posts)
                ..addAll(
                  topicState.posts
                    ..removeWhere((post) => post.index ~/ 20 == 0),
                ),
            ),
          ),
      );
    } else {
      final response = await fetchTopicPosts(
        client: state.client,
        topicId: topicId,
        page: firstPage - 1,
        cookies: state.cookies,
      );

      return state.copy(
        users: state.users..addEntries(response.users),
        topics: state.topics
          ..update(
            topicId,
            (topicState) => topicState.copy(
              topic: response.topic,
              posts: List.of(response.posts)..addAll(topicState.posts),
            ),
          ),
      );
    }
  }

  void before() => dispatch(IsLoadingAction(true));

  void after() => dispatch(IsLoadingAction(false));
}

class FetchNextPostsAction extends ReduxAction<AppState> {
  final int topicId;

  FetchNextPostsAction(this.topicId) : assert(topicId != null);

  @override
  Future<AppState> reduce() async {
    final lastPage = state.topics[topicId].posts.last.index ~/ 20;

    if (lastPage < state.topics[topicId].topic.postsCount ~/ 20) {
      final response = await fetchTopicPosts(
        client: state.client,
        topicId: topicId,
        page: lastPage + 1,
        cookies: state.cookies,
      );

      return state.copy(
        lastUpdated: DateTime.now(),
        users: state.users..addEntries(response.users),
        topics: state.topics
          ..update(
            topicId,
            (topicState) => topicState.copy(
              topic: response.topic,
              posts: topicState.posts..addAll(response.posts),
            ),
          ),
      );
    } else {
      final response = await fetchTopicPosts(
        client: state.client,
        topicId: topicId,
        page: lastPage,
        cookies: state.cookies,
      );

      final firstIndex = response.posts.first.index;

      return state.copy(
        lastUpdated: DateTime.now(),
        users: state.users..addEntries(response.users),
        topics: state.topics
          ..update(
            topicId,
            (topicState) => topicState.copy(
              topic: response.topic,
              posts: topicState.posts
                ..removeWhere((post) => post.index >= firstIndex)
                ..addAll(response.posts),
            ),
          ),
      );
    }
  }

  void before() => dispatch(IsLoadingAction(true));

  void after() => dispatch(IsLoadingAction(false));
}

class FetchPostsAction extends ReduxAction<AppState> {
  final int topicId;
  final int pageIndex;

  FetchPostsAction(this.topicId, this.pageIndex)
      : assert(topicId != null && pageIndex != null && pageIndex >= 0);

  @override
  Future<AppState> reduce() async {
    final response = await fetchTopicPosts(
      client: state.client,
      topicId: topicId,
      page: pageIndex,
      cookies: state.cookies,
    );

    return state.copy(
      lastUpdated: DateTime.now(),
      users: state.users..addEntries(response.users),
      topics: state.topics
        ..update(
          topicId,
          (topicState) => topicState.copy(
            topic: response.topic,
            posts: List.from(response.posts),
          ),
          ifAbsent: () => TopicState(
            topic: response.topic,
            posts: List.from(response.posts),
          ),
        ),
    );
  }

  void before() => dispatch(IsLoadingAction(true));

  void after() => dispatch(IsLoadingAction(false));
}
