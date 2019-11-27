import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'fetch_topic_posts.dart';

Future<FetchTopicPostsResponse> fetchReply({
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

  return FetchTopicPostsResponse.fromJson(json);
}
