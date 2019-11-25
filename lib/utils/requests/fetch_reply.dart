import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:ngnga/models/post.dart';
import 'package:ngnga/models/user.dart';

class FetchReplyResponse {
  final Post post;
  final List<MapEntry<int, User>> users;

  FetchReplyResponse._({this.post, this.users});

  factory FetchReplyResponse.fromJson(Map<String, dynamic> json) {
    List<MapEntry<int, User>> users = [];

    for (final entry in Map.from(json["data"]["__U"]).entries) {
      try {
        final userId = int.parse(entry.key);
        final user = User.fromJson(entry.value);
        users.add(MapEntry(userId, user));
      } on FormatException {} catch (e) {
        rethrow;
      }
    }

    return FetchReplyResponse._(
      post: json["data"]["__R"].length > 0
          ? Post.fromJson(json["data"]["__R"][0])
          : null,
      users: users,
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
