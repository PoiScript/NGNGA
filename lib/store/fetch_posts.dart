import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:async_redux/async_redux.dart';
import 'package:http/http.dart';

import '../models/post.dart';
import '../models/topic.dart';
import '../models/user.dart';
import './is_loading.dart';
import './state.dart';

class _FetchTopicResponse {
  final Topic topic;
  final Iterable<Post> posts;
  final Iterable<MapEntry<int, User>> users;

  _FetchTopicResponse({this.topic, this.posts, this.users});

  factory _FetchTopicResponse.fromJson(Map<String, dynamic> json) {
    return _FetchTopicResponse(
      topic: Topic.fromJson(json["data"]["__T"]),
      posts:
          List.from(json["data"]["__R"]).map((value) => Post.fromJson(value)),
      users: Map.from(json["data"]["__U"])
          .values
          .map((value) => User.fromJson(value))
          .map((user) => MapEntry(user.id, user)),
    );
  }
}

Future<_FetchTopicResponse> _fetchTopic(
  int topicId,
  int page,
  Map<String, String> cookies,
) async {
  final uri = Uri.https("nga.178.com", "read.php", {
    "tid": topicId.toString(),
    "page": (page + 1).toString(),
    "__output": "11",
  });

  print(uri);

  final res = await get(uri, headers: {
    "cookie": cookies.entries.map((e) => "${e.key}=${e.value}").join(";")
  });

  final json = jsonDecode(res.body);

  return _FetchTopicResponse.fromJson(json);
}

class FetchNextPostsAction extends ReduxAction<AppState> {
  final int topicId;

  FetchNextPostsAction(this.topicId) : assert(topicId != null);

  @override
  Future<AppState> reduce() async {
    var lastPage = state.topics[topicId].posts.last.index ~/ 20;

    assert(lastPage < state.topics[topicId].topic.postsCount ~/ 20);

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
  }

  void before() => dispatch(IsLoadingAction(true));

  void after() => dispatch(IsLoadingAction(false));
}

class FetchPostsAction extends ReduxAction<AppState> {
  final int topicId;

  FetchPostsAction(this.topicId) : assert(topicId != null);

  @override
  Future<AppState> reduce() async {
    var response = await _fetchTopic(topicId, 0, state.cookies);

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