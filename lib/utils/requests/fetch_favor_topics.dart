import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:ngnga/models/topic.dart';

class FetchFavorTopicsResponse {
  final List<Topic> topics;
  final int topicCount;

  FetchFavorTopicsResponse._({
    this.topics,
    this.topicCount,
  }) : assert(topics != null && topicCount != null);

  factory FetchFavorTopicsResponse.fromJson(Map<String, dynamic> json) {
    return FetchFavorTopicsResponse._(
      topics: List.from(json["data"]["__T"])
          .map((value) => Topic.fromJson(value))
          .toList(),
      topicCount: json["data"]["__ROWS"],
    );
  }
}

Future<FetchFavorTopicsResponse> fetchFavorTopics({
  @required List<String> cookies,
}) async {
  final uri = Uri.https("nga.178.com", "thread.php", {
    "favor": "1",
    "__output": "11",
  });

  print(uri);

  final res = await get(uri, headers: {"cookie": cookies.join(";")});

  final json = jsonDecode(res.body);

  return FetchFavorTopicsResponse.fromJson(json);
}
