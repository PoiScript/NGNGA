import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart';

import 'package:ngnga/models/topic.dart';

class FetchFavorTopicsResponse {
  final List<Topic> topics;
  final int topicsCount;
  final int maxPage;

  FetchFavorTopicsResponse._({
    this.topics,
    this.topicsCount,
    this.maxPage,
  }) : assert(topics != null && topicsCount != null);

  factory FetchFavorTopicsResponse.fromJson(Map<String, dynamic> json) {
    List<Topic> favorites = [];

    if (json['data'][0][0] is List) {
      for (final value in json['data'][0][0]) {
        if (value['__P'] == null) favorites.add(Topic.fromJson(value));
      }
    } else if (json['data'][0][0] is Map) {
      for (final value in json['data'][0][0].values) {
        if (value['__P'] == null) favorites.add(Topic.fromJson(value));
      }
    }

    return FetchFavorTopicsResponse._(
      topics: favorites,
      topicsCount: json['data'][0][1],
      maxPage: json['data'][0][1] ~/ json['data'][0][3],
    );
  }
}

Future<FetchFavorTopicsResponse> fetchFavorTopics({
  @required Client client,
  @required String baseUrl,
  @required int page,
}) async {
  final uri = Uri.https(baseUrl, 'nuke.php', {
    '__lib': 'topic_favor',
    '__act': 'topic_favor',
    'action': 'get',
    'page': (page + 1).toString(),
    '__output': '11',
  });

  print(uri);

  final res = await client.get(uri);

  final json = jsonDecode(res.body);

  return FetchFavorTopicsResponse.fromJson(json);
}
