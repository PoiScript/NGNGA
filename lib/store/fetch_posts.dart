import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:async_redux/async_redux.dart';
import 'package:http/http.dart';

import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/topic.dart';
import 'package:ngnga/models/user.dart';

import 'is_loading.dart';
import 'state.dart';

class _FetchTopicResponse {
  final Topic topic;
  final Iterable<Post> posts;
  final List<MapEntry<int, User>> users;

  _FetchTopicResponse({this.topic, this.posts, this.users});

  factory _FetchTopicResponse.fromJson(Map<String, dynamic> json) {
    List<MapEntry<int, User>> users = [];

    for (var entry in Map.from(json["data"]["__U"]).entries) {
      try {
        final userId = int.parse(entry.key);
        final user = User.fromJson(entry.value);
        users.add(MapEntry(userId, user));
      } catch (_) {}
    }

    return _FetchTopicResponse(
      topic: Topic.fromJson(json["data"]["__T"]),
      posts:
          List.from(json["data"]["__R"]).map((value) => Post.fromJson(value)),
      users: users,
    );
  }
}

Future<_FetchTopicResponse> _fetchTopic(
  int topicId,
  int page,
  List<String> cookies,
) async {
  final uri = Uri.https("nga.178.com", "read.php", {
    "tid": topicId.toString(),
    "page": (page + 1).toString(),
    "__output": "11",
  });

  print(uri);

  final res = await get(uri, headers: {"cookie": cookies.join(";")});

  final json = jsonDecode(res.body);

  return _FetchTopicResponse.fromJson(json);
}

class FetchPreviousPostsAction extends ReduxAction<AppState> {
  final int topicId;

  FetchPreviousPostsAction(this.topicId) : assert(topicId != null);

  @override
  Future<AppState> reduce() async {
    var firstPage = state.topics[topicId].posts.first.index ~/ 20;

    if (firstPage == 0) {
      var response = await _fetchTopic(topicId, 0, state.cookies);

      return state.copy(
        users: state.users..addEntries(response.users),
        topics: state.topics
          ..update(
            topicId,
            (topicState) => topicState.copy(
              topic: response.topic,
              posts: ListQueue.of(response.posts)
                ..addAll(
                  topicState.posts
                    ..removeWhere((post) => post.index ~/ 20 == 0),
                ),
            ),
          ),
      );
    } else {
      var response = await _fetchTopic(topicId, firstPage - 1, state.cookies);

      return state.copy(
        users: state.users..addEntries(response.users),
        topics: state.topics
          ..update(
            topicId,
            (topicState) => topicState.copy(
              topic: response.topic,
              posts: ListQueue.of(response.posts)..addAll(topicState.posts),
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
    var lastPage = state.topics[topicId].posts.last.index ~/ 20;

    if (lastPage < state.topics[topicId].topic.postsCount ~/ 20) {
      var response = await _fetchTopic(topicId, lastPage + 1, state.cookies);

      return state.copy(
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
      var response = await _fetchTopic(topicId, lastPage, state.cookies);
      var firstIndex = response.posts.first.index;

      return state.copy(
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
    var response = await _fetchTopic(topicId, pageIndex, state.cookies);

    return state.copy(
      users: state.users..addEntries(response.users),
      topics: state.topics
        ..update(
          topicId,
          (topicState) => topicState.copy(
            topic: response.topic,
            posts: ListQueue.from(response.posts),
          ),
          ifAbsent: () => TopicState(
            topic: response.topic,
            posts: ListQueue.from(response.posts),
          ),
        ),
    );
  }

  void before() => dispatch(IsLoadingAction(true));

  void after() => dispatch(IsLoadingAction(false));
}
