import 'dart:async';
import 'dart:convert';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';

import '../models/post.dart';
import '../models/topic.dart';
import '../models/user.dart';
import './is_loading.dart';
import './state.dart';

class FetchPostsAction extends ReduxAction<AppState> {
  final int topicId;
  final int pageIndex;

  FetchPostsAction({
    @required this.topicId,
    this.pageIndex = 0,
  }) : assert(topicId != null && pageIndex != null);

  @override
  Future<AppState> reduce() async {
    final uri = Uri.https("nga.178.com", "read.php", {
      "tid": topicId.toString(),
      "page": pageIndex.toString(),
      "__output": "11",
    });

    print(uri);

    final res = await get(uri, headers: {
      "cookie": state.cookies.entries
          .map((entry) => "${entry.key}=${entry.value}")
          .join(";")
    });

    final json = jsonDecode(res.body);

    final postsObject = json["data"]["__R"];

    final topicObject = json["data"]["__T"];

    var topic = Topic.fromJson(topicObject);

    var posts = List.from(postsObject)
        .map((value) => Post.fromJson(value))
        .map((post) => MapEntry(post.index, post));

    return state.copy(
      users: Map.of(state.users)
        ..addEntries(
          Map.from(json["data"]["__U"] ?? {})
              .values
              .map((value) => User.fromJson(value))
              .map((user) => MapEntry(user.id, user)),
        ),
      topics: Map.of(state.topics)
        ..update(
          topicId,
          (topicState) => topicState.copy(
            topic: topic,
            pages: topicState.posts..addEntries(posts),
          ),
          ifAbsent: () => TopicState(
            topic: topic,
            posts: Map.fromEntries(posts),
          ),
        ),
    );
  }

  void before() => dispatch(IsLoadingAction(true));

  void after() => dispatch(IsLoadingAction(false));
}
