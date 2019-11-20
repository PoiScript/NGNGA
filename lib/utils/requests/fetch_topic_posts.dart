import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/topic.dart';
import 'package:ngnga/models/user.dart';

class FetchTopicPostsResponse {
  final Topic topic;
  final Iterable<Post> posts;
  final List<MapEntry<int, User>> users;

  FetchTopicPostsResponse._({
    this.topic,
    this.posts,
    this.users,
  });

  factory FetchTopicPostsResponse.fromJson(Map<String, dynamic> json) {
    List<MapEntry<int, User>> users = [];

    for (var entry in Map.from(json["data"]["__U"]).entries) {
      try {
        final userId = int.parse(entry.key);
        final user = User.fromJson(entry.value);
        users.add(MapEntry(userId, user));
      } catch (_) {}
    }

    return FetchTopicPostsResponse._(
      topic: Topic.fromJson(json["data"]["__T"]),
      posts:
          List.from(json["data"]["__R"]).map((value) => Post.fromJson(value)),
      users: users,
    );
  }
}

Future<FetchTopicPostsResponse> fetchTopicPosts({
  @required Client client,
  @required int topicId,
  @required int page,
  @required List<String> cookies,
}) async {
  final uri = Uri.https("nga.178.com", "read.php", {
    "tid": topicId.toString(),
    "page": (page + 1).toString(),
    "__output": "11",
  });

  print(uri);

  final res = await client.get(uri, headers: {"cookie": cookies.join(";")});

  final json = jsonDecode(res.body);

  return FetchTopicPostsResponse.fromJson(json);
}
