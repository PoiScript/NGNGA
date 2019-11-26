import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/topic.dart';
import 'package:ngnga/models/user.dart';

class FetchTopicPostsResponse {
  final Topic topic;
  final List<Post> posts;
  final List<User> users;

  final int maxPage;

  FetchTopicPostsResponse._({
    this.topic,
    this.posts,
    this.users,
    this.maxPage,
  });

  factory FetchTopicPostsResponse.fromJson(Map<String, dynamic> json) {
    List<User> users = [];
    List<Post> posts = [];

    for (var entry in Map.from(json["data"]["__U"]).entries) {
      try {
        users.add(User.fromJson(entry.value, int.parse(entry.key)));
      } on FormatException {} catch (e) {
        rethrow;
      }
    }

    for (var value in List.from(json["data"]["__R"])) {
      posts.add(Post.fromJson(value));
    }

    return FetchTopicPostsResponse._(
      topic: Topic.fromJson(json["data"]["__T"]),
      posts: posts,
      users: users,
      maxPage: (json["data"]["__ROWS"] - 1) ~/ json["data"]["__R__ROWS_PAGE"],
    );
  }
}

Future<FetchTopicPostsResponse> fetchTopicPosts({
  @required Client client,
  @required String baseUrl,
  @required String cookie,
  @required int topicId,
  @required int page,
}) async {
  final uri = Uri.https(baseUrl, "read.php", {
    "tid": topicId.toString(),
    "page": (page + 1).toString(),
    "__output": "11",
  });

  print(uri);

  final res = await client.get(uri, headers: {"cookie": cookie});

  final json = jsonDecode(res.body);

  return FetchTopicPostsResponse.fromJson(json);
}
