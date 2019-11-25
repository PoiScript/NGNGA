import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:ngnga/models/favorite.dart';

class FetchFavorTopicsResponse {
  final List<Favorite> favorites;
  final int favoriteCount;

  FetchFavorTopicsResponse._({
    this.favorites,
    this.favoriteCount,
  }) : assert(favorites != null && favoriteCount != null);

  factory FetchFavorTopicsResponse.fromJson(Map<String, dynamic> json) {
    List<Favorite> favorites = [];

    if (json["data"][0][0] is List) {
      for (final value in json["data"][0][0]) {
        favorites.add(Favorite.fromJson(value));
      }
    } else if (json["data"][0][0] is Map) {
      for (final value in json["data"][0][0].values) {
        favorites.add(Favorite.fromJson(value));
      }
    }

    return FetchFavorTopicsResponse._(
      favorites: favorites,
      favoriteCount: json["data"][0][1],
    );
  }
}

Future<FetchFavorTopicsResponse> fetchFavorTopics({
  @required Client client,
  @required String baseUrl,
  @required String cookie,
  @required int page,
}) async {
  final uri = Uri.https(baseUrl, "nuke.php", {
    "__lib": "topic_favor",
    "__act": "topic_favor",
    "action": "get",
    "page": (page + 1).toString(),
    "__output": "11",
  });

  print(uri);

  final res = await client.get(uri, headers: {"cookie": cookie});

  final json = jsonDecode(res.body);

  return FetchFavorTopicsResponse.fromJson(json);
}
