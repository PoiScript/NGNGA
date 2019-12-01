import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ngnga/models/category.dart';

import 'package:ngnga/models/topic.dart';

class FetchCategoryTopicsResponse {
  final List<Topic> topics;
  final List<Category> categories;
  final int topicCount;
  final int maxPage;

  FetchCategoryTopicsResponse._({
    this.topics,
    this.categories,
    this.topicCount,
    this.maxPage,
  }) : assert(topics != null && topicCount != null);

  factory FetchCategoryTopicsResponse.fromJson(Map<String, dynamic> json) {
    List<Topic> topics = [];
    List<Category> categories = [];

    if (json['data']['__T'] is List) {
      for (var value in List.from(json['data']['__T'])) {
        Topic topic = Topic.fromJson(value);
        if (topic.category != null) categories.add(topic.category);
        topics.add(topic);
      }
    } else {
      for (var value in Map.from(json['data']['__T']).values) {
        Topic topic = Topic.fromJson(value);
        if (topic.category != null) categories.add(topic.category);
        topics.add(topic);
      }
    }

    return FetchCategoryTopicsResponse._(
      topics: topics,
      categories: categories,
      topicCount: json['data']['__ROWS'],
      maxPage: json['data']['__ROWS'] ~/ json['data']['__T__ROWS_PAGE'],
    );
  }
}

Future<FetchCategoryTopicsResponse> fetchCategoryTopics({
  @required Client client,
  @required String baseUrl,
  @required String cookie,
  @required int categoryId,
  @required int page,
  @required bool isSubcategory,
}) async {
  final uri = Uri.https(baseUrl, 'thread.php', {
    isSubcategory ? 'stid' : 'fid': categoryId.toString(),
    'page': (page + 1).toString(),
    '__output': '11',
  });

  print(uri);

  final res = await client.get(uri, headers: {'cookie': cookie});

  final json = jsonDecode(res.body);

  return FetchCategoryTopicsResponse.fromJson(json);
}
