import 'dart:async';
import 'dart:convert';

import 'package:async_redux/async_redux.dart';
import 'package:http/http.dart';

import '../models/post.dart';
import '../models/topic.dart';
import '../models/user.dart';
import './is_loading.dart';
import './state.dart';

class FetchPostsAction extends ReduxAction<AppState> {
  final Topic topic;
  final int page;

  FetchPostsAction({
    this.topic,
    this.page,
  });

  @override
  Future<AppState> reduce() async {
    final uri = Uri.https("nga.178.com", "read.php", {
      "tid": topic.id.toString(),
      "page": page.toString(),
      "__output": "11",
    });

    print(uri);

    print(state.cookies);

    final res = await get(uri, headers: {
      "cookie": state.cookies.entries
          .map((entry) => "${entry.key}=${entry.value}")
          .join(";")
    });

    final json = jsonDecode(res.body);

    final postsObject = json["data"]["__R"];

    final topicObject = json["data"]["__T"];

    var topic1 = Topic.fromJson(topicObject);

    var posts =
        List.from(postsObject).map((value) => Post.fromJson(value)).toList();

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
          topic.id,
          (state) => state.copy(
            topic: topic1,
            pages: state.pages
              ..update(page, (_) => posts, ifAbsent: () => posts),
          ),
          ifAbsent: () => TopicState(
            topic: topic1,
            pages: {page: posts},
          ),
        ),
    );
  }

  void before() => dispatch(IsLoadingAction(true));

  void after() => dispatch(IsLoadingAction(false));
}
