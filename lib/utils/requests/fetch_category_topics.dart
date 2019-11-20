import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:ngnga/models/topic.dart';

class FetchCategoryTopicsResponse {
  final Iterable<Topic> topics;
  final int topicCount;

  FetchCategoryTopicsResponse._({
    this.topics,
    this.topicCount,
  }) : assert(topics != null && topicCount != null);

  factory FetchCategoryTopicsResponse.fromJson(Map<String, dynamic> json) {
    return FetchCategoryTopicsResponse._(
      topics: (json["data"]["__T"] is List)
          ? List.from(json["data"]["__T"]).map((value) => Topic.fromJson(value))
          : Map.from(json["data"]["__T"])
              .values
              .map((value) => Topic.fromJson(value)),
      topicCount: json["data"]["__ROWS"],
    );
  }
}

Future<FetchCategoryTopicsResponse> fetchCategoryTopics({
  @required Client client,
  @required int categoryId,
  @required int page,
  @required bool isSubcategory,
  @required List<String> cookies,
}) async {
  final uri = isSubcategory
      ? Uri.https("nga.178.com", "thread.php", {
          "stid": categoryId.toString(),
          "page": (page + 1).toString(),
          "__output": "11",
        })
      : Uri.https("nga.178.com", "thread.php", {
          "fid": categoryId.toString(),
          "page": (page + 1).toString(),
          "__output": "11",
        });

  print(uri);

  final res = await client.get(uri, headers: {"cookie": cookies.join(";")});

  final json = jsonDecode(res.body);

  return FetchCategoryTopicsResponse.fromJson(json);
}
