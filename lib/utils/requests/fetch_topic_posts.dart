import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/topic.dart';
import 'package:ngnga/models/user.dart';

import 'fetch_reply.dart';

class FetchTopicPostsResponse {
  final Topic topic;
  final List<Post> posts;
  final List<Post> comments;
  final List<User> users;

  final int maxPage;

  FetchTopicPostsResponse._({
    this.topic,
    this.posts,
    this.users,
    this.comments,
    this.maxPage,
  });

  factory FetchTopicPostsResponse.fromJson(Map<String, dynamic> json) {
    List<User> users = [];
    List<Post> posts = [];
    List<Post> comments = [];

    for (var entry in Map.from(json["data"]["__U"]).entries) {
      int userId = int.tryParse(entry.key);

      if (userId == null) continue;

      users.add(User.fromJson(entry.value, userId));
    }

    for (var value in List.from(json["data"]["__R"])) {
      posts.add(Post.fromJson(value));

      if (value['comment'] is List) {
        for (var value in List.of(value['comment'])) {
          comments.add(Post.fromJson(value));
        }
      }
    }

    return FetchTopicPostsResponse._(
      topic: Topic.fromJson(json["data"]["__T"]),
      posts: posts,
      comments: comments,
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

  var response = await client.get(uri, headers: {"cookie": cookie});

  final json = jsonDecode(response.body);

  List<User> users = [];
  List<Post> posts = [];
  List<Post> comments = [];

  for (var entry in Map.from(json["data"]["__U"]).entries) {
    int userId = int.tryParse(entry.key);

    if (userId == null) continue;

    users.add(User.fromJson(entry.value, userId));
  }

  for (var value in List.from(json["data"]["__R"])) {
    if (value['comment_to_id'] is int) {
      int index = comments.indexWhere((c) => c.id == value['pid']);

      if (index == -1) {
        var response = await fetchReply(
          client: client,
          cookie: cookie,
          postId: value['comment_to_id'],
          topicId: topicId,
          baseUrl: baseUrl,
        );
        posts.addAll(response.posts);
        users.addAll(response.users);
        comments.addAll(response.comments);
        index = comments.indexWhere((c) => c.id == value['pid']);
      }

      posts.add(comments[index].copy(
        index: value["lou"],
        commentTo: value['comment_to_id'],
      ));
    } else {
      posts.add(Post.fromJson(value));

      if (value['comment'] is List) {
        for (var value in List.of(value['comment'])) {
          comments.add(Post.fromJson(value));
        }
      }
    }
  }

  return FetchTopicPostsResponse._(
    topic: Topic.fromJson(json["data"]["__T"]),
    posts: posts,
    comments: comments,
    users: users,
    maxPage: (json["data"]["__ROWS"] - 1) ~/ json["data"]["__R__ROWS_PAGE"],
  );
}
