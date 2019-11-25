import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart';

class FavoritesResponse {
  final String message;

  FavoritesResponse._({
    @required this.message,
  });

  factory FavoritesResponse.fromJson(Map<String, dynamic> json) {
    return FavoritesResponse._(message: json['data'][0]);
  }
}

Future<FavoritesResponse> addToFavorites({
  @required Client client,
  @required String baseUrl,
  @required String cookie,
  @required int topicId,
}) async {
  final uri = Uri.https(baseUrl, "nuke.php", {
    "__lib": "topic_favor",
    "__act": "topic_favor",
    "action": "add",
    "tid": topicId.toString(),
    "__output": "11",
  });

  print(uri);

  final res = await client.post(uri, headers: {"cookie": cookie});

  final json = jsonDecode(res.body);

  return FavoritesResponse.fromJson(json);
}

Future<FavoritesResponse> removeFromFavorites({
  @required Client client,
  @required String baseUrl,
  @required String cookie,
  @required int topicId,
}) async {
  final uri = Uri.https(baseUrl, "nuke.php", {
    "__lib": "topic_favor",
    "__act": "topic_favor",
    "action": "del",
    "tidarray": topicId.toString(),
    // TODO: handle different page index
    "page": "1",
    "__output": "11",
  });

  print(uri);

  final res = await client.post(uri, headers: {"cookie": cookie});

  final json = jsonDecode(res.body);

  return FavoritesResponse.fromJson(json);
}
