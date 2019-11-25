import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/user.dart';

class FetchReplyResponse {
  final Post post;
  final Iterable<MapEntry<int, User>> users;

  FetchReplyResponse._({this.post, this.users});

  factory FetchReplyResponse.fromJson(Map<String, dynamic> json) {
    return FetchReplyResponse._(
      post: json["data"]["__R"].length > 0
          ? Post.fromJson(json["data"]["__R"][0])
          : null,
      users: Map.from(json["data"]["__U"])
          .values
          .map((value) => User.fromJson(value))
          .map((user) => MapEntry(user.id, user)),
    );
  }
}

Future<FetchReplyResponse> fetchReply({
  @required Client client,
  @required String baseUrl,
  @required String cookie,
  @required int topicId,
  @required int postId,
}) async {
  final uri = Uri.https(baseUrl, "read.php", {
    "pid": postId.toString(),
    "tid": topicId.toString(),
    "__output": "11",
  });

  print(uri);

  final res = await client.get(uri, headers: {"cookie": cookie});

  final json = jsonDecode(res.body);

  return FetchReplyResponse.fromJson(json);
}
