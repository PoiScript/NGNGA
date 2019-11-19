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
    return FetchFavorTopicsResponse._(
      favorites: List.from(json["data"][0][0])
          .map((value) => Favorite.fromJson(value))
          .toList(),
      favoriteCount: json["data"][0][1],
    );
  }
}

Future<FetchFavorTopicsResponse> fetchFavorTopics({
  @required List<String> cookies,
  @required int page,
}) async {
  final uri = Uri.https("nga.178.com", "nuke.php", {
    "__lib": "topic_favor",
    "__act": "topic_favor",
    "action": "get",
    "page": (page + 1).toString(),
    "__output": "11",
  });

  print(uri);

  final res = await get(uri, headers: {"cookie": cookies.join(";")});

  final json = jsonDecode(res.body);

  return FetchFavorTopicsResponse.fromJson(json);
}
