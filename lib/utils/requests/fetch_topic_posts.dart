import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/topic.dart';
import 'package:ngnga/models/user.dart';

class FetchTopicPostsResponse {
  final Topic topic;
  final List<PostItem> posts;
  final List<Post> comments;
  final Map<int, User> users;

  final int maxPage;

  FetchTopicPostsResponse._({
    @required this.topic,
    @required this.posts,
    @required this.users,
    @required this.comments,
    @required this.maxPage,
  });

  factory FetchTopicPostsResponse.fromJson(Map<String, dynamic> json) {
    Map<int, User> users = {};
    List<PostItem> posts = [];
    List<Post> comments = [];

    for (var entry in Map.from(json['data']['__U']).entries) {
      if (entry.key == '__MEDALS' ||
          entry.key == '__REPUTATIONS' ||
          entry.key == '__GROUPS') continue;

      users[int.parse(entry.key)] = User.fromJson(entry.value);
    }

    for (var value in List.from(json['data']['__R'])) {
      posts.add(PostItem.fromJson(value));

      if (value['comment'] is List) {
        for (var value in List.of(value['comment'])) {
          comments.add(Post.fromJson(value));
        }
      }
    }

    return FetchTopicPostsResponse._(
      topic: Topic.fromJson(json['data']['__T']),
      posts: posts,
      comments: comments,
      users: users,
      maxPage: (json['data']['__ROWS'] - 1) ~/ json['data']['__R__ROWS_PAGE'],
    );
  }
}

Future<FetchTopicPostsResponse> fetchTopicPosts({
  @required Client client,
  @required String baseUrl,
  @required int topicId,
  @required int page,
}) async {
  final uri = Uri.https(baseUrl, 'read.php', {
    'tid': topicId.toString(),
    'page': (page + 1).toString(),
    '__output': '11',
  });

  print(uri);

  var response = await client.get(uri);

  final json = jsonDecode(response.body);

  return FetchTopicPostsResponse.fromJson(json);
}

Future<FetchTopicPostsResponse> fetchReply({
  @required Client client,
  @required String baseUrl,
  @required int topicId,
  @required int postId,
}) async {
  final uri = Uri.https(baseUrl, 'read.php', {
    'pid': postId.toString(),
    'tid': topicId.toString(),
    '__output': '11',
  });

  print(uri);

  final res = await client.get(uri);

  final json = jsonDecode(res.body);

  return FetchTopicPostsResponse.fromJson(json);
}
